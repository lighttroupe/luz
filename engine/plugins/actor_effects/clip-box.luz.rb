class ActorEffectClipBox < ActorEffect
	title				"Clip Box"
	description "All parts of actor that extend outside of box are hidden."

	categories :special

	hint "Places four clip planes around the actor. Placement is affected by any translation or rotation done before Clip Box in the effects list."

	setting 'size', :float, :range => 0.0..1000.0, :default => 1.0..1000.0
	setting 'angle', :float, :default => 0.0..1.0

	def render
		with_clip_box(size / 2.0, angle) {
			yield
		}
	end
end
