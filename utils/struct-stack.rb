# reuses structs to prevent garbage production
class StructStack
	def initialize(klass)
		@class = klass
	end

	def pop(*args)
		@available_stack ||= []
		@used_hash ||= {}

		if @available_stack.empty?
			obj = @class.new(*args)
		else
			obj = @available_stack.pop
			args.each_with_index { |arg, i| obj[i] = arg }
		end
		@used_hash[obj] = true
		return obj
	end

	def push(obj)
		@available_stack << obj
		@used_hash.delete(obj)
	end
end
