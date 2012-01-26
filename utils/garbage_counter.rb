module GarbageCounter
	# Classes
	def self.new_classes(base_class = Object)
		counts = {}
		ObjectSpace.each_object(base_class) {	|obj| counts[obj.class] ||= 0 ; counts[obj.class] -= 1 }
		yield
		ObjectSpace.each_object(base_class) {	|obj| counts[obj.class] += 1 }

		return counts.select {|klass, count| count != 0 }
	end

	def self.report_new_classes(base_class = Object, &proc)
		p self.new_classes(base_class, &proc)
	end

	# Instances
	def self.new_objects(base_class = Object)
		objects = {}
		new_objects = []
		ObjectSpace.each_object(base_class) {	|obj| objects[obj.object_id] = obj }
		yield
		ObjectSpace.each_object(base_class) {	|obj| new_objects << obj unless (objects[obj.object_id]) }

		return new_objects
	end

	def self.report_new_objects(base_class = Object, &proc)
		p self.new_objects(base_class, &proc)
	end
end
