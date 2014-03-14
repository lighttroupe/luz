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

require 'user_object_setting' #, 'variable_combobox'

class UserObjectSettingVariable < UserObjectSetting
	def to_yaml_properties
		['@variable'] + super
	end

	def immediate_value
		(@variable) ? @variable.do_value : 0.0		# NOTE: important that we ask the variable (not the engine), in case it hasn't been updated yet this frame
	end

	def last_value
		(@variable) ? @variable.last_value : 0.0		# NOTE: important that we ask the variable (not the engine), in case it hasn't been updated yet this frame
	end

	def variable
		@variable
	end

	def with_value(value, &proc)
		return yield unless @variable
		@variable.with_value(value, &proc)
	end

	def summary
		summary_format(@variable.title) if @variable
	end
end
