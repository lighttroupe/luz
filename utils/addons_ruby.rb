 ###############################################################################
 #  Copyright 2006 Ian McIntosh <ian@openanswers.org>
 #
 #  This program is free software; you can redistribute it and/or modify
 #  it under the terms of the GNU General Public License as published by
 #  the Free Software Foundation; either version 2 of the License, or
 #  (at your option) any later version.
 #
 #  This program is distributed in the hope that it will be useful,
 #  but WITHOUT ANY WARRANTY; without even the implied warranty of
 #  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 #  GNU Library General Public License for more details.
 #
 #  You should have received a copy of the GNU General Public License
 #  along with this program; if not, write to the Free Software
 #  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 ###############################################################################

# extend/simplify/standardize some Ruby objects

module Kernel
	TAB = "\t"

	def load_directory(path, filter_pattern='*rb')
		count = 0
		paths = []		# collect and then sort to make load order consistent
		Dir.new(path).each_matching_recursive(filter_pattern) { |filepath| paths << filepath }
		paths.sort!.each { |filepath| count += 1 if reload_if_newer(filepath) }
		return count
	end

  def invoker(levels = -1)
    st = Thread.current[:callstack]
    st && st[levels - 2]
  end

	def chance(c)
		rand < c
	end

	def rand_in_range(low, high)
		low + (rand * (high - low))

#		low, high = high, low if low > high
#		slots = (high - low) + 1
#		width_each = 1.0 / slots
#		rand.div(width_each)
	end

	def section(name)
		$section_nesting_level ||= 0
		puts "#{TAB * $section_nesting_level}- #{name}..."
		time = Time.now
		$section_nesting_level += 1
		yield
		$section_nesting_level -= 1
		puts "#{TAB * $section_nesting_level}- #{name} Done (%0.2fs)" % (Time.now - time)
	end

	def timer(name='Timer', options=nil)
		t = Time.new
		yield
		delta = (Time.new - t)
		puts sprintf("%s: %02.5f seconds\n", name, delta) if (options.nil? or (options[:if_over] and delta > options[:if_over].to_f))
	end

	def max(a,b)
		(a >= b) ? a : b
	end

	def min(a,b)
		(a <= b) ? a : b
	end
end

module ObjectSpace
	def self.object_count(base_class = Object)
		count = 0
		each_object(base_class) {	count += 1 }
		return count
	end
end

class Module
	# Lets an object quickly create many empty methods
	def empty_method(*signals)
		signals.each { |signal| module_eval( "def #{signal}(*args, &proc) ; end", __FILE__, __LINE__) }
	end

	def attr_reader(*signals)
		# Like the original, but also adds 'signal?'
		signals.each { |signal|
			module_eval( "def #{signal} ; @#{signal} ; end", __FILE__, __LINE__)
			module_eval( "def #{signal}? ; @#{signal} ; end", __FILE__, __LINE__)
		}
	end

	def attr_accessor(*signals)
		# Add custom readers
		attr_reader(*signals)

		# Add custom writers
		signals.each { |signal|
			module_eval( "def #{signal}=(value) @#{signal} = value ; end", __FILE__, __LINE__)
			module_eval( "def set_#{signal}(value) self.#{signal} = value ; return self ; end", __FILE__, __LINE__)
		}
	end
end

class Class
	def inherited_from?(klass)
		self.ancestors.include?(klass) and self != klass		# NOTE: ancestors[] includes the class itself
	end
end

def optional_require(file)
	begin
		require file
		return true
	rescue LoadError
		return false
	end
end

class Object
	require 'deep_clone'
	require 'callbacks'
	require 'easy_dsl'

	include DeepClone
	include Callbacks
	include EasyDSL

	def to_a
		return self if is_a?(Array)
		return [self]
	end

	def set_default_instance_variables(hash)
		hash.each { |k,v| instance_variable_set("@#{k}", v) if instance_variable_get("@#{k}").nil? }
	end

	# Can be called with a symbol, string, method, or proc.
	def easy_call(name, *args, &proc)
		case name
		when Symbol, String
			send(name, *args, &proc)
		when Method, Proc
			name.call(*args, &proc)
		end
	end
end

class Hash
	def value_to_key(value)
		return nil if (a = find { |k,v| v == value }).nil?
		return a.first
	end

