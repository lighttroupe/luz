class Gtk::ListStore
	def each_iter
		each { |model, path, iter| yield iter }
	end

	def empty?
		each { return false }	# TODO: better way to do this?
		return true
	end
end
