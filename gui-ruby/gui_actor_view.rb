class GuiActorView < GuiBox
	attr_accessor :actor

	def gui_render!
		super
		with_scale(0.75, 1.0) {		# TODO: this is related to screen ratio
			$gui.actor_view_background_image.using {		# TODO
				unit_square
			}
			@actor.render! if @actor
		}
	end
end
