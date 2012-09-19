class GuiBox < GuiObject
	def initialize(contents = [])
		@contents = contents
		@contents.each { |gui_object|
			gui_object.parent = self
		}
		super()
	end

	def <<(gui_object)
		@contents << gui_object
		gui_object.parent = self
	end

	def prepend(gui_object)
		@contents.unshift(gui_object)
		gui_object.parent = self
	end

	def bring_to_top(object)
		if @contents.delete(object)
			@contents << object
		end
	end

	#
	# Extend GuiObject methods to pass them along to contents
	#
	def gui_render!
		return if hidden?
		with_positioning {
			@contents.each { |gui_object| gui_object.gui_render! }
		}
	end

	def gui_tick!
		return if hidden?
		@contents.each { |gui_object| gui_object.gui_tick! }
		super
	end

	def hit_test_render!
		return if hidden?
		with_positioning {
			@contents.each { |gui_object|
				gui_object.hit_test_render!
			}
		}
	end
end
