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

class UserObjectSettingFont < UserObjectSetting
	def to_yaml_properties
		['@font'] + super
	end

	def widget
		font_button = Gtk::FontButton.new(@font ? "#{@font} 16" : nil)
		font_button.set_show_size(false)

		font_button.signal_connect('font-set') {
			name = font_button.font_name.strip

			# remove font size
			name = name.gsub(/ \d*$/, '')

			# remove odd useless appendages
			name = name.without_suffix(' Normal')

			set(:font, name)
		}
		return font_button
	end

	def immediate_value
		@font
	end
end
