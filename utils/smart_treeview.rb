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

class SmartTreeView < Gtk::TreeView
	Column = Struct.new(:name, :options)

	###################################################################
	# Class-level settings
	###################################################################
	def self.column(name, options={})
		options = {:title => ''}.merge(options)

		@columns ||= []
		@columns.append_or_replace(Column.new(name, options)) { |a, b| a.name == b.name }

		# Add accessor methods to class
		self.class_eval("def #{name}_column ; @#{name}_column ; end", __FILE__, __LINE__)
	end

	# Collects list of columns from superclasses
	def self.columns
		#(self == SmartTreeView ? [] : self.superclass.columns) + @columns
		existing = (self == SmartTreeView ? [] : self.superclass.columns.dup)

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
			return (self == SmartTreeView ? {} : self.superclass.options).merge(@options)
		end
	end

	###################################################################
	# Object-level functions
	###################################################################
	def initialize(options = {})
		super()

		# Merge default options, options from class definition, and options passed to constructor.
		# NOTE: later options take precidence.
		options = {:model_class => SmartListStore}.merge(self.class.options).merge(options)

		if options[:model]
			set_model(options[:model])
		else
			set_model(options[:model_class].new)
		end
		options.delete(:model_class)
		options.delete(:model)

		apply_options(options)
		create_columns(self.class.columns)

		show
	end

	def create_columns(columns)
		@renderers = {}
		columns.each { |column|
			column_options = {:position => :end, :renderers => []}.merge(column.options)

			new_column = Gtk::TreeViewColumn.new #(column.options[:title])
			instance_variable_set("@#{column.name}_column", new_column)
			column_options[:renderers].each { |renderer_options|
				renderer_options = {:expand => true}.merge(renderer_options)

				# Create new cell renderer
				case renderer_options[:type]
				when :text
					new_renderer = Gtk::CellRendererText.new
					new_column.pack_start(new_renderer, renderer_options[:expand])
					new_column.add_attribute(new_renderer, :text, find_model_column_index(renderer_options[:model_column]))
					add_edited_callback(new_renderer, renderer_options[:on_edited])

				when :markup
					new_renderer = Gtk::CellRendererText.new
					new_column.pack_start(new_renderer, renderer_options[:expand])
					new_column.add_attribute(new_renderer, :markup, find_model_column_index(renderer_options[:model_column]))
					add_edited_callback(new_renderer, renderer_options[:on_edited])

				when :toggle
					new_renderer = Gtk::CellRendererToggle.new
					new_column.pack_start(new_renderer, renderer_options[:expand])

					# Toggle renderer uses two model columns: 'active' and 'inconsistent'
					#  1) "active" simply means checked
					new_column.add_attribute(new_renderer, :active, find_model_column_index(renderer_options[:model_column]))

					#  2) "inconsistent" (optional) is most often used when the checkbox represents the state of multiple objects
					if c = renderer_options[:model_column_inconsistent]
						new_column.add_attribute(new_renderer, :inconsistent, find_model_column_index(c))
						renderer_options.delete(:model_column_inconsistent)
					end

					# Report toggling of checkbox to parent
					add_toggled_callback(new_renderer, renderer_options[:on_toggled])
					renderer_options.delete(:on_toggled)

				when :progress
					new_renderer = Gtk::CellRendererProgress.new
					new_column.pack_start(new_renderer, renderer_options[:expand])
					new_column.add_attribute(new_renderer, :value, find_model_column_index(renderer_options[:model_column]))

				when :pixbuf
					new_renderer = Gtk::CellRendererPixbuf.new
					new_column.pack_start(new_renderer, renderer_options[:expand])
					new_column.add_attribute(new_renderer, :pixbuf, find_model_column_index(renderer_options[:model_column]))

				else throw 'unhandled renderer type'
				end
				renderer_options.delete(:type)
				renderer_options.delete(:expand)
				renderer_options.delete(:model_column)

				# Make it accessible, if it has a name
				if name = renderer_options.delete(:name)
					@renderers[name] = new_renderer
					self.class.module_eval("def #{name}_renderer ; @renderers[:#{name}] ; end", __FILE__, __LINE__)
				end

				renderer_options[:options].each { |key, value|
					new_renderer.send(key.to_s + '=', value)
				} if renderer_options[:options]
				renderer_options.delete(:options)

				# Assume remaining key=>value pairs are cell renderer options
				renderer_options.each { |key, value|
					new_column.add_attribute(new_renderer, key, value)
				}
			}
			column_options.delete(:type)
			column_options.delete(:renderers)

			position = column_options[:position]
			column_options.delete(:position)

			# Assume remaining key=>value pairs are column options
			column_options.each { |key, value|
				new_column.send(key.to_s + '=', value)
			}

			# Add column to tree
			case position
			when :start then insert_column(new_column, 0)
			when :end then append_column(new_column)
			when Integer then insert_column(new_column, position)
			else
				throw "unknown position value '#{position}'"
			end
		}
	end

	def add_toggled_callback(renderer, cb)
		# GARBAGE-HACK: out of create_columns() context.
		renderer.on_toggled { |path| easy_call(cb, model.get_iter(path)) } unless cb.nil?
	end

	def add_edited_callback(renderer, cb)
		# GARBAGE-HACK: out of create_columns() context.
		renderer.on_edited { |path, value| easy_call(cb, model.get_iter(path), value) } unless cb.nil?
	end

	def apply_options(options)
		options.each { |key, value|
			self.send(key.to_s + '=', value)
		}
	end

	def unselect_all
		selection.unselect_all
	end

	def select(iter)
		selection.select_iter(iter)
	end

private

	def find_model_column_index(name)
		model.class.columns.each_with_index { |column, index| return index if column.name == name }
		throw "SmartTreeView column set to use unknown model column \"#{name}\" columns are (#{model.class.columns.map {|column| column.name}.join(', ')})"
	end
end
