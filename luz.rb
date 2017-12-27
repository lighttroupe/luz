#!/usr/bin/env ruby

Dir.chdir(File.dirname(__FILE__))		# (so this file can be run from anywhere)

######################################################################################
# Copyright 2015 Ian McIntosh <ian@openanswers.org> released under the GPL version 2 #
######################################################################################

if RUBY_VERSION[0] != '2'
	puts "For Speed and Smoooth Flow, choose Ruby 2 (you are using #{RUBY_VERSION})"
	exit
else
	puts "Using Ruby #{RUBY_VERSION}"
end

APP_NAME = 'Luz 2.0'
BASE_SET_PATH = 'base.luz'

# Add directories to load path
$LOAD_PATH.unshift('./utils').unshift('./engine').unshift('./engine/user_object_settings').unshift('./gui').unshift('.')

require 'reloadable_require'

# SDL2, OpenGL, system utils
multi_require 'sdl2', 'opengl', 'glu', 'pathname', 'optparse', 'syck'

include GL
include GLU

# Luz addons
multi_require 'boolean_accessor', 'method_piping', 'vector3', 'easy_accessor', 'value_animation', 'value_animation_states', 'addons/dir', 'addons/array', 'addons/class', 'addons/dir', 'addons/exception', 'addons/fixnum', 'addons/float', 'addons/gl', 'addons/hash', 'addons/integer', 'addons/kernel', 'addons/module', 'addons/nil', 'addons/object', 'addons/object_space', 'addons/string'

# Luz engine
multi_require 'constants', 'drawing', 'sdl_application', 'luz_performer', 'engine', 'settings', 'pointer', 'pointer_mouse', 'gui_default'

# Settings directory
settings_directory_path = File.join(Dir.home, SETTINGS_DIRECTORY_NAME)
FileUtils.mkdir_p(settings_directory_path) rescue Errno::EEXIST

# Settings file
settings_file_path = File.join(settings_directory_path, SETTINGS_FILENAME)
$settings = Settings.new.load(settings_file_path)
$settings['value-animation-time'] ||= GuiSettingsWindow::DEFAULT_VALUE_ANIMATION_TIME		# TODO: move elsewhere
$settings['gui-alpha'] ||= GuiSettingsWindow::DEFAULT_GUI_ALPHA
$settings['recent-projects'] ||= []

# Create Application
$application = LuzPerformer.new(APP_NAME)
$application.create

# Create Luz Engine
$engine = Engine.new
$engine.post_initialize		# TODO: add message bus ip/port params
$engine.load_plugins

# Load Project
project_path = ARGV.pop		# last argument is optional project name
if project_path
	$engine.load_from_path(project_path)
else
	$engine.project.append_from_path(BASE_SET_PATH)
end

# Build GUI
$gui = GuiDefault.new
$gui.set_initial_state_from_project

# ...replace GUI when project changes
$engine.on_new_project { $gui = GuiDefault.new ; $gui.set_initial_state_from_project }

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
