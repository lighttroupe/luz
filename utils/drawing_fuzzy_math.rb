module DrawingFuzzyMath
	# Accepts 0.0 -> 1.0, returns 0.0 -> 1.0
	# (fuzzy 0.0 == radian 0.0)
	def fuzzy_sine(fuzzy)
		Math.sin(fuzzy * (Math::PI * 2.0)) / 2.0 + 0.5
	end

	def fuzzy_cosine(fuzzy)
		Math.cos(fuzzy * (Math::PI * 2.0)) / 2.0 + 0.5
	end
end
