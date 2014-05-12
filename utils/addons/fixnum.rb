class Fixnum
	def within?(low, high)
		return (to_i >= low and to_i <= high)
	end

	def is_even?
		return self % 2 == 0
	end

	def is_odd?
		return !is_even?
	end

	def clamp(low, high)
		return low if self < low
		return high if self > high
		return self
	end

	def squared
		self * self
	end

	def multiple_of?(n)
		(self != 0) and (self % n) == 0
	end
end
