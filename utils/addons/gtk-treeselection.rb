class Gtk::TreeSelection
	def selected_iters
		a = []
		selected_each { |model, path, iter| a << iter }
		return a
	end

	def empty?
		selected_each { return false }
		return true
	end

	def each_iter
		selected_each { |model, path, iter| yield iter }
	end
end
