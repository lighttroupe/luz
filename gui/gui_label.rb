require 'gui_object'

#
# GuiLabel is a piece of static text
#
class GuiLabel < GuiObject
	easy_accessor :string, :width, :text_align, :font, :lines

	callback :clicked

	def click(pointer)
		clicked_notify(pointer)
	end

	def string=(s)
		return if @string == s
		@string = s
		@image = nil
	end

	def gui_render
		@cairo_font ||= CairoFont.new
		@image ||= @cairo_font.render_to_image(string, font || $gui.gui_font, width || 1, lines || 1, text_align)

		with_positioning {
			#with_color([0,0.2,0.2]) { unit_square }
			#with_color([0.5,0.5,1]) { unit_square_outline }
			@image.using { unit_square }
		}
	end
end
