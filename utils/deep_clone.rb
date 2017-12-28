#
# DeepClone makes a whole independent new Object, with new copies of internal data structures.
#
# Optionally filter what is cloned vs linked in new object with passed proc.
#
# new_object = object.deep_clone
#
module DeepClone
	def deep_clone(cloned_objects = {}, &is_cloneable_callback)
		return cloned_objects[self] if cloned_objects[self]
		case self
		when Hash
			klone = self.clone.clear
			self.each { |k,v| klone[k.deep_clone(cloned_objects, &is_cloneable_callback)] = v.deep_clone(cloned_objects, &is_cloneable_callback) }
		when Array
			klone = self.clone.map { |obj| obj.deep_clone(cloned_objects, &is_cloneable_callback) }
		else
			begin
				# Determine if we should clone or reuse this object
				is_root_object = cloned_objects.empty?		# (just started clone process)
				if is_root_object || (is_cloneable_callback && is_cloneable_callback.call(self))
					# klone this object (if possible)
					begin
						klone = self.clone
					rescue NotImplementedError
						klone = self
					end
				else
					# refer to this object
					klone = self
				end
			rescue
				klone = self
			end
		end
		cloned_objects[self] = klone if klone

		# clone instance variables
		klone.instance_variables.each { |v|
			klone.instance_variable_set(v, klone.instance_variable_get(v).deep_clone(cloned_objects, &is_cloneable_callback))
		}
		klone
	end
end

if $0 == __FILE__
	require 'test/unit'

	class Object
		include DeepClone
	end

	class TestDeepClone < Test::Unit::TestCase
		def test_sometime
			string = "test"
			array = [1,2,3,string]
			assert_equal [1,2,3,string], array.deep_clone
			assert_equal string.object_id, array.deep_clone.last.object_id
			assert_not_equal string.object_id, array.deep_clone { |obj| obj.is_a?(String) }.last.object_id
		end
	end
end
