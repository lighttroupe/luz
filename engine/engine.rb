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

	require 'engine/engine_message_bus'
	include EngineMessageBus

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

	require 'engine/engine_file_monitoring'
	include EngineFileMonitoring

	if optional_require 'engine/engine_dmx'
		include EngineDMX
	end

	#
	# Init
	#
	def initialize(options = {})
		@frame_number = 0
		@num_known_user_object_classes = 0
		$env = Hash.new

		init_pausing
		init_time
		init_beats

		init_message_bus
		add_message_bus(options[:listen_ip] || MESSAGE_BUS_IP, options[:listen_port] || MESSAGE_BUS_PORT)
	end

	# NOTE: some init has to be done after we have the $engine variable set (so after initialize returns)
	def post_initialize
		init_environment
		update_environment

		init_buttons
		init_sliders

		init_project

		set_opengl_defaults
		projection
		view

		# set up the environment
		@frame_number -= 1			# HACK: without counting it
		tick(@last_frame_time)
	end

	def do_frame(time)
		return if @paused

		record_frame_time {
			tick(time)
			render(enable_frame_saving=true)
			frame_end_notify
		}
	end

	def reload
		change_count = reload_modified_source_files		# Kernel add-on method
		change_count += load_plugins		# Pick up any new plugins
		reinitialize_user_objects				# Ensures UOs are properly init'd
		update_user_objects_notify			# Let everyone know that UOs changed
		reload_notify
		return change_count
	end

private

	def resolve_events
		@project.events.each { |event| event.do_value }			# unlike sliders, events would lose "presses" if not updated every frame
	end
end
