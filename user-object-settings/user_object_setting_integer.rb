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

require 'user_object_setting_numeric'

class UserObjectSettingInteger < UserObjectSettingNumeric
	ANIMATION_REPEAT_NUMBER_RANGE = ENTER_REPEAT_NUMBER_RANGE = EXIT_REPEAT_NUMBER_RANGE = 0.1..999
	ANIMATION_STEP_NUMBER_RANGE = 1..999
	ANIMATION_TYPE_OPTIONS = [[:none, 'No Animation'], [:repeat, 'One-way'], [:reverse, 'Ping-pong']]

	attr_accessor :animation_min, :animation_type, :animation_max, :animation_step, :animation_repeat_number, :animation_repeat_unit

	def to_yaml_properties
		super + ['@animation_min']
	end

	def after_load
		@options[:default] = (@options[:default] or @options[:range] or 1..2)

		set_default_instance_variables(:animation_min => @options[:default].first, :animation_step => 1, :animation_type => :none)
		super
	end

	def widget
		create_spinbutton(:animation_min, @options[:range], 1, 10, 0)
	end

	def immediate_value
		@last_value = @animation_min
	end

	def summary
		summary_format(@animation_min.to_s)
	end
end
