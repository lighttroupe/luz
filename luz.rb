#!/usr/bin/env ruby
######################################################################################
# Copyright 2018 Ian McIntosh <ian@openanswers.org> released under the GPL version 2 #
######################################################################################

puts "Using Ruby #{RUBY_VERSION}#{" - WARNING: Intended for Ruby 2+" if RUBY_VERSION[0] == '1'}"

Dir.chdir(File.dirname(__FILE__))		# (so this file can be run from anywhere)

# load path
$LOAD_PATH.unshift('./utils').unshift('./engine').unshift('./engine/user_object_settings').unshift('./gui').unshift('.')

# requires
require 'reloadable_require'
multi_require 'sdl2', 'opengl', 'glu', 'pathname', 'optparse', 'syck'
include GL		# (we use GL methods in many places)
include GLU
multi_require 'boolean_accessor', 'method_piping', 'settings', 'vector3', 'easy_accessor', 'value_animation', 'value_animation_states', 'addons/dir', 'addons/array', 'addons/class', 'addons/dir', 'addons/exception', 'addons/fixnum', 'addons/float', 'addons/gl', 'addons/hash', 'addons/integer', 'addons/kernel', 'addons/module', 'addons/nil', 'addons/object', 'addons/object_space', 'addons/string'
multi_require 'constants', 'drawing', 'sdl_application', 'luz_performer', 'engine', 'pointer', 'pointer_mouse', 'gui_default'

# Settings file
settings_directory_path = File.join(Dir.home, SETTINGS_DIRECTORY_NAME)
FileUtils.mkdir_p(settings_directory_path) rescue Errno::EEXIST
settings_file_path = File.join(settings_directory_path, SETTINGS_FILENAME)
$settings = Settings.new.load(settings_file_path)
$settings['value-animation-time'] ||= GuiSettingsWindow::DEFAULT_VALUE_ANIMATION_TIME		# TODO: move elsewhere
$settings['gui-alpha'] ||= GuiSettingsWindow::DEFAULT_GUI_ALPHA
$settings['recent-projects'] ||= []

if ARGV.last.to_s.include?(Project::FILE_EXTENSION_WITH_DOT)
	project_path = ARGV.pop		# last argument is optional project name
end

# Create Application
$application = LuzPerformer.new(APP_NAME)
$application.parse_command_line_options
$application.init_video

# Create Luz Engine
$engine = Engine.new
$engine.post_initialize		# TODO: add message bus ip/port params
$engine.load_plugins

# Load Project
if project_path
	$engine.load_from_path(project_path)
else
	$engine.project.append_from_path(BASE_SET_PATH)
end

# Create GUI
create_gui = lambda { $gui = GuiDefault.new ; $gui.set_initial_state_from_project }
$engine.on_new_project(&create_gui)
create_gui.call

# Go!
begin
	$gui.positive_message("Welcome to #{APP_NAME}")
	$application.run
rescue Interrupt
ensure
	# ...done!
	$settings.save
	puts "\nThanks for playing with me! -Luz"
end
