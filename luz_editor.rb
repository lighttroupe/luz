#!/usr/bin/env ruby

 ###############################################################################
 #  Copyright 2011 Ian McIntosh <ian@openanswers.org>
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

Dir.chdir(File.dirname(__FILE__))	# So that this file can be run from anywhere
$LOAD_PATH << './utils'
$LOAD_PATH << './user-object-settings'
$LOAD_PATH << './gui'
$LOAD_PATH << './engine'

###################################################################
# Constants
###################################################################
APP_NAME			= 'Luz Studio'
APP_COPYRIGHT	= "Copyright (c) #{Time.now.year} Ian McIntosh"
APP_VERSION		= 0.91

DEFAULT_GTK_RC_FILE = 'luz.rc'

require 'reloadable_require'		# NOTE: also adds the ability to require multiple files at once
require 'addons_ruby', 'method_piping', 'boolean_accessor'

# Application basics
require 'constants', 'application', 'settings'

# Extensions to GUI related objects
require 'gtk2', 'gtkglext'

load_directory(Dir.pwd + '/utils/addons/', '**.rb')

require 'addons_gl'

class LuzEditor < Application
	attr_reader :width, :height

	def initialize
		super

		GC.disable

		Gtk.init
		Gtk::RC.parse(DEFAULT_GTK_RC_FILE)
		Gtk::GL.init

		require 'error_window'
		@error_window = ErrorWindow.new

		require 'engine'
		$engine = Engine.new
		$engine.post_initialize

		require 'gui'
		$gui = GUI.new
		$gui.create_treeview_models
		$gui.create_windows		# Remove this, create windows separately

		@width, @height = $gui.window_width, $gui.window_height

		$engine.load_plugins
		$engine.add_default_objects

		$engine.on_user_object_exception { |obj,e| on_user_object_exception(obj,e) }

		@frames_per_second = $settings['editor-fps']
		@animating = true

		GC.enable
	end

	def end_animation
		@animating = false
	end

	#
	# application-level exception handling
	#
	def on_user_object_exception(object, exception)
		puts sprintf(Engine::USER_OBJECT_EXCEPTION_FORMAT, exception.report_format, "#{object.class}:#{object.title}")
	end

	def handle_exception(e)
		# Report in GUI
		@error_window.show_with_message(e.report_format)

		# Report in control terminal
		e.report("exception requiring user notification")

		# Stop processing frames, etc., just remain with a basic GUI
		end_animation
		$engine.crash_notify
	end

	empty_method :get_framebuffer_rgb
end

require 'optparse'

options = {}
OptionParser.new do |opts|
	opts.banner = "Usage: luz_editor.rb [project.luz]"
end.parse!

project = ARGV.last

GLADE_FILE_NAME = 'luz_editor.glade'
settings_path = File.join(Dir.home, SETTINGS_DIRECTORY, SETTINGS_FILENAME)
$settings = Settings.new.load(settings_path)
$application = LuzEditor.new
Gtk.main_clear_queue	# Give GUI a chance to draw before loading project
$engine.load_from_path(project) if (project and File.extname(project) == '.luz')
$application.run
$settings.save(settings_path)
