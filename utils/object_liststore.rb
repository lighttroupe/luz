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

require 'smart_liststore'

class ObjectListStore < SmartListStore
	column :object, :type => Object

	def add(objects)
		iter = nil 		# NOTE: This lets us see last value after the each() block runs
		objects.to_a.each { |object| iter = append ; set_object_column(iter, object) ; set_columns_from_object(iter) }
		return iter
	end
	alias :add_objects :add

	def set_objects(objects)
		clear
		add(objects)
	end

	def delete(object)
		iter = find(object)
		remove(iter) if iter
	end

	def delete_objects(objects)
		objects.each { |obj| delete(obj) }
	end

	def find(object)
		each_iter { |iter| return iter if get_object_column(iter) == object }
		return nil
	end

	def objects
		list = []
		each_iter { |iter| list << get_object_column(iter) }		# removed: unless object.nil?
		return list
	end

	def set_columns_from_object(iter)
		object = get_object_column(iter)

		# can't fill from nothing
		return unless object

		# Superclsses define a proc for extracting the appropriate value for this model column from the object (or some other source)
		self.class.columns.each { |column|
			next if column.name == :object

			if column.options[:from_object]
				# Call user-callback to extract value from the object
				self.send("set_#{column.name}_column", iter, easy_call(column.options[:from_object], object))
			else
				throw "model column \"#{column.name}\" missing :from_object proc"
			end
		}
	end

	def add_or_update_object(obj)
		if iter = find(obj)
			# Update
			set_columns_from_object(iter)
		else
			# Add
			iter = add(obj)
		end
		return iter
	end
end
