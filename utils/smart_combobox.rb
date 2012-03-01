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

require 'smart_liststore'

class SmartComboBox < Gtk::ComboBox
	Column = Struct.new(:name, :options)

	###################################################################
	# Class-level settings
	###################################################################
	def self.column(name, options={})
		options = {:title => ''}.merge(options)

		@columns ||= []
		@columns.append_or_replace(Column.new(name, options)) { |a, b| a.name == b.name } # ; a.options.merge!(b.options) ; true ; else ; false ; end }

		# Add accessor methods to class
		#self.class_eval("def #{name}_column ; @#{name}_column ; end", __FILE__, __LINE__)
	end

	# Collects list of columns from superclasses
	def self.columns
		#(self == SmartComboBox ? [] : self.superclass.columns) + @columns

		existing = (self == SmartComboBox ? [] : self.superclass.columns.dup)

		# Our columns override those of superclasses
		(@columns || []).each { |column| existing.append_or_replace(column) { |a, b| a.name == b.name }}
		return existing
	end

	def self.options(options=nil)
		@options ||= {}
		if options.is_a? Hash
			# If called with a hash (in a class definition), save it.
			@options = @options.merge(options)
		else
			# If called without, return options from self and superclasses, merged with later classes taking precidence.
			return (self == SmartComboBox ? {} : self.superclass.options).merge(@options)
		end
	end

	###################################################################
	# Object-level functions
	###################################################################
	def initialize(options = {})
		super(text_only = false)

		# Merge default options, options from class definition, and options passed to constructor.
		# NOTE: later options take precidence.
		options = {:model_class => SmartListStore}.merge(self.class.options).merge(options)

		set_model(options[:model] || options[:model_class].new)
		options.delete(:model_class)
		options.delete(:model)

		apply_options(options)
		create_columns(self.class.columns)

		show
	end

	def create_columns(columns)
		columns.each { |column|
			column_options = {:expand => true}.merge(column.options)

			# Create new cell renderer
			case column_options[:type]
			when :text
				new_renderer = Gtk::CellRendererText.new
				pack_start(new_renderer, column_options[:expand])
				add_attribute(new_renderer, :text, find_model_column_index(column_options[:model_column]))
			when :markup
				new_renderer = Gtk::CellRendererText.new
				pack_start(new_renderer, column_options[:expand])
				add_attribute(new_renderer, :markup, find_model_column_index(column_options[:model_column]))
			when :pixbuf
				new_renderer = Gtk::CellRendererPixbuf.new
				pack_start(new_renderer, column_options[:expand])
				add_attribute(new_renderer, :pixbuf, find_model_column_index(column_options[:model_column]))
			else
				throw "unhandled renderer type '#{column_options[:type]}'"
			end

			instance_variable_set("@#{column.name}_column_renderer", new_renderer)

			#column_options.delete(:type)
			#column_options.delete(:expand)
			#column_options.delete(:model_column)

			# Assume remaining key=>value pairs are cell renderer options
			#column_options.each { |key, value|
				#puts "attribute: #{key} => #{value}"
				#add_attribute(new_renderer, key, value)
			#}
		}
	end

	def apply_options(options)
		options.each { |key, value|
			self.send(key.to_s + '=', value)
		}
	end

#	def select(iter)
#		selection.select_iter(iter)
#	end

private

	def find_model_column_index(name)
		model.class.columns.each_with_index { |column, index| return index if column.name == name }
		throw "SmartComboBox column set to use unknown model column \"#{name}\""
	end
end
