class GuiScrollbarScroller < GuiObject
	def initialize(scrollbar)
		super()
		@scrollbar = scrollbar
		draggable!
	end

	def update_drag(pointer)
		#@scrollbar.scroll_up!(point)
	end

	def gui_render!
		with_positioning {
			with_color([1.0,1.0,1.0]) {
				unit_square
			}
		}
	end
end

class GuiScrollbar < GuiBox
	# target should support:
	# scroll_velocity
	# scroll_percentage
	# visible_percentage
	def initialize(target)
		super()
		@target = target
	end

	def gui_tick!
		unless @scroller
			@scroller = GuiScrollbarScroller.new(self).set(:scale_x => 0.50, :scale_y => 1.0)
			self << @scroller
		end

		scroller_size = @target.visible_percentage
		scroller_half_size = scroller_size / 2.0
		scroller_progress = @target.scroll_percentage
		space = (1.0 - scroller_size)

		@scroller.set(:scale_y => scroller_size, :offset_y => (0.5 - scroller_half_size) - (scroller_progress * space))

		@scroller
	end

	def scroll_up!(pointer)
		@target.scroll_up!(pointer)
	end

	def scroll_down!(pointer)
		@target.scroll_down!(pointer)
	end

	def gui_render!
		# @target.scroll_velocity
		with_positioning {
			with_color([0.2,@target.scroll_velocity.abs,0.0]) {
				unit_square
			}
		}
		super
	end
end
