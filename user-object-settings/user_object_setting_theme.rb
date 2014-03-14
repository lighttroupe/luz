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

require 'user_object_setting'	#,'theme_combobox'

class UserObjectSettingTheme < UserObjectSetting

	def to_yaml_properties
		['@theme'] + super
	end

	def after_load
		@theme ||= $engine.project.themes.first
		super
	end

	# enter and exit times are in engine-time (seconds, float)
	def immediate_value
		@theme
	end

	def summary
		summary_format(@theme.title) if @theme
	end
end

