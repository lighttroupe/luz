#
# Path is a helper class for building 2D paths in the format [x1, y1, x2, y2, ...], useful for passing to an OpenGL Tessellator
#
class Path < Array
	def self.generate
		p = Path.new
		yield p
		return p
	end

	def start_at(x,y)
		clear
		line_to(x,y)
		self
	end

	def line_to(x,y)
		self << x
		self << y
		self
	end

	def first
		self[0, 2]
	end

	def last
		self[-2, 2]
	end

	#def [](i)
		#super[i*2, 2]
	#end

	#def each
		#0.upto(size - 2, 2) { |i| yield [self[i], self[i+1]] }
	#end

	#def size
		#super / 2
	#end

	def append_with_callback(num_points)
		0.upto(num_points-1) { |i| line_to(*yield(i)) }
		self
	end

	def arc_to(center_x, center_y, radius_x, radius_y, radians_start, radians_stop, detail)
		radians_step = (radians_stop - radians_start) / detail.to_f
		radians = radians_start
		for i in 0..detail
			self << center_x + (radius_x * Math.cos(radians))
			self << center_y + (radius_y * Math.sin(radians))
			radians += radians_step
		end
		self
	end
end
