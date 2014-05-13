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

	require 'engine/engine_project'
	include EngineProject

	require 'engine/engine_time'
	include EngineTime

	require 'engine/engine_beats'
	include EngineBeats

	require 'engine/engine_buttons'
	include EngineButtons

	require 'engine/engine_sliders'
	include EngineSliders

	require 'engine/engine_images'
	include EngineImages

	require 'engine/engine_exceptions'
	include EngineExceptions

	require 'engine/engine_rendering'
	include EngineRendering

	require 'engine/engine_environment'
	include EngineEnvironment

	require 'engine/engine_plugins'
	include EnginePlugins

	require 'engine/engine_pausing'
	include EnginePausing

	if optional_require 'engine/engine_dmx'
		include EngineDMX
	end

	###################################################################
	# Init / Shutdown
	###################################################################
	def initialize(options = {})
		@frame_number = 0
		init_engine_pausing
		init_engine_time
		init_engine_beats

		$env = Hash.new

		@num_known_user_object_classes = 0
		@perspective = [-0.5, 0.5, -0.5, 0.5]

		@message_buses = []
		if defined? MessageBus
			add_message_bus(options[:listen_ip] || MESSAGE_BUS_IP, options[:listen_port] || MESSAGE_BUS_PORT)
		end
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

		init_engine_project

		@frame_number -= 1 ; tick(@last_frame_time)		# set up the environment HACK: without counting it
	end

	def reload
		change_count = reload_modified_source_files		# Kernel add-on method
		change_count += load_plugins		# Pick up any new plugins
		reinitialize_user_objects				# Ensures UOs are properly init'd
		update_user_objects_notify			# Let everyone know that UOs changed
		reload_notify
		return change_count
	end

	def clear_objects
		@project.clear
	end

	def do_frame(time)
		return if @paused

		record_frame_time {
			tick(time)
			render(enable_frame_saving=true)
			frame_end_notify
		}
	end

private

	def tick(frame_time)
		slider_tick

		@frame_number += 1
		#printf("Frame: %05d ==================================\n", @frame_number)

		# Project PreTick		NOTE: at this point $env is from previous frame
		@project.effects.each { |effect| user_object_try(effect) { effect.pretick } }

		update_time(frame_time)

		# Update inputs
		@message_buses.each { |bus| bus.update }

		update_environment

		# Resolve Events
		@project.events.each { |event| event.do_value }

		# Project Tick
		@project.effects.each { |effect| effect.tick! }

		# Beat
		update_beats(frame_time)

		@last_frame_time = frame_time
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
