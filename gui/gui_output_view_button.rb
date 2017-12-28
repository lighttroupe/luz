#
# GuiOutputViewButton glows while in output view
#
class GuiOutputViewButton < GuiButton
	easy_accessor :background_image_on

	def background_image
		if on?
			background_image_on
		else
			super
		end
	end

	def on?
		$gui.rendering_output?
	end
end
