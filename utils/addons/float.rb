class Float
	def scale(low, high)
		low + self * (high - low)		# NOTE: expects self to be 0.0..1.0
	end

	def squared
		self * self
	end

	def square_root
		Math.sqrt(self)
	end

	def clamp(low, high)
		return low if self < low
		return high if self > high
		self
	end
end
