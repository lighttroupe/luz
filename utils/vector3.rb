class Vector3
	attr_accessor :x, :y, :z

	def self.new_from_string(str)
		x, y, z = str.split(',').collect { |v| v.to_f }
		self.new(x, y, z)
	end

	def initialize(x=0.0, y=0.0, z=0.0)
		set(x, y, z)
	end

	def set(x, y=nil, z=nil)
		if y and z
			@x, @y, @z = x, y, z
		else
			@x, @y, @z = x.x, x.y, x.z # treat x as a point
		end
		self
	end

	def ==(point)
		return false unless point.is_a? Vector3
		@x == point.x && @y == point.y && @z == point.z
	end

	def -(point)
		Vector3.new(x - point.x, y - point.y, z - point.z)
	end

	def +(point)
		Vector3.new(x + point.x, y + point.y, z + point.z)
	end

	def to_a
		[@x, @y, @z]
	end

	def *(float)
		Vector3.new(x * float, y * float, z * float)
	end

	def /(float)
		Vector3.new(x / float, y / float, z / float)
	end

	def dot(point)
		(point.x * @x) + (point.y * @y) + (point.z * @z)
	end

	def cross(point)
		Vector3.new(@y * point.z - @z * point.y, @z * point.x - @x * point.z, @x * point.y - @y * point.x)
	end

	def unit
		l = self.length
		return Vector3.new if l == 0.0

		Vector3.new(x / l, y / l, z / l)
	end

	def normalize!
		l = self.length
		return set(0.0,0.0,0.0) if l == 0.0
		return set(x / l, y / l, z / l)
	end

	def normalize
		l = self.length
		return set(0.0,0.0,0.0) if l == 0.0
		return set(x / l, y / l, z / l)
	end

	def length
		(x.squared + y.squared + z.squared).square_root
	end

	def distance_to(point)
		((@x - point.x).squared + (@y - point.y).squared + (@z - point.z).squared).square_root
	end

	def vector_to(point)
		(point - self)
	end

	def to_vector
		Vector.new(:x => @x, :y => @y, :z => @z)
	end

	def zero?
		(@x == 0.0 and @y == 0.0 and @z == 0.0)
	end

	def to_s
		"#{@x}, #{@y}, #{@z}"
	end

	def left
		Vector3.new(@y, -@x, @z)
	end
end
