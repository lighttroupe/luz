###############################################################################
#  Copyright 2007 Ian McIntosh <ian@openanswers.org>
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

# Mixin: Callbacks.

module Callbacks
	def self.included(base) #:nodoc:
		base.extend(ClassMethods)
	end

	###################################################################
	# Class-level methods
	###################################################################

	module ClassMethods
		def callback(*names)
			names.to_a.each { |name|
				self.class_eval <<-end_class_eval
					def on_#{name}(&proc)
						@#{name}_handlers ||= []
						@#{name}_handlers << proc
					end

					def #{name}_notify(*args)
						@#{name}_handlers.each { |handler| handler.call(*args) } if @#{name}_handlers
					end
				end_class_eval
			}
		end

		def unique_callback(*names)
			names.to_a.each { |name|
				self.class_eval <<-end_class_eval
					def on_#{name}(&proc)
						@#{name}_handler = proc
					end

					def #{name}_notify(*args)
						@#{name}_handler.call(*args) if @#{name}_handler
					end
				end_class_eval
			}
		end
	end
end
