#
# easy_accessor :background_color, :default => []
#
# like attr_accessor but with default values (cached so as to not generate garbage with each call, for complex defaults like rgb colors)
#
# also adds eg. set_background_color(...) method which is chainable.
#
class Module
	def easy_accessor(*signals)
		# easy_accessor :value, :default => 0.5
		if signals.size == 2 && (options = signals.last).is_a?(Hash)
			signal = signals.first
			default = options[:default]
			#puts "def #{signal}() ; @#{signal} || (@#{signal}_default_#{Time.now.to_i} ||= #{default.inspect}) ; end"		# using Time breaks cache on code reload
			module_eval( "def #{signal}() ; @#{signal} || (@#{signal}_default_#{Time.now.to_i} ||= #{default.inspect}) ; end", __FILE__, __LINE__ )
			module_eval( "def #{signal}=(value) @#{signal} = value ; end", __FILE__, __LINE__ )
			module_eval( "def set_#{signal}(value) self.#{signal} = value ; self ; end", __FILE__, __LINE__ )
		else
			# easy_accessor :one, :two, :three
			signals.each { |signal|
				module_eval( "def #{signal}() ; @#{signal} ; end", __FILE__, __LINE__ )
				module_eval( "def #{signal}=(value) @#{signal} = value ; end", __FILE__, __LINE__ )
				module_eval( "def set_#{signal}(value) self.#{signal} = value ; self ; end", __FILE__, __LINE__ )
			}
		end
	end
end
