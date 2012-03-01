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

require 'delegate'

class GladeWindow < DelegateClass(Gtk::Window)

	MOUSE_BUTTON_1, MOUSE_BUTTON_2, MOUSE_BUTTON_3 = (1..3).to_a

	def initialize(root_widget_name = nil, options = {})
		file_name = sprintf("gui/%s.ui", root_widget_name) 
		instance_variable_names = options[:widgets] || []	

		@builder = Gtk::Builder.new.add_from_file(file_name)

		# create instance variables out of created widgets
		instance_variable_names.each { |name|
			instance_variable_set('@' + name.to_s, @builder.get_object(name.to_s))
		}

		# hookup signal handlers
		@builder.connect_signals { |handler_name|
			method(handler_name)
		}

		# in the class, we will refer to the GtkWindow as @window when referencing variables	
		@window = @builder.get_object(root_widget_name)
		@window.realize

		#options = root_widget_name = glade = nil		# GARBAGE-HACK

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