#	def find_value(&block)
#		return nil if (a = find(&block)).nil?
#		return a.last
#	end

#	def map(&block)
#		h = Hash.new
#		each_pair { |k, v| newkv = block.call(k, v) ; h[newkv.first] = newkv.last }
#		return h
#	end
end

class Array
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

	def reverse_coordinates
		a = dup
		0.step(size - 1, 2) { |i| a[i], a[i+1] = a[i+1], a[i]	}
		return a.reverse
	end

	def random
		return self[rand(size)] unless size == 0
		return nil
	end

	def insert_randomly(value)
		insert(rand(size), value)
	end

	def insert_randomly(value)
		insert(rand(size), value)
	end

	def delete_unless
		delete_if { |object| !yield object }
	end

	# Returns new array containing first n items
	def top(n)
		self[0, n]
	end

	def remove_randomly
		delete_at(rand(size))
	end

	def choose_randomly(number)
		candidates = self.dup
		number = candidates.size if number > candidates.size

		selection = []
		number.times { selection << candidates.remove_randomly }
		return selection
	end

	def random_element
		self[rand(size)]
	end

	def randomize
		each_index { |i| r = rand(size)	; self[i], self[r] = self[r], self[i] }
	end

	def all_equal(field)
		return true if self.size <= 1
		value = self.first.send(field)
		each { |v| return false if v.send(field) != value }
		return true
	end

	def all?
		each { |obj| return false if yield(obj) == false }
		return true
	end

	def inconsistent?
		yes = no = false
		each { |obj| if yield(obj) ; yes = true ; else ; no = true ; end ; return true if yes and no }
		return false
	end

	def max_by_method(method, *args, &proc)
		max = nil
		each { |obj|
			value = obj.send(method, *args, &proc)
			max = value if (max.nil?) or (!value.nil? and value > max)
		}
		return max
	end

	# returns the average change between array elements		NOTE: requires at least two elements
	def delta_min_max_avg
		min, max, total = nil, nil, 0.0

		for i in 0..size-2
			difference = self[i + 1] - self[i]
			min = difference if (min.nil? or difference < min)
			max = difference if (max.nil? or difference > max)
			total += difference
		end
		return [min, max, total / (size - 1)]
	end

	def first_non_blank_string(alt = nil)
		each {|str| return str unless (str.nil? or str.empty?) }
		return alt
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
		total = self.first
		each_with_index { |v, i| total += v if (v and i > 0) }
		return total
	end

	def average
		total, count = 0.0, 0
		each { |v|
			if v
				total += v
				count += 1
			end
		}
		return nil if count == 0
		return total / count
	end

	def minimum
		min = nil
		each { |v| min = v if (min.nil? or v < min) }
		return min
	end

	def maximum
		max = nil
		each { |v| max = v if (max.nil? or v > max) }
		return max
	end

	def collect_non_nil
		a = []
		self.each { |obj| value = yield obj ; a << value unless value.nil? }
		return a
	end

	def collect_with_index
		a = []
		self.each_with_index { |obj, index| a << yield(obj, index) }
		return a
	end

#	def find(&block)
#		each { |v| return v if block.call(v) }
#		nil
#	end

	# TODO: this belongs elsewhere
	def each_enabled
		each { |obj| yield obj if obj.enabled? }
	end

	def binary_search_closest_lower_index(value)
		first=0
		last=self.size - 1

		while first <= last
			mid = (first + last) / 2
			return mid if value == self[mid]

			if value > self[mid]
				# Quick check if this is the index
				return mid if (mid < last) and (value < self[mid+1])

				first = mid + 1
			else
				# Quick check if previous is the index
				return mid-1 if (mid > first) and (value > self[mid-1])

				last = mid - 1
			end
		end
		return nil
	end
end

