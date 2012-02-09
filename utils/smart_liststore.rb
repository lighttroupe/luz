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

class SmartListStore < Gtk::ListStore
	Column = Struct.new(:name, :options)

	###################################################################
	# Class-level settings
	###################################################################
	def self.column(name, options)
		throw "expecting symbol instead of \"#{name.inspect}\"" unless name.is_a? Symbol
		throw "expecting hash instead of \"#{options.inspect}\"" unless options.is_a? Hash

		@columns ||= []
		@columns.append_or_replace(Column.new(name, options)) { |obj, new| obj.name == new.name }
	end

	# Collects list of columns from superclasses
	def self.columns
		@columns ||= []
		existing = (self == SmartListStore ? [] : self.superclass.columns)
		@columns.each { |column| existing.append_or_replace(column) { |obj, new| obj.name == new.name }}
		return existing
	end

	###################################################################
	# Object-level functions
	###################################################################
	def initialize
		# Create model based on columns declared by superclasses
		columns = self.class.columns
		throw 'SmartListStore instanciated without any columns' if columns.empty?

		columns.each_with_index { |column, index|
			# Add accessor methods to class
			self.class.class_eval("def self.#{column.name}_column_index ; #{index} ; end", __FILE__, __LINE__)
			self.class.class_eval("def get_#{column.name}_column(iter) ; iter.get_value(#{index}) ; end", __FILE__, __LINE__)
			self.class.class_eval("def set_#{column.name}_column(iter, value) ; iter.set_value(#{index}, value) ; self ; end", __FILE__, __LINE__)
		}

		# Create the actual model by passing list of classes to Gtk::ListStore
		super(*columns.collect { |column| type_to_class(column.options[:type]) } )
	end
	
	def type_to_class(type)
		case type
		when :text then String
		when :integer then Integer
		when :pixbuf then Gdk::Pixbuf
		else
			throw "unknown SmartListStore column type \"#{type}\"" if type.is_a? Symbol
			type		# just return 'type', which can be a class
		end
	end
end
