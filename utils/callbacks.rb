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

					def on_#{name}_with_init(&proc)
						@#{name}_handlers ||= []
						@#{name}_handlers << proc
						proc.call
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
