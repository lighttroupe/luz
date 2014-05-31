class ActorEffectVertexShaderText < ActorEffect
	title				"Vertex Shader Test"
	description ""

	categories :special

	setting 'amount', :float, :default => 0.0..1.0, :shader => true

	CODE = "
			vertex.x += (rand(vertex.xy)-0.5) * amount;
			vertex.y += (rand(vertex.yx)-0.5) * amount;
		"

	def render
		return yield if amount == 0.0

		with_vertex_shader_snippet(CODE, self) {
			yield
		}
	end
end
