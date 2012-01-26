class GLVertexShader
	attr_accessor :shader

	def initialize(source)
		@shader = glCreateShader(GL_VERTEX_SHADER)
		@source = source

		glShaderSource(@shader, @source)
		glCompileShader(@shader)

		puts "Vertex Shader: #{glGetShaderInfoLog(@shader)}" unless (glGetShaderiv(@shader, GL_COMPILE_STATUS) == true)
	end
end
