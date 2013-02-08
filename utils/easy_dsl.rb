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

# Mixin: EasyDSL simplifies creating Domain Specific Languages.

# Provides class-level methods for defining other class-level methods.
require 'set'

module EasyDSL
	def self.included(base) #:nodoc:
		base.extend(ClassMethods)
	end

	###################################################################
	# Class-level methods
	###################################################################

	module ClassMethods
		def dsl_string(*names)
			names.to_a.each { |name|
				self.class_eval <<-end_class_eval
					def self.#{name}(value = nil)
						@#{name} = value if value
						return @#{name} || ''
					end
				end_class_eval
			}
		end

		def dsl_flag(*names)
			names.to_a.each { |name|
				self.class_eval <<-end_class_eval
					def self.#{name}(rhs = true)
						@#{name} = rhs
					end
					def self.#{name}?
						@#{name} || false
					end
				end_class_eval
			}
		end

		def dsl_set(singular, plural)
			self.class_eval <<-end_class_eval
				def self.#{singular}(value)
					@#{plural} ||= Set.new	# NOTE: singular form adds to set
					@#{plural} << value
					@#{plural}
				end

				def self.#{plural}(*values)
					@#{plural} = Set.new		# NOTE: plural form clears existing values
					if values
						values.each { |v|
							@#{plural} << v
						}
					end
					@#{plural}
				end

				def self.in_#{singular}?(value)
					(@#{plural} && @#{plural}.include?(value))
				end
			end_class_eval
		end
	end
end
