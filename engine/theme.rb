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

require 'parent_user_object', 'taggable', 'style'

class Theme < ParentUserObject
	title 'Theme'

	include Taggable

	def to_yaml_properties
		tag_instance_variables + super
	end

	setting 'background_color', :color, :default => [0.0,0.0,0.0,1.0], :only_literal => true

	def default_title
		'New Theme'
	end

	def after_load
		#set_default_instance_variables(:titile => '')
		super
		after_load_tag_class_registration
	end

	def before_delete
		clear_tags
		super
	end

	def empty?
		effects.empty?
	end

	def style(index)
		effects[index % effects.size]
	end

	def using_style(index)
		return yield if effects.empty?
		style(index).using { yield }
	end

	def using_style_amount(index, amount)
		return yield if (amount == 0.0 or effects.empty?)
		effects[index % effects.size].using_amount(amount) { yield }
	end
end
