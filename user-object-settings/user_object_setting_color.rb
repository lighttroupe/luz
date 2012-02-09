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

require 'user_object_setting'

class UserObjectSettingColor < UserObjectSetting
	DEFAULT_COLOR = [1.0,1.0,1.0,1.0]

	attr_accessor :color		# for setting it (usually temporarily for yielding with the color set)

	def to_yaml_properties
		['@color'] + super
	end

	def after_load
		#throw 'color array must contain 3 or 4 Floats from 0.0 to 1.0' if @options[:default] and not (color[0].is_a?(Float) and color[1].is_a?(Float) and color[2].is_a?(Float) and (color[3].nil? or color[3].is_a?(Float))

		color = (@options[:default] || DEFAULT_COLOR)

		@use_alpha = (color.size == 4)		# "cleverly" determine whether to use alpha based on the default value set
		set_default_instance_variables(:color => Color.new.set(color), :type => :literal)
		super
	end

	def widget
		colorselection = Gtk::ColorSelection.new
		colorselection.has_opacity_control = @use_alpha
		colorselection.has_palette = false
		colorselection.current_alpha = @color.gdk_alpha
		colorselection.previous_alpha = @color.gdk_alpha
		colorselection.current_color = @color.gdk_color
		colorselection.previous_color = @color.gdk_color

		# not supported in ruby-gnome2?
		#colorselection.set_update_policy(Gtk::UPDATE_DISCONTINUOUS)
		#...nor... colorselection.set_property('update-policy', Gtk::UPDATE_DISCONTINUOUS)

		colorselection.signal_connect('color-changed') { @color.gl_color = colorselection.gl_color ; change_notify }
		return colorselection
	end

	def immediate_value
		@color
	end
end
