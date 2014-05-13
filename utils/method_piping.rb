#
# This is the delegator pattern.
#
#  pipe :start_the_machine!, :machine, :method => :start!								# calls @machine.start!
#
class Module		# TODO: why?
	def pipe(signal, target, original_options={})
		(signal.respond_to?(:each) ? signal : [signal]).each { |signal|
			options = {:method => signal}.merge(original_options)
			if options[:args]
				module_eval( "def #{signal}(&proc) instance_variable_get('@' + '#{target.to_s}').send('#{options[:method]}', #{options[:args]}, &proc) ; end", "__(METHOD PIPING)__", 1)
			elsif options[:no_args]
				module_eval( "def #{signal}(&proc) instance_variable_get('@' + '#{target.to_s}').send('#{options[:method]}', &proc) ; end", "__(METHOD PIPING)__", 1)
			else
				module_eval( "def #{signal}(*args, &proc) instance_variable_get('@' + '#{target.to_s}').send('#{options[:method]}', *args, &proc) ; end", "__(METHOD PIPING)__", 1)
			end
		}
	end
end
