class Module
	# Lets an object quickly create many empty methods
	def empty_method(*signals)
		signals.each { |signal| module_eval( "def #{signal}(*args, &proc) ; end", __FILE__, __LINE__) }
	end

	def attr_reader(*signals)
		# Like the original, but also adds 'signal?'
		signals.each { |signal|
			module_eval( "def #{signal} ; @#{signal} ; end", __FILE__, __LINE__)
			module_eval( "def #{signal}? ; @#{signal} ; end", __FILE__, __LINE__)
		}
	end

	def attr_accessor(*signals)
		# Add custom readers
		attr_reader(*signals)

		# Add custom writers
		signals.each { |signal|
			module_eval( "def #{signal}=(value) @#{signal} = value ; end", __FILE__, __LINE__)
			module_eval( "def set_#{signal}(value) self.#{signal} = value ; return self ; end", __FILE__, __LINE__)
		}
	end
end
