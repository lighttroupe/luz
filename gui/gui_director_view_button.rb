class GuiDirectorViewButton < GuiButton
	easy_accessor :background_image_on

	def background_image
		if on?
			background_image_on
		else
			super
		end
	end

	def on?
		$gui.rendering_director?
	end
end
