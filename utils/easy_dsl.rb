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
