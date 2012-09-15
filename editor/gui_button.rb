class GuiButton < GuiObject
	callback :clicked
	easy_accessor :background_image

	def click(pointer)
		clicked_notify(pointer)
	end

	BUTTON_COLOR = [1.0,1.0,1.0,1.0]
	BUTTON_HOVER_COLOR = [1.0,0.5,0.5]
	BUTTON_CLICK_COLOR = [0.5,1.0,0.5]

	def gui_color
		(pointer_clicking?) ? BUTTON_CLICK_COLOR : ((pointer_hovering?) ? BUTTON_HOVER_COLOR : BUTTON_COLOR)
	end

	def gui_render!
		return if hidden?
		with_positioning {
			with_color(gui_color) {
				if background_image
					background_image.using {
						unit_square
					}
				else
					unit_square
				end
			}
		}
	end
end
