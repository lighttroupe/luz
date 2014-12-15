class GuiActorView < GuiBox
	attr_accessor :actor

	def initialize
		super
		set(:background_image => $engine.load_image('images/actor-view-background.png').set_texture_options(:no_smoothing => true))
	end

	def gui_render
		super
		@actor.render! if @actor
	end
end
