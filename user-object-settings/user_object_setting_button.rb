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

require 'user_object_setting'	#, 'variable_combobox'

class UserObjectSettingButton < UserObjectSetting
	def to_yaml_properties
		['@button'] + super
	end

	LABEL_NORMAL = 'Record '
	LABEL_RECORDING = 'Recording - press desired button'

	def widget
		combobox = create_button_name_combobox(:button)

		record_button = Gtk::Button.new.set_label(LABEL_NORMAL).set_image(Gtk::Image.new(Gtk::Stock::MEDIA_RECORD, Gtk::IconSize::BUTTON))
		record_button.signal_connect('clicked') {
			# Change button appearance
			record_button.set_label(LABEL_RECORDING)

			$engine.button_grab { |button|
				@button = button

				# Show new button
				combobox.set_active_object(@button)

				# Restore normal label
				record_button.set_label(LABEL_NORMAL)
			}
		}
		return Gtk.hbox_for_widgets([combobox, record_button])
	end

	def immediate_value
		@button
	end

	def summary
		summary_format(@button)
	end
end
