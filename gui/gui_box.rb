#
# GuiBox is the base level container.
#
# It does no positioning of child objects, each is simply drawn on top of the previous.
#
class GuiBox < GuiObject
	callback :contents_change

	def initialize(contents = [])
		self.contents = contents
		@selection = Set.new
		@float_left = -0.5
		@float_right = 0.5
		super()
	end

	#
	#
	#
	def count
		@contents.count
	end

	def empty?
		@contents.empty?
	end

	# finding
	def first
		@contents.first
	end

	def include?(object)
		@contents.include? object
	end

	def index(object)
		@contents.index(object)
	end

	#
	# Adding
	#
	def contents=(contents)
		if @contents
			unlink!
			notify = true
		end
		@contents = contents		# NOTE: points at list, doesn't copy it (list operations happen on the array we're showing)
		@contents.each { |gui_object| gui_object.parent = self }
		contents_change_notify if notify
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
		elsif gui_object.float == :right
			extra_spacing = (gui_object.offset_x || 0.0)
			gui_object.offset_x = @float_right - (gui_object.scale_x / 2.0) - extra_spacing
			@float_right -= (gui_object.scale_x + extra_spacing)
		end
		contents_change_notify
	end

	def insert(index, object)
		@contents.insert(index, object)
		object.parent = self
		contents_change_notify
	end

	def add_after_selection(object)
		if (selected_object = selection.first) && (index = @contents.index(selected_object))
			insert(index+1, object)
		else
			self << object
		end
		contents_change_notify
	end

	def prepend(gui_object)
		@contents.unshift(gui_object)
		gui_object.parent = self
		contents_change_notify
	end

	def bring_to_top(object)
		if @contents.delete(object)
			@contents << object
			contents_change_notify
		end
	end

	#
	#
	#
	def clear!
		return if empty?
		unlink!
		@contents.clear
		clear_selection!
		contents_change_notify
	end

	def remove(gui_object)
		@contents.delete(gui_object)
		contents_change_notify
	end

	def unlink!
		@contents.each { |gui_object| gui_object.parent = nil }
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
		return if @selection.size == 1 && child_is_selected?(object)
		@selection.clear					# without notify
		add_to_selection(object)	# with notify
	end

	def selected_index
		selection = @selection.first
		index(selection) if selection
	end

	def clear_selection!
		return if @selection.empty?
		@selection.clear
		selection_change_notify
	end

	def select_next!(number=1)
		return if @contents.empty?
		selection = @selection.first		# TODO: support multiselection?
		index = @contents.index(selection) || -1
		index = (index + number) % @contents.size
		@selection.clear
		add_to_selection(@contents[index])
	end

	def select_previous!(number=1)
		return if @contents.empty?
		selection = @selection.first		# TODO: support multiselection?
		index = @contents.index(selection) || @contents.size
		index = (index - number) % @contents.size
		@selection.clear
		add_to_selection(@contents[index])
	end

	attr_reader :selection

	def selection_grab_focus!
		selected = selection.first
		selected.grab_keyboard_focus! if selected
	end

	#
	# Iterating
	#
	def each(&proc)
		@contents.each(&proc)
	end
	def find(&proc)
		@contents.find(&proc)
	end
	def map(&proc)
		@contents.map(&proc)
	end

	def each_with_positioning
		with_positioning {
			@contents.each { |gui_object| yield gui_object }
		}
	end

	#
	# Reordering
	#
	def move_child_up(child, number=1)
		return unless (index = @contents.index(child))
		if index > (number-1)
			@contents[index], @contents[index-number] = @contents[index-number], @contents[index]
			contents_change_notify
		end
	end

	def move_child_down(child, number=1)
		return unless (index = @contents.index(child))
		if index < (@contents.size - number)
			@contents[index], @contents[index+number] = @contents[index+number], @contents[index]
			contents_change_notify
		end
	end

	#
	# Extend GuiObject methods to pass them along to contents
	#
	def gui_tick
		return if hidden?
		@contents.each { |gui_object| gui_object.gui_tick }
		super
	end

	def gui_render
		return if hidden?
		with_positioning { gui_render_background }
		each_with_positioning { |gui_object| gui_object.gui_render }
		with_positioning { gui_render_keyboard_focus } if keyboard_focus?
	end

	def hit_test_render!
		return if hidden?
		each_with_positioning { |gui_object| gui_object.hit_test_render! }
	end
end
