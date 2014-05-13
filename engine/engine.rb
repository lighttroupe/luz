 ###############################################################################
 #  Copyright 2006 Ian McIntosh <ian@openanswers.org>
 #
 #  This program is free software; you can redistribute it and/or modify
 #  it under the terms of the GNU General Public License as published by
 #  the Free Software Foundation; either version 2 of the License, or
 #  (at your option) any later version.
 #
 #  This program is distributed in the hope that it will be useful,
 #  but WITHOUT ANY WARRANTY; without even the implied warranty of
 #  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 #  GNU Library General Public License for more details.
 #
 #  You should have received a copy of the GNU General Public License
 #  along with this program; if not, write to the Free Software
 #  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 ###############################################################################

multi_require 'engine/engine_methods_for_user_object', 'director', 'actor', 'curve', 'theme', 'variable', 'event', 'user_object', 'user_object_setting', 'project', 'image', 'actor_shape', 'actor_canvas'

optional_require 'beat_detector'
optional_require 'message_bus'

class Engine
	USER_OBJECT_EXCEPTION_FORMAT = "#{'#' * 80}\nOops! The plugin shown below has caused an error and has stopped functioning:\n\n%s\nObject:%s\n#{'#' * 80}\n"
	OBJECT_CLASS_TO_SYMBOL = {Actor => :actors, Director => :directors, Theme => :themes, Curve => :curves, Variable => :variables, Event => :events, ProjectEffect => :effects}

	PLUGIN_DIRECTORY_PATH = File.join(Dir.pwd, 'engine', 'plugins')
	BASE_SET_PATH = 'base.luz'

	attr_accessor :director, :theme, :simulation_speed, :frame_number
	attr_reader :project, :background_color

	#
	# Callbacks
	#
	callback :new_project
	callback :frame_end
	callback :new_user_object_class
	callback :reload
	callback :update_user_objects
	callback :user_object_changed
	callback :user_object_exception
	callback :crash

	include Drawing
	include MethodsForUserObject		# engine gets 'em, too.

	require 'engine/engine_buttons'
	include EngineButtons

	require 'engine/engine_sliders'
	include EngineSliders

	require 'engine/engine_images'
	include EngineImages

	if optional_require 'engine/engine_dmx'
		include EngineDMX
	end

	###################################################################
	# Init / Shutdown
	###################################################################
	def initialize(options = {})
		@simulation_speed = 1.0
		@paused = false
		@frame_number, @time = 0, 0.0
		@last_frame_time = 0.0
		@total_frame_times = 0.0
		@add_to_engine_time = 0.0

		@beat_detector = BeatDetector.new if defined? BeatDetector

		@event_values = Hash.new

		$env = Hash.new

		@num_known_user_object_classes = 0

		@perspective = [-0.5, 0.5, -0.5, 0.5]

		@message_buses = []
		if defined? MessageBus
			add_message_bus(options[:listen_ip] || MESSAGE_BUS_IP, options[:listen_port] || MESSAGE_BUS_PORT)
		end
	end

	#
	# Time
	#
	def reset_time!
		@time = 0.0
	end

	def add_to_engine_time(amount)
		@add_to_engine_time += amount
	end

	def notify_of_new_user_object_classes
		# call the notify callback for just new ones
		@num_known_user_object_classes.upto(UserObject.inherited_classes.size - 1) { |index|
			new_user_object_class_notify(UserObject.inherited_classes[index])
		}
		@num_known_user_object_classes = UserObject.inherited_classes.size
	end

	# Some init has to be done after we have the $engine variable set (so after initialize returns)
	def post_initialize
		init_environment
		update_environment

		button_init
		slider_init

		set_opengl_defaults
		projection
		view

		@project = Project.new
		@frame_number -= 1 ; tick(@last_frame_time)		# set up the environment HACK: without counting it
	end

	def average_frame_time
		@total_frame_times / @frame_number
	end

	def average_frames_per_second
		@frame_number / @total_frame_times
	end

	def clear_objects
		@project.clear
	end

	def do_frame(time)
		return if @paused

		frame_start = Time.now

		tick(time)
		render(enable_frame_saving=true)

		frame_end_notify
		@total_frame_times += (Time.now - frame_start)
	end

	#
	# Beats
	#
	def beat!
		@beat_detector.beat!(@frame_time)
	end

	pipe :beat_zero!, :beat_detector
	pipe :next_beat_is_zero!, :beat_detector
	pipe :beat_double_time!, :beat_detector
	pipe :beat_half_time!, :beat_detector
	pipe :beats_per_minute, :beat_detector
	pipe :beats_per_minute=, :beat_detector

	#
	# Pausing
	#
	boolean_accessor :paused
	def paused=(pause)
		project.effects.each { |effect| effect.pause if effect.respond_to? :pause } if pause and !@paused
		@paused = pause
	end

	###################################################################
	# Save / Load
	###################################################################
	def load_from_path(path)
		@project.load_from_path(path)
		new_project_notify
	end

	pipe :save, :project
	pipe :save_to_path, :project
	pipe :project_changed!, :project, :method => :changed!
	pipe :project_changed?, :project, :method => :changed?

	def load_plugins
		count = load_directory(PLUGIN_DIRECTORY_PATH, '*.luz.rb')
		notify_of_new_user_object_classes
		return count
	end

	def reload
		change_count = reload_modified_source_files		# Kernel add-on method
		change_count += load_plugins		# Pick up any new plugins
		reinitialize_user_objects				# Ensures UOs are properly init'd
		update_user_objects_notify			# Let everyone know that UOs changed
		reload_notify
		return change_count
	end

	def reinitialize_user_objects
		@project.each_user_object { |obj| safe { obj.after_load } }
		@project.each_user_object { |obj| safe { obj.resolve_settings } }
		@project.each_user_object { |obj| obj.crashy = false }
	end

	###################################################################
	# Exception Handling
	###################################################################
	def user_object_try(obj)
		begin
			return yield if obj.usable?		# NOTE: doesn't yield for "crashed" UOs
		rescue Interrupt => e
			raise e
		rescue Exception => e
			obj.crashy = true
			obj.last_exception = e if $gui
			user_object_exception_notify(obj, e)
			user_object_changed_notify(obj)
		end
	end

	def safe
		begin
			yield
		rescue Interrupt => e
			raise e
		rescue Exception => e
			e.report
		end
	end

	###################################################################
	# Rendering
	###################################################################

	def render(enable_frame_saving)
		if enable_frame_saving && frame_saving_requested?
			with_frame_saving { |target_buffer|
				target_buffer.using(:clear => true) {
					render_recursively(@project.effects) {
						# Nothing to do when reaching the end of the effects chain
					}
				}

				# draw created image to screen
				target_buffer.with_image {
					fullscreen_rectangle
				}
			}
		else
			render_recursively(@project.effects) { }
		end
	end

	#
	# NOTE: This is a prototype for a generic recursive renderer, to replace that of actors/directors and maybe themes/variables/events
	#
	def render_recursively(user_objects, index=0, &proc)
		uo = user_objects[index]
		return proc.call unless uo

		if uo.usable?
			$engine.user_object_try(uo) {
				uo.resolve_settings
				uo.tick!
				uo.render {
					render_recursively(user_objects, index+1, &proc)		# continue (potentially multiple times-- this is how Grid and other child-creating plugins work)
				}
			}
		else
			render_recursively(user_objects, index+1, &proc)				# skip
		end
	end

	#
	# OpenGL
	#
	def projection
		@camera_distance_from_origin = 0.5

		# TODO: comment formula below
		angle = 2.0 * Math.atan(0.5 / @camera_distance_from_origin) * RADIANS_TO_DEGREES

		GL.MatrixMode(GL::PROJECTION)
		GL.LoadIdentity

		# 1.0 = output ratio
		GLU.Perspective(angle, 1.0, 0.001, 1024.0) # NOTE: near/far clip plane numbers are somewhat arbitrary.
	end

	def view
		GL.MatrixMode(GL::MODELVIEW)
		GL.LoadIdentity
		GL.Translate(0,0,-@camera_distance_from_origin) # NOTE: makes a 1x1 object at the origin visible/fullscreen
	end

	def set_opengl_defaults
		GL.Enable(GL::BLEND)
		GL.BlendFunc(GL::SRC_ALPHA, GL::ONE_MINUS_SRC_ALPHA)

		# POLYGON_SMOOTH causes seams on NVidia hardware
		#GL.Enable(GL::POLYGON_SMOOTH)
		#GL.Hint(GL::POLYGON_SMOOTH_HINT, GL::NICEST)

		GL.ShadeModel(GL::FLAT)			# TODO: probably want to change this

		# When using painter's algorithm for 2D, no need for depth test
		GL.Disable(GL::DEPTH_TEST)

		# Many effects rely on the backface to be visible (eg. flip_horizontally)
		GL.Disable(GL::CULL_FACE)
		GL.PolygonMode(GL::FRONT, GL::FILL)
		GL.PolygonMode(GL::BACK, GL::FILL)

		GL.Enable(GL::TEXTURE_2D)
	end

