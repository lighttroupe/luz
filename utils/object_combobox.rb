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

require 'smart_combobox', 'object_liststore'

class ObjectComboBox < SmartComboBox
	options :model_class => ObjectListStore

	def active_object
		return nil unless active_iter
		return model.get_object_column(active_iter)
	end

	def first_object
		return nil unless model.iter_first
		return model.get_object_column(model.iter_first)
	end

	def set_active_object(object)
		each_iter { |iter|
			if model.get_object_column(iter) == object
				self.active_iter = iter
				break
			end
		}
		return self
	end
end
