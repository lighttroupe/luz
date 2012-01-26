class Module
	# Creates methods to get/set/
	def boolean_accessor(*signals)
		signals.each { |signal|
			module_eval( "def #{signal}?() @#{signal} == true ; end", __FILE__, __LINE__ )
			module_eval( "def is_#{signal}?() @#{signal} == true ; end", __FILE__, __LINE__ )
			module_eval( "def #{signal}=(value) @#{signal} = value ; end", __FILE__, __LINE__ )
			module_eval( "def set_#{signal}(value) @#{signal} = value ; self ; end", __FILE__, __LINE__ )
			module_eval( "def toggle_#{signal}() self.#{signal} = !self.#{signal}? ; self ;end", __FILE__, __LINE__ )
			module_eval( "def toggle_#{signal}!() self.#{signal} = !self.#{signal}? ; self ; end", __FILE__, __LINE__ )
			module_eval( "def #{signal}!() self.#{signal} = true ; self ; end", __FILE__, __LINE__ )
			module_eval( "def not_#{signal}!() self.#{signal} = false ; self ; end", __FILE__, __LINE__ )
		}
	end
end