private

	def tick(frame_time)
		slider_tick

		@frame_number += 1
		#printf("Frame: %05d ==================================\n", @frame_number)

		# Project PreTick		NOTE: at this point $env is from previous frame
		@project.effects.each { |effect| user_object_try(effect) { effect.pretick } }

		# Real-World Time
		@frame_time = frame_time
		@frame_time_delta = @frame_time - @last_frame_time

		# Engine time (modified by simulation speed)
		@time_delta = (@simulation_speed * (@frame_time_delta)) + @add_to_engine_time
		@time += @time_delta
		@add_to_engine_time = 0.0

		# Update inputs
		@message_buses.each { |bus| bus.update }

		update_environment

		resolve_events

		# Project Tick
		@project.effects.each { |effect| effect.tick! }

		# Beat
		@beat_detector.tick(@frame_time) if @beat_detector

		@last_frame_time = @frame_time
	end

	#
	# Events
	#
	def resolve_events
		@project.events.each { |event| event.do_value }
	end

	#
	# Message bus
	#
	def add_message_bus(ip, port)
		message_bus = MessageBus.new.listen(ip, port)
		message_bus.on_button_down(&method(:on_button_down))
		message_bus.on_button_up(&method(:on_button_up))
		message_bus.on_slider_change(&method(:on_slider_change))
		@message_buses << message_bus
	end

	#
	# Environment
	#
	def init_environment
		$env[:time] = 0.0
		$env[:beat] = 0.0
		$env[:output_width] = $application.width
		$env[:output_height] = $application.height

		# Because of the nature of with_x { } blocks, we only need to set some things once
		# NOTE: an editor GUI *can* mess with these values, though, and this is intentional!

		$env[:last_message_bus_activity_at] = nil					# set by message bus
		$env[:time_since_message_bus_activity] = 999.0		# like fo'eva

		# Default enter/exit is right in the middle (fully on stage)
		$env[:enter] = 1.0
		$env[:exit] = 0.0
	end

	def update_environment
		beat_scale = @beat_detector.progress			# a fuzzy (0.0 to 1.0 inclusive) measure of progress within the current beat
		bpm = @beat_detector.beats_per_minute

		# Integer beat counts
		$env[:beat_number] = @beat_detector.beat_number					# integer beat count
		$env[:beats_per_measure] = @beat_detector.beats_per_measure					# integer beat count
		$env[:beat_index_in_measure] = $env[:beat_number] % $env[:beats_per_measure]

		# Integer measure count
		$env[:measure_number] = $env[:beat_number].div($env[:beats_per_measure])				# TODO: account for measure changes ?

		# Floating point measure scale (0.0 to 1.0)
		$env[:measure_scale] = ($env[:beat_index_in_measure] + beat_scale) / $env[:beats_per_measure]

		# Floating point measure number (eg. measure 503.2)
		$env[:measure] = $env[:measure_number] + $env[:measure_scale]

		# Floating point beat scale (0.0 to 1.0)
		$env[:previous_beat_scale] = $env[:beat_scale]		# TODO: does this need to be initialized for frame 0?
		$env[:beat_scale] = beat_scale						# fuzzy beat (0.0 to 1.0)

		# Floating point beat count (eg. beat 2012.8)
		$env[:previous_beat] = $env[:beat]
		$env[:beat] = ($env[:beat_number] + beat_scale)
		$env[:beat_delta] = ($env[:beat] - $env[:previous_beat])

		$env[:is_beat] = @beat_detector.is_beat?	# boolean
		$env[:bpm] = bpm
		$env[:bps] = bpm / 60.0
		$env[:seconds_per_beat] = 60.0 / bpm
		$env[:frame_number] = @frame_number

		$env[:previous_time] = $env[:time]
		$env[:time] = @time
		$env[:time_delta] = @time_delta

		$env[:frame_time] = @frame_time						# TODO: change to 'real world time' or something
		$env[:frame_time_delta] = @frame_time_delta

		# Default birth times: beginning of engine time
		$env[:birth_time] = 0.0
		$env[:birth_beat] = 0

		$env[:child_index] = 0
		$env[:total_children] = 1

		$env[:time_since_message_bus_activity] = ($env[:frame_time] - $env[:last_message_bus_activity_at]) if $env[:last_message_bus_activity_at]
	end

	if optional_require 'rb-inotify'
		puts 'Using iNotify for live reloading of changed images'

		$notifier ||= INotify::Notifier.new		# seems we only need one

		def with_watch(file_path)
			# Load file
			if yield
				# Add a watch, and when it fires, yield again
				$notifier.watch(file_path, :close_write) {
					puts "Reloading #{file_path} ..."
					yield
				}

				$notifier_io = [$notifier.to_io]
				$engine.on_frame_end { $notifier.process if IO.select($notifier_io, nil, nil, 0) } unless $notifier_callback_set
				$notifier_callback_set = true
			end
		end
	else
		def with_watch(file_path)		# stub
			yield
		end
	end
end
