module DeepClone
	# This is the same as the above, except it only clones an object if is_cloneable_callback(obj) returns true, otherwise it uses a reference to obj (the root object is always cloned)
	def deep_clone(list = {}, &is_cloneable_callback)
		return list[self] if list[self]
		case self
		when Hash
			klone = self.clone
			klone.clear
			self.each { |k,v| klone[k.deep_clone(list, &is_cloneable_callback)] = v.deep_clone(list, &is_cloneable_callback) }
		when Array
			klone = self.clone
			klone.clear
			self.each { |obj| klone << obj.deep_clone(list, &is_cloneable_callback) }
		else
			begin
				# Determine if we should clone or reuse this object
				is_root_object = (list.empty?)

				if is_root_object or (is_cloneable_callback and is_cloneable_callback.call(self))
					klone = self.clone
				else
					klone = self
				end
			rescue
				klone = self
			end
		end
		list[self] = klone
		klone.instance_variables.each { |v|
			klone.instance_variable_set(v, klone.instance_variable_get(v).deep_clone(list, &is_cloneable_callback))
		}
		return klone
	end
end

if $0 == __FILE__
	require 'test/unit'

	class Object
		include DeepClone
	end

	class TestDeepClone < Test::Unit::TestCase
		def test_sometime
		end
	end
end
