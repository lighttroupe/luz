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

require 'user_object_setting'

class UserObjectSettingString < UserObjectSetting
	attr_accessor :string

	def to_yaml_properties
		['@string'] + super
	end

	def widget
		@string ||= ''

		if @options[:multiline]
			entry = Gtk::TextView.new
			entry.text = @string
			entry.set_size_request(300, 120)
		else
			entry = Gtk::Entry.new
			entry.set_width_chars(40)
			entry.text = @string
		end

		entry_box_widgets = [entry]

		if @options[:file_edit]
			entry.on_change { set(:string, entry.text) }

		else
			# A label to show current length (in characters)
			size_label = Gtk::Label.new(label_text_for_string(@string))
			size_label.set_xalign(1.0)
			size_label.use_markup = true

			# Connect size label with entry
			entry.on_change { set(:string, entry.text) ; size_label.markup = label_text_for_string(@string) }

			entry_box_widgets << size_label
		end

		# Package them together
		entry_box = Gtk.vbox_for_widgets(entry_box_widgets)

		# Add them to final output box
		hbox = [entry_box]

		# Add an edit button?
		if @options[:file_edit]
			edit_button = create_edit_button
			edit_button.signal_connect('clicked') {
				$gui.safe_open_file(File.join($engine.project.file_path, entry.text))
			}
			hbox << edit_button
		end

		return Gtk.hbox_for_widgets(hbox)
	end

	def label_text_for_string(str)
		sprintf("<small>%d character(s)</small>", str.size)
	end

	def summary
		summary_format(@string) if @string
	end

	def immediate_value
		@string || ''
	end
end

