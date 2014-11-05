module Kernel
	def timer(name='Timer', options=nil)
		t = Time.new
		yield
		delta = (Time.new - t)
		puts sprintf("%s: %02.5f seconds\n", name, delta) if (options.nil? or (options[:if_over] and delta > options[:if_over].to_f))
	end

	def min(a, b)
		(a <= b) ? a : b
	end

	def max(a, b)
		(a >= b) ? a : b
	end
end
