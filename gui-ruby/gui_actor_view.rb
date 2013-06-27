class GuiActorView < GuiBox
	attr_accessor :actor

	def gui_render!
		super
		with_scale(0.75, 1.0) {		# TODO: this is related to screen ratio
			background_image.using { unit_square }
			@actor.render! if @actor
		}
	end

private

	def background_image
		@background_image ||= $engine.load_image('images/actor-view-background.png').set_texture_options(:no_smoothing => true)
	end
end
