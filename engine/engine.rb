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

require 'beat_detector', 'message_bus', 'director', 'actor', 'curve', 'theme', 'variable', 'event', 'user_object', 'user_object_setting', 'project', 'image'
require 'actor_shape', 'actor_canvas'

begin
	require 'inline'
	require 'addons_inline'
rescue LoadError
	puts "ruby-inline is unavailable: you are missing out on a possible performance increase"
rescue Exception => e
	puts "error loading ruby-inline: #{e}"
end

class Engine
	USER_OBJECT_EXCEPTION_FORMAT = "#{'#' * 80}\nOops! The plugin shown below has caused an error and has stopped functioning:\n\n%s\nObject:%s\n#{'#' * 80}\n"
	OBJECT_CLASS_TO_SYMBOL = {Actor => :actors, Director => :directors, Theme => :themes, Curve => :curves, Variable => :variables, Event => :events, ProjectEffect => :effects}

	include Drawing

	require 'engine_buttons'
	include EngineButtons

	require 'engine_sliders'
	include EngineSliders

	require 'engine_images'
	include EngineImages

	require 'engine_dmx'
	include EngineDMX

	require 'engine_sound'
	include EngineSound

	module MethodsForUserObject
		def first_frame?
			$env[:frame_number] == 1
		end

		def with_time_shift(second_offset, &proc)
			with_env(:time, ($env[:time] + second_offset), &proc)		 # TODO: how about a generic with_env_addition(:time, second_offset) { ... }
		end

		def with_beat_shift(beat_offset)
			old_beat, old_beat_number = $env[:beat], $env[:beat_number]
			$env[:beat] += beat_offset
			$env[:beat_number] += beat_offset
			yield
			$env[:beat], $env[:beat_number] = old_beat, old_beat_number
		end

		def with_env(var, value)
			old_value = $env[var]
			return yield if (value == old_value)
			$env[var] = value			# TODO: make cumulative += version
			yield
			$env[var] = old_value
		end

		def with_enter_and_exit(enter, exit)
			old_enter, old_exit = $env[:enter], $env[:exit]
			return yield if (enter == old_enter && exit == old_exit)
			$env[:enter], $env[:exit] = enter.clamp(0.0, 1.0), exit.clamp(0.0, 1.0)
			yield
			$env[:enter], $env[:exit] = old_enter, old_exit
		end

		# Easy way to turn a fuzzy (0.0..1.0) to enter/exit values
		def with_enter_exit_progress(value)
			with_env(:enter, (value < 0.5) ? (value / 0.5) : 1.0) {
				with_env(:exit, (value > 0.5) ? ((value - 0.5) / 0.5) : 0.0) {
					yield
				}
			}
		end

		def with_env_hash(hash)
			old_values = Hash.new
			# Save current value, set new one
			hash.each_pair { |key, value| old_values[key] = $env[key] ; $env[key] = value }
			yield
			# Restore old values
			old_values.each_pair { |key, value| $env[key] = value }
		end
	end
	UserObject.send(:include, MethodsForUserObject)

	include MethodsForUserObject		# engine gets 'em, too.

	PLUGIN_DIRECTORY_PATH = Dir.pwd + '/plugins/'
	BASE_SET_PATH = 'base.luz'

	attr_accessor :director, :theme, :simulation_speed, :frame_number
	attr_reader :project, :background_color
	boolean_accessor :paused

	def paused=(pause)
		project.effects.each { |effect| effect.pause if effect.respond_to? :pause } if pause and !@paused
		@paused = pause
	end

	def beat!
		@beat_detector.beat!(@frame_time)
	end

	pipe :beat_zero!, :beat_detector
	pipe :next_beat_is_zero!, :beat_detector
	pipe :beat_double_time!, :beat_detector
	pipe :beat_half_time!, :beat_detector
	pipe :beats_per_minute, :beat_detector
	pipe :beats_per_minute=, :beat_detector

	callback :crash
	callback :update_user_objects

	callback :reload

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

		@beat_detector = BeatDetector.new

		@event_values = Hash.new

		$env = Hash.new
		init_environment
		update_environment

		button_init
		slider_init

		@num_known_user_object_classes = 0

		@perspective = [-0.5, 0.5, -0.5, 0.5]

		@message_buses = []
		if defined? MessageBus
			add_message_bus(options[:listen_ip] || MESSAGE_BUS_IP, options[:listen_port] || MESSAGE_BUS_PORT)
			@message_buses.last.relay_port = options[:relay_port] if options[:relay_port]
		end
	end

	def reset_time!
		@time = 0.0
	end

	def add_message_bus(ip, port)
		message_bus = MessageBus.new.listen(ip, port)
		message_bus.on_button_down(&method(:on_button_down))
		message_bus.on_button_up(&method(:on_button_up))
		message_bus.on_slider_change(&method(:on_slider_change))
		@message_buses << message_bus
	end

	def add_to_engine_time(amount)
		@add_to_engine_time += amount
	end

	callback :new_user_object_class
	def notify_of_new_user_object_classes
		# call the notify callback for just new ones
		@num_known_user_object_classes.upto(UserObject.inherited_classes.size - 1) { |index|
			new_user_object_class_notify(UserObject.inherited_classes[index])
		}
		@num_known_user_object_classes = UserObject.inherited_classes.size
	end

	# Some init has to be done after we have the $engine variable set (so after initialize returns)
	def post_initialize
		@project = Project.new
		@frame_number -= 1 ; tick(@last_frame_time)		# set up the environment HACK: without counting it
	end

	def average_frame_time
		@total_frame_times / @frame_number
	end

	def average_frames_per_second
		@frame_number / @total_frame_times
	end

	callback :clear_objects
	def clear_objects
		clear_objects_notify		# NOTE: project (and others) can listen to this and do the work
	end

	callback :new_project
	def add_default_objects
		@project.append_from_path(BASE_SET_PATH)
		new_project_notify
		@project.not_changed!
	end

	callback :render
	callback :render_settings_changed
	callback :frame_start
	callback :frame_end
	def do_frame(time)
		unless @paused
			frame_start = Time.now

			#
			# render at given real-world (or a carefully controlled time when non-realtime-recording) on which engine time is based
			#
			tick(time)

			frame_start_notify
			render_settings_changed_notify if @frame_number == 1
			render_notify
			frame_end_notify

			@total_frame_times += (Time.now - frame_start)
		end
	end

	###################################################################
	# Save / Load
	###################################################################
	def load_from_path(path)
		@project.load_from_path(path)
		new_project_notify
	end

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

	# hardwire! instructs objects to optimize themselves (in non-reversable ways)
	pipe :hardwire!, :project

	###################################################################
	# Exception Handling
	###################################################################
	callback :user_object_changed
	callback :user_object_exception

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
		#if first_frame?		# should only need to do these once since all changes use: with_setting { yield } but perhaps also when GL context is lost?
			render_settings
			projection
			view
		#end

		if (enable_frame_saving and frame_saving_requested?)
			with_frame_saving { |target_buffer|
				target_buffer.using(:clear => true) {
					render_recursively(@project.effects) {
						# Nothing to do when reaching the end of the effects chain
					}
				}

				# draw screen rendered
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

		if !uo.usable?
			render_recursively(user_objects, index+1, &proc)
		else
			$engine.user_object_try(uo) {
				uo.resolve_settings
				uo.tick!
				uo.render {
					# when it yields, continue down the chain
					render_recursively(user_objects, index+1, &proc)
				}
			}
		end
	end

	#
	# OpenGL
	#
	def render_settings
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
		@project.effects.each { |effect| user_object_try(effect) { effect.resolve_settings ; effect.tick } }

		# Beat
		@beat_detector.tick(@frame_time)

		@last_frame_time = @frame_time
	end

	#
	# Events
	#
	def resolve_events
		@project.events.each { |event| event.do_value }
	end

	#
	# Environment
	#
	def init_environment
		$env[:time] = 0.0
		$env[:beat] = 0.0

		# Because of the nature of with_x { } blocks, we only need to set some things once
		# NOTE: an editor GUI *can* mess with these values, though, and this is intentional!

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
	end
end
