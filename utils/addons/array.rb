class Array
	def collect_with_index
		a = []
		self.each_with_index { |obj, index| a << yield(obj, index) }
		a
	end

	def collect_non_nil
		a = []
		self.each { |obj| value = yield obj ; a << value unless value.nil? }
		a
	end

	def append_or_replace(rhs)
		each_with_index { |obj, i|
			if yield(obj, rhs)
				self[i] = rhs  # replace
				return
			end
		}
		self << rhs
	end

	def multiply_each(value)
		each_index { |i| self[i] *= value }
	end

	# returns the average change between array elements		NOTE: requires at least two elements
	def delta_min_max_avg
		min, max, total = nil, nil, 0.0

		for i in 0..size-2
			difference = self[i + 1] - self[i]
			min = difference if (min.nil? || difference < min)
			max = difference if (max.nil? || difference > max)
			total += difference
		end
		[min, max, total / (size - 1)]
	end

	#
	# set min/max/avg
	#
	def sum
		total = self.first		# avoid caring about type
		each_with_index { |v, i| total += v if (v && i > 0) }
		total
	end

	def average
		total, count = 0.0, 0
		each { |v|
			if v
				total += v
				count += 1
			end
		}
		return nil if size == 0
		total / count
	end

	def minimum
		min = nil
		each { |v| min = v if (min.nil? || v < min) }
		min
	end

	def maximum
		max = nil
		each { |v| max = v if (max.nil? || v > max) }
		max
	end
end
