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

require 'unique_timeout_callback'

class UserObjectSettingsEditor < Gtk::VBox
	callback :change

	SETTING_CHANGE_DELAY = 50			# in milliseconds

	def initialize
		super
		destroy
		show_all
		$engine.on_frame_end { on_frame_end }		# progressive gui creation
		$settings.on_change('live-editing') { obj = @object ; destroy ; @object = nil ; create_for(obj) }

		# Do change notification on a short timeout to avoid overload when the spinboxes fly!
		@change_notify_timeout = UniqueTimeoutCallback.new(SETTING_CHANGE_DELAY) { change_notify ; $engine.project_changed! }
	end

	def create_for(object)
		if object == @object
			# HACK: this prevents recreating the table when a single row is repeatedly selected and deselected.
			# This unfortunately seems to happen when using GTK type-ahead-find in a treeview.  See clear() below.
			@settings_table.visible = true
			return
		end

		destroy
		@object = object

		#
		# Progressive build (until build time can be improved)
		#
		@settings_to_add = @object.class.settings		# (settings will be added by callback)

		# Or do it immediately:
		#@object.class.settings.each { |setting| add_row(build_label(setting), build_widget(setting)) }
		#show_all
	end

	def on_frame_end
		# progressive gui creation
		return unless @settings_to_add and not @settings_to_add.empty?
		setting = @settings_to_add.shift
		add_setting(setting)
	end

	def add_setting(setting)
		add_row(build_label(setting), build_widget(setting))
	end

	def clear
		# Don't actually clear, just hide the contents in the hope that the same object will be drawn again.
		@settings_table.visible = false
	end

	def draw_update
		@draw_updateable_widgets.each { |w| w.draw_update }
	end

private

	def add_row(label, controls)
		realize		# NOTE: without this, when Luz is first started, the UOSEditor is screwed up upon first viewing the Themes tab (when the default theme is selected by default)

		@draw_updateable_widgets << controls if controls.respond_to? :draw_update

		if false		# TODO: let user choose this?
			# Horizontal layout, text on the left, controls on the right.
			index = @settings_table.add_row
			@settings_table.attach(label, 0, 1, index, index + 1, xopt = Gtk::FILL, yopt = Gtk::FILL)
			@settings_table.attach(controls, 1, 2, index, index + 1, xopt = Gtk::FILL|Gtk::EXPAND|Gtk::SHRINK, yopt = Gtk::FILL)
		else
			# Vertical layout, text on one row, controls on the next.
			index = @settings_table.add_row
			@settings_table.attach(label, 0, 2, index, index + 1, xopt = Gtk::FILL, yopt = Gtk::FILL)
			index = @settings_table.add_row
			@settings_table.attach(controls, 0, 2, index, index + 1, xopt = Gtk::FILL|Gtk::EXPAND|Gtk::SHRINK, yopt = Gtk::FILL)
		end
		@settings_table.show_all
	end

	def build_label(setting)
		markup = "<small>#{setting.name.humanize}:</small>"  # show that it breaks cache? .with_optional_pango_tag(setting.options[:breaks_cache], 'u')
		return Gtk::Label.new.set_alignment(0,0).set_markup(markup)
	end

	def build_widget(setting)
		# Create appropriate GTK widget(s) to manipulate this settings
		user_object_setting = @object.get_user_object_setting_by_name(setting.name)
		user_object_setting.on_change { @change_notify_timeout.set }

		if user_object_setting.widget_expands?
			user_object_setting.widget
		else
			Gtk::non_expanding(user_object_setting.widget)
		end
	end

	def destroy
		# The Gtk::Table to hold our settings, label on the left, option on the right
		remove(@settings_table) if @settings_table
		@draw_updateable_widgets = []
		@settings_table = Gtk::Table.new(rows=0, cols=2).set_row_spacings(8).set_column_spacings(8).set_border_width(4)
		add(@settings_table)
		@object = nil
	end
end
