class Module
	def easy_accessor(*signals)
		signals.each { |signal|
			module_eval( "def #{signal}=(value) @#{signal} = value ; end", __FILE__, __LINE__ )
			module_eval( "def set_#{signal}(value) @#{signal} = value ; self ; end", __FILE__, __LINE__ )
		}
	end
end
