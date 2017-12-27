#
# GuiDirectorEditButton lights up while editing director, otherwise click to edit
#
class GuiDirectorEditButton < GuiButton
	easy_accessor :background_image_on

	def background_image
		if on?
			background_image_on
		else
			super
		end
	end

	def on?
		$gui.chosen_director && $gui.chosen_director.offscreen_render_actor.actor		# render actor present
	end
end
