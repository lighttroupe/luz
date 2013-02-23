#
# GuiBox is the base level container.
#
# It does no positioning of child objects, each is simply drawn on top of the previous.
#

require 'set'

class GuiBox < GuiObject
	def initialize(contents = [])
		self.contents = contents
		@selection = Set.new
		@float_left = -0.5
		super()
	end

	def <<(gui_object)
		@contents << gui_object
		gui_object.parent = self

		#
		# crude float:left support (add it to object, it gets stacked left by the container)
		#
		if gui_object.float == :left
			extra_spacing = (gui_object.offset_x || 0.0)
			gui_object.offset_x = @float_left + (gui_object.scale_x / 2.0) + extra_spacing
			@float_left += gui_object.scale_x + extra_spacing
		end
	end

	def insert(index, object)
		@contents.insert(index+1, object)		# HACK: whoops shouldn't use @list here!!
		object.parent = self
	end

	def add_after_selection(object)
		if (obj = selection.first) && (index = @contents.index(obj))
			insert(index+1, object)
		else
			self << object
		end
	end

	def insert(index, gui_object)
		@contents.insert(index, gui_object)
		gui_object.parent = self
	end

	def remove(gui_object)
		@contents.delete(gui_object)
	end

	def prepend(gui_object)
		@contents.unshift(gui_object)
		gui_object.parent = self
	end

	def clear!
		@contents.each { |gui_object| gui_object.parent = nil }
		@contents.clear
	end

	def contents=(contents)
		clear! if @contents
		@contents = contents		# NOTE: points at list, doesn't copy it (list operations happen on the array we're showing)
		@contents.each { |gui_object| gui_object.parent = self }
	end

	def bring_to_top(object)
		if @contents.delete(object)
			@contents << object
		end
	end

	def include?(object)
		@contents.include? object
	end

	def index(object)
		@contents.index(object)
	end

	def empty?
		@contents.empty?
	end

	#
	# Selection
	#
	callback :selection_change

	def child_is_selected?(object)
		@selection.include?(object)
	end

	def add_to_selection(object)
		@selection << object
		selection_change_notify
	end

	def remove_from_selection(object)
		@selection.delete(object)
		selection_change_notify
	end

	def set_selection(object)
		clear_selection!
		add_to_selection(object)
		selection_change_notify
	end

	def clear_selection!
		@selection.clear
		selection_change_notify
	end

	attr_reader :selection

	#
	# Extend GuiObject methods to pass them along to contents
	#
	def each_with_positioning
		with_positioning {
			@contents.each { |gui_object| yield gui_object }
		}
	end

	def gui_tick!
		return if hidden?
		@contents.each { |gui_object| gui_object.gui_tick! }
		super
	end

	def gui_render!
		return if hidden?
		with_positioning { gui_render_background }
		each_with_positioning { |gui_object| gui_object.gui_render! }
	end

	def hit_test_render!
		return if hidden?
		each_with_positioning { |gui_object| gui_object.hit_test_render! }
	end
end
