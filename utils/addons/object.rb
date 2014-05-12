class Object
	if optional_require('deep_clone')
		include DeepClone
	end

	if optional_require('callbacks')
		include Callbacks
	end

	if optional_require('easy_dsl')
		include EasyDSL
	end

	def to_a
		return self if is_a?(Array)
		return [self]
	end

	def set_default_instance_variables(hash)
		hash.each { |k,v| instance_variable_set("@#{k}", v) if instance_variable_get("@#{k}").nil? }
	end

	# Can be called with a symbol, string, method, or proc.
	def easy_call(name, *args, &proc)
		case name
		when Symbol, String
			send(name, *args, &proc)
		when Method, Proc
			name.call(*args, &proc)
		end
	end
end
