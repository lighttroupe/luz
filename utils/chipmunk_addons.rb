module CP
	class Body
		attr_accessor :drawables
		def object=(o)
			raise "don't use this"
		end
		def object
			raise "don't use this"
		end
		def add_constraint(constraint)
			@constraints ||= []
			@constraints << constraint
			self
		end
		def constraints
			@constraints ||= []
		end
	end
	module Shape
		class Circle
			attr_accessor :level_object
			def object=(o)
				raise "don't use this"
			end
			def object
				raise "don't use this"
			end
		end
		class Poly
			attr_accessor :level_object
			def object=(o)
				raise "don't use this"
			end
			def object
				raise "don't use this"
			end
		end
		class Segment
			attr_accessor :level_object
			def object=(o)
				raise "don't use this"
			end
			def object
				raise "don't use this"
			end
		end
	end
end
