require 'gui_object'

#
# GuiLabel is a piece of static text
#
class GuiLabel < GuiObject
	easy_accessor :string

	def string=(s)
		@string = s
		@image = nil
	end

	def gui_render!
		@cairo_font ||= CairoFont.new
		@image ||= @cairo_font.render_to_image(string, $gui.gui_font)

		with_positioning {
			#with_color([0,0.2,0.2]) { unit_square }
			#with_color([1,1,1]) { unit_square_outline }
			@image.using { unit_square }
		}
	end
end
