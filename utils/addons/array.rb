class Array
	#
	# iteration
	#
	# define an iterator over each pair of indexes in an array
	def each_pair_index
		(0..(self.length-1)).each do |i|
			((i+1)..(self.length-1 )).each do |j|
				yield i, j
			end
		end
	end

	# define an iterator over each pair of values in an array for easy reuse
	def each_pair
		self.each_pair_index do |i, j|
			yield self[i], self[j]
		end
	end

	def all_equal_or_default(method, default)
		return default if empty?

		begin
			value = first.send(method)
			each { |obj| return default if obj.send(method) != value }
			return value	# all equal
		rescue NoMethodError
			puts 'foobar'
			return default
		end
	end

	#
	# Randomness
	#
	def random
		return nil if size == 0
		self[rand(size)]
	end

	def insert_randomly(value)
		insert(rand(size), value)
	end

	def remove_randomly
		delete_at(rand(size))
	end

	def choose_randomly(number)
		candidates = self.dup
		number = candidates.size if number > candidates.size

		selection = []
		number.times { selection << candidates.remove_randomly }
		selection
	end

	def random_element
		self[rand(size)]
	end

	def randomize
		each_index { |i| r = rand(size)	; self[i], self[r] = self[r], self[i] }
	end

	def delete_unless
		delete_if { |object| !yield object }
	end

	# Returns new array containing first n items
	def top(n)
		self[0, n]
	end

	def all_equal(field)
		return true if self.size <= 1
		value = self.first.send(field)
		each { |v| return false if v.send(field) != value }
		true
	end

	def all?
		each { |obj| return false if yield(obj) == false }
		true
	end

	def inconsistent?
		yes = no = false
		each { |obj| if yield(obj) ; yes = true ; else ; no = true ; end ; return true if yes && no }
		false
	end

	def max_by_method(method, *args, &proc)
		max = nil
		each { |obj|
			value = obj.send(method, *args, &proc)
			max = value if (max.nil?) || (!value.nil? && value > max)
		}
		max
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

	def first_non_blank_string(alt = nil)
		each {|str| return str unless (str.nil? || str.empty?) }
		alt
	end

	# sets first element of array to given value
	def first=(rhs)
		return self if size == 0 # TODO: handle empty array?
		self[0] = rhs
	end
	def set_first(rhs)
		self.first = rhs
		self
	end

	# sets last element of array to given value
	def last=(rhs)
		return self if size == 0 # TODO: handle empty array?
		self[size - 1] = rhs
	end
	def set_last(rhs)
		self.last = rhs
		self
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

	def reverse_each_with_index
		(self.size - 1).downto(0) { |i| yield(self[i], i) }
	end

	def grow_to(desired_size)
		(size).upto(desired_size - 1) { |index| self[index] = yield(index) }
	end

	def remove_first
		shift
		self
	end

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

	def collect_non_nil
		a = []
		self.each { |obj| value = yield obj ; a << value unless value.nil? }
		a
	end

	def collect_with_index
		a = []
		self.each_with_index { |obj, index| a << yield(obj, index) }
		a
	end
end
