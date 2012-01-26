 ###############################################################################
 #  Copyright 2009 Ian McIntosh <ian@openanswers.org>
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

require 'libglade2'

puts '*** Overriding buggy behavior of GladeXML#connect'
class GladeXML
	alias :connect_with_bug :connect
	def connect(source, target, signal, handler, data, after = false)
		guard_source_from_gc(source) if defined? guard_source_from_gc		# this method seems to be missing in debian
		connect_with_bug(source, target, signal, handler, data, after)
	end
end

require 'delegate'

# NOTE: expects GLADE_FILE_NAME to defined externally

class GladeWindow < DelegateClass(Gtk::Window)
	def initialize(root_widget_name = nil, options = {})
		options = {:glade_file_name => GLADE_FILE_NAME}.merge(options)

		root_widget_name ||= self.class.name.to_lowercase_underscored

		# Load the widgets below 'root_widget' and auto-hookup all the methods
		glade = GladeXML.new(options[:glade_file_name], root_widget_name, &method(:get_signal_handler))

		# create instance variables for each widget below us (except root widget, which is handled below)
		glade.widget_names.each { |name| instance_variable_set('@' + name, glade.get_widget(name)) unless name == root_widget_name }

		# In the class, we can refer to the GtkWindow as 'self', but we need an instance variable for delegation.

		@window = glade.get_widget(root_widget_name)
		throw "root widget not found '#{root_widget_name}'" unless @window

		@window.realize

		options = root_widget_name = glade = nil		# GARBAGE-HACK

		setup_default_signal_handlers

		@is_fullscreen = false		# TODO: remove this and instead test the state via GTK/GDK ?

		super(@window)		# ...as required by delegation
	end

	def setup_default_signal_handlers
		@window.signal_connect('delete_event') { self.on_delete_event }
	end

	def get_signal_handler(handler_name)
		# Create a new method to wrap the actual signal handler, with added exception handling
		# This prevents user actions from crashing the application.
		self.class.class_eval <<-end_class_eval
			def #{handler_name}_with_exception_handling(*args)
				begin
					if method(:#{handler_name}).arity == 0
						self.send(:#{handler_name})
					else
						self.send(:#{handler_name}, *args)
					end
				rescue Exception => e
					puts "Glade signal handler '#{handler_name}' caused exception:\n"
					puts e.report
				end
			end
		end_class_eval

		# return our new method
		method("#{handler_name}_with_exception_handling")
	end

	def on_delete_event
		hide 		# overrideable
	end

	def on_close_button_clicked
		hide
	end

	def on_cancel_button_clicked
		hide
	end
end
