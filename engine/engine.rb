multi_require 'engine/engine_methods_for_user_object', 'director', 'actor', 'curve', 'theme', 'variable', 'event', 'user_object', 'user_object_setting', 'project', 'image', 'actor_shape', 'actor_canvas'

optional_require 'message_bus'

class Engine
	PLUGIN_DIRECTORY_PATH = File.join(Dir.pwd, 'engine', 'plugins')

	attr_accessor :director, :theme, :simulation_speed, :frame_number
	attr_reader :project, :background_color

	#
	# Callbacks
	#
	callback :new_project
	callback :frame_end
	callback :reload
	callback :user_object_exception

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
	# Init (happens after $engine variable is set, ie after initialize returns)
	#
	def post_initialize(options = {})
		@frame_number = 0

		init_pausing
		init_time
		init_beats

		init_message_bus
		add_message_bus(options[:listen_ip] || MESSAGE_BUS_IP, options[:listen_port] || MESSAGE_BUS_PORT)

		$env = Hash.new
		init_environment

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
		reinitialize_user_objects
		reload_notify
		return change_count
	end

private

	def tick(frame_time)
		slider_tick								# TODO: does this really need to come first?

		@frame_number += 1				# ; printf("Frame: %05d ==================================\n", @frame_number)

		project_pretick						# NOTE: at this point $env is from previous frame
		update_time(frame_time)
		read_from_message_bus
		update_environment
		resolve_events
		project_tick
		update_beats(frame_time)

		$gui.gui_tick! if $gui

		@last_frame_time = frame_time
	end

	def resolve_events
		@project.events.each { |event| event.do_value }			# unlike sliders, events would lose "presses" if not updated every frame
	end
end
