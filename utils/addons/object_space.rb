module ObjectSpace
	def self.object_count(base_class = Object)
		count = 0
		each_object(base_class) {	count += 1 }
		return count
	end
end
