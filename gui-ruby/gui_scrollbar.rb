class GuiScrollbarScroller < GuiObject
	HOVER_COLOR = [0.7,0.7,0.0,0.8]
	INACTIVE_COLOR = [0.08,0.08,0.08,0.4]
	ACTIVE_COLOR = [0.15,0.15,0.15,0.9]

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
			with_color(scroller_color) {
				unit_square
			}
		}
	end

	def scroller_color
		if @scrollbar.can_move?
			if pointer_hovering?
				HOVER_COLOR
			else
				ACTIVE_COLOR
			end
		else
			INACTIVE_COLOR
		end
	end
end

class GuiScrollbar < GuiBox
	WELL_COLOR = [0.05,0.05,0.05,0.4]

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
			self << (@scroller = GuiScrollbarScroller.new(self).set(:scale_x => 0.50, :scale_y => 1.0))
		end

		scroller_size = @target.visible_percentage
		scroller_half_size = scroller_size / 2.0
		scroller_progress = @target.scroll_percentage
		space = (1.0 - scroller_size)

		@scroller.set(:scale_y => scroller_size * 0.95, :offset_y => (0.5 - scroller_half_size) - (scroller_progress * space))

		@scroller
	end

	def can_move?
		@target.visible_percentage < 1.0
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
			with_color(WELL_COLOR) {
				unit_square
			}
		}
		super
	end
end
