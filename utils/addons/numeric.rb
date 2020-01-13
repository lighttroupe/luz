class Numeric
	def clamp(low, high)
		return low if self <= low
		return high if self >= high
		self
	end

	def squared
		self * self
	end
end
