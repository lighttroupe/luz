module Kernel
	TAB = "\t"

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
