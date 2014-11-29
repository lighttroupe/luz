require 'gui_object'

#
# GuiLabel is a piece of static text
#
class GuiLabel < GuiObject
	easy_accessor :string

	def gui_render!
		@cairo_font ||= CairoFont.new
		@image ||= @cairo_font.render_to_image(string, $gui.gui_font)

		with_positioning {
			@image.using { unit_square }
		}
	end
end