class String
	def limit(max_length, indicator='...')
		return self[0, max_length] + indicator if length > max_length
		return self
	end

	def shift(n)
		text = self[0, n]
		self[0, n] = ''		# shift string left, removing word
		return text
	end

	def next_word
		strip!		# TODO: strip is wrong: it removes whitespace from both ends of the string
		space_index = index(' ')
		return self if space_index.nil?
		return shift(space_index)
	end

	def begins_with?(string)
		self.index(string) == 0
	end

	def matches?(search_string)
		search_words = search_string.downcase.split(' ')
		return false if search_words.empty?

		# Each search word must match consecutive self.words eg. "music visuals".match?("m vis") == true
		string_words = self.split(' ')
		return false if search_words.size > string_words.size

		search_words.each_with_index { |search_word, index|
			return false unless string_words[index].begins_with? search_word
		}
		return true
	end

	# Adds spaces between capitalized words and converts underscores to spaces
  def humanize
		return self.
			gsub(/([A-Z]+)([A-Z][a-z])/, '\1 \2').
			gsub(/([a-z\d])([A-Z])/, '\1 \2').
			gsub(/_/, ' ').
			split(' ').collect { |w| w.capitalize }.join(' ')
  end

  def to_lowercase_underscored
		return self.
			gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2').
			gsub(/([a-z\d])([A-Z])/, '\1_\2').
			gsub(/ /, '_').downcase
  end

  def has_prefix?(prefix)
  	self[0, prefix.length] == prefix		# TODO: faster way to implement this?
  end

  def without_prefix(prefix)
  	return self[prefix.length, self.length - prefix.length] if has_prefix?(prefix)
  	return self
  end

  def has_suffix?(suffix)
  	self[-suffix.length, suffix.length] == suffix		# TODO: faster way to implement this?
  end

  def without_suffix(suffix)
  	return self[0, self.length - suffix.length] if has_suffix?(suffix)
  	return self
  end
end

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
		throw 'value cannot be 0' if self == 0
		return self - 1 if fuzzy == 1.0
		return (self * fuzzy).to_i
	end

	def plural(singular, plural)
		sprintf("%d %s", self, (self == 1) ? singular : plural)
	end

	def index_progress_to(total)
		return 0.0 if self == 0
		return 1.0 if total == 1
		return (self.to_f / (total - 1).to_f)
	end

	def second
		self
	end
	alias :seconds :second

	def minute
		self * 60
	end
	alias :minutes :minute

	def hour
		self * (60 * 60)
	end
	alias :hours :hour
end

class Float
	def damper(target, damper)
		return target if ((self - target).abs < damper)
		return self
	end

	def fuzzy?
		return (self >= 0.0 and self <= 1.0)
	end

	def scale(low, high)
		#throw "scale called on float with bad value '#{self}'" unless self.fuzzy?
		low + self * (high - low)
	end

	def index_and_progress_to(high)
		return [high-1, 1.0] if self == 1.0

		(self * high).divmod(1.0)
	end

	def squared ; self * self	; end
	def cubed ; self * self * self ; end

	def square_root
		Math.sqrt(self)
	end

	def clamp(low, high)
		return low if self < low
		return high if self > high
		return self
	end

	def clamp_fuzzy
		return 0.0 if self < 0.0
		return 1.0 if self > 1.0
		return self
	end

	def time_format
		hours, remainder = self.divmod(3600.0)
		minutes, seconds = remainder.divmod(60.0)
		return sprintf('%02d:%02d:%05.2f', hours, minutes, seconds)
	end

	def time_format_natural
		hours, remainder = self.divmod(3600.0)
		minutes, seconds = remainder.divmod(60.0)
		parts = []
		parts << hours.plural('hour', 'hours') if hours > 0
		parts << minutes.plural('minute', 'minutes') if minutes > 0
		parts << seconds.to_i.plural('second', 'seconds') if parts.empty? # Only show seconds if it's the only part
		return parts.join(', ')
	end
end

class Dir
	def each_matching(pattern)	# accepts patterns like '*.png'
		each { |filename| yield File.join(path, filename) if File.fnmatch(pattern, filename) }
	end

	def each_matching_recursive(pattern)	# accepts patterns like '*.png'
		each { |filename|
			unless filename == '..' or filename == '.'
				filepath = File.join(path, filename)

				if File.directory?(filepath)
					# When we find directories, recurse
					Dir.new(filepath).each_matching_recursive(pattern) { |filepath| yield filepath }
				elsif File.fnmatch(pattern, filename)
					# Send matching file names back to parent
					yield filepath
				end
			end
		}
	end

	# Dir.home added in Ruby 1.9
	def self.home
		ENV['HOME']
	end unless self.respond_to? :home
end

module Math
	def self.distance_2d(a,b)
		((a[0] - b[0]).squared + (a[1] - b[1]).squared).square_root
	end
end
