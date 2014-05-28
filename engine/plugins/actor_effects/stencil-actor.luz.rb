class ActorEffectStencilActor < ActorEffect
	title				"Stencil Actor"
	description "Choose an actor to serve as a stencil."

	categories :special

	setting 'actor', :actor
	setting 'alpha_cutoff', :float, :range => 0.0..1.0, :default => 0.0..1.0

	def render
		return yield unless actor_setting.present?

		with_stencil_buffer_for_writing(:alpha_cutoff => alpha_cutoff) {
			actor.render
		}
		with_stencil_buffer_filter {
			yield
		}
	end
end
