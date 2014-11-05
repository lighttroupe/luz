class Integer
	# yields (value, index) 'self' times
	# eg. 11.distribute(0.0..100.0) => (0.0, 0), (10.0, 1), ..., (100.0, 10)
	def distribute(range)
		if self <= 1
			yield range.first, 0
		else
			step = (range.last - range.first) / (self - 1)
			for i in 0...self
				yield range.first + (i * step), i
			end
		end
	end

	def distributed_among(total, range)
		if total <= 1
			yield range.first
		else
			step = (range.last - range.first) / (total - 1)
			yield range.first + (self * step)
		end
	end

	def distribute_exclusive(range)
		if self <= 1
			yield range.first, 0
		else
			step = (range.last - range.first) / (self)
			for i in 0...self
				yield range.first + (i * step), i
			end
		end
	end

	# returns 0...self
	def choose_index_by_fuzzy(fuzzy)
		raise 'value cannot be 0' if self == 0
		return self - 1 if fuzzy == 1.0
		return (self * fuzzy).to_i
	end

	def plural(singular, plural)
		sprintf("%d %s", self, (self == 1) ? singular : plural)
	end
end
