class GLFragmentShader
	attr_accessor :shader

	def initialize(source)
		@shader = glCreateShader(GL_FRAGMENT_SHADER)
		@source = source

		glShaderSource(@shader, @source)
		glCompileShader(@shader)

		puts "Fragment Shader: #{glGetShaderInfoLog(@shader)}\n" unless (glGetShaderiv(@shader, GL_COMPILE_STATUS) == true)
	end
end
