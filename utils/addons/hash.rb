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
