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

require 'glade_window'

RESOLUTION_OPTIONS = [
	'(current desktop resolution)',
	'320x240 (4:3)',
	'640x480 (4:3)',
	'800x600 (4:3)',
	'1024x768 (4:3)',
	'1280x720 (16:9)',
	'1440x900 (8:5)',
	'1600x1200 (4:3)',
	'1920x1080 (16:9)',
	'2048x1152 (16:9)'
]

class PreferencesWindow < GladeWindow
	def initialize
		super

		on_key_press(Gdk::Keyval::GDK_Escape) { hide }

		#
		# EDITOR TAB
		#

		# Editor FPS
		$settings['editor-fps'] ||= 30
		@editor_fps_spinbutton.value = $settings['editor-fps'].to_i
		@editor_fps_spinbutton.on_change { $settings['editor-fps'] = @editor_fps_spinbutton.value.to_i }

		$settings['project-directory'] ||= (GLib.get_user_special_dir(GLib::USER_DIRECTORY_DOCUMENTS) || GLib.home_dir || '')
		@project_directory_filechooserbutton.current_folder = $settings['project-directory']
		@project_directory_filechooserbutton.on_change { $settings['project-directory'] = @project_directory_filechooserbutton.current_folder }

		# Hints
		$settings['enable-hints'] = true unless $settings['enable-hints'] === false
		@enable_hints_checkbutton.active = $settings['enable-hints']
		@enable_hints_checkbutton.on_change { $settings['enable-hints'] = @enable_hints_checkbutton.active? }

		# Snap to Grid
		$settings['snap-to-grid'] = true unless $settings['snap-to-grid'] === false
		@enable_snap_to_grid_checkbutton.active = $settings['snap-to-grid']
		@enable_snap_to_grid_checkbutton.on_change { $settings['snap-to-grid'] = @enable_snap_to_grid_checkbutton.active? }

		# Live Editing
		$settings['live-editing'] = false unless $settings['live-editing'] === true
		@enable_live_editing_checkbutton.active = $settings['live-editing']
		@enable_live_editing_checkbutton.on_change { $settings['live-editing'] = @enable_live_editing_checkbutton.active? }

		#
		# PERFORMER TAB
		#

		# Performer FPS
		$settings['performer-fps'] ||= 30
		@performer_fps_spinbutton.value = $settings['performer-fps'].to_i
		@performer_fps_spinbutton.on_change { $settings['performer-fps'] = @performer_fps_spinbutton.value.to_i }

		# Performer Resolution
		RESOLUTION_OPTIONS.each { |text| @resolution_combobox.append_text(text) }
		@resolution_combobox.on_change { $settings['performer-resolution'] = @resolution_combobox.active_text }
		@resolution_combobox.active = (RESOLUTION_OPTIONS.index($settings['performer-resolution']) || 0)
	end
end
