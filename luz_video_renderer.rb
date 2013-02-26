#!/usr/bin/env ruby

 ###############################################################################
 #  Copyright 2012 Ian McIntosh <ian@openanswers.org>
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
$LOAD_PATH.unshift('./utils').unshift('./gui-gtk').unshift('.')

DEFAULT_GTK_RC_FILE = 'luz.rc'

require 'constants'
require 'gtk2'
require 'reloadable_require'
require 'addons_ruby'
load_directory(Dir.pwd + '/utils/addons/', '**.rb')
require 'exception_addons'

Gtk.init
Gtk::RC.parse(DEFAULT_GTK_RC_FILE)

require 'settings'
settings_path = File.join(Dir.home, SETTINGS_DIRECTORY, SETTINGS_FILENAME)
$settings = Settings.new.load(settings_path)

require 'render_window'
$render_window = RenderWindow.new

require 'optparse'
options = OptionParser.new do |opts|
	opts.banner = "Usage: luz_video_renderer.rb [options]"

	opts.on("--project <project.luz>", String, "a Luz project") do |project|
		$render_window.project = project
	end
end
options.parse!

$render_window.show

Gtk.main
