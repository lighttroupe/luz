module Math
	def self.distance_2d(a,b)
		((a[0] - b[0]).squared + (a[1] - b[1]).squared).square_root
	end
end
