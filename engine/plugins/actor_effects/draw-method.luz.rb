class ActorEffectDrawMethod < ActorEffect
	title				"Draw Method"
	description "Changes how the actor's pixels are applied."

	categories :color

	setting 'draw_method', :select, :options => DRAW_METHOD_OPTIONS, :summary => true

	def render
		with_pixel_combine_function(draw_method) {
			yield
		}
	end
end
