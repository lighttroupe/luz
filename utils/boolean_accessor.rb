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

# Example Usage:
#
#		class Example
#			boolean_accessor :is_understood		# starts false
#
#			def initialize
#				is_understood!
#			end

class Module
	def boolean_accessor(*signals)
		signals.each { |signal|
			module_eval( "def #{signal}() @#{signal} == true ; end", __FILE__, __LINE__ )
			module_eval( "def #{signal}?() @#{signal} == true ; end", __FILE__, __LINE__ )
			module_eval( "def is_#{signal}?() @#{signal} == true ; end", __FILE__, __LINE__ )
			module_eval( "def #{signal}=(value) @#{signal} = value ; end", __FILE__, __LINE__ )

			# Chainable (return self)
			module_eval( "def set_#{signal}(value) @#{signal} = value ; self ; end", __FILE__, __LINE__ )
			module_eval( "def toggle_#{signal}() self.#{signal} = !self.#{signal}? ; self ;end", __FILE__, __LINE__ )
			module_eval( "def toggle_#{signal}!() self.#{signal} = !self.#{signal}? ; self ; end", __FILE__, __LINE__ )
			module_eval( "def #{signal}!() self.#{signal} = true ; self ; end", __FILE__, __LINE__ )
			module_eval( "def not_#{signal}!() self.#{signal} = false ; self ; end", __FILE__, __LINE__ )
		}
	end
end
