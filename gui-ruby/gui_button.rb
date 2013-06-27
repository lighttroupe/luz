class GuiButton < GuiObject
	BUTTON_COLOR = [1.0,1.0,1.0,1.0]
	BUTTON_HOVER_COLOR = [1.0,0.5,0.5]
	BUTTON_CLICK_COLOR = [0.5,1.0,0.5]

	callback :clicked
	callback :holding
	easy_accessor :background_image

	def click(pointer)
		clicked_notify(pointer)
	end

	def click_hold(pointer)
		holding_notify(pointer)
	end

	def gui_render!
		return if hidden?
		with_positioning {
			with_color(gui_color) {
				gui_render_background
			}
		}
	end

private

	def gui_color
		(pointer_clicking?) ? BUTTON_CLICK_COLOR : ((pointer_hovering?) ? BUTTON_HOVER_COLOR : nil)
	end
end
