class GLShaderProgram
	boolean_accessor :ok

	def initialize(opts)
		#puts '==================== Compiling ===================='

		@vertex_shader = GLVertexShader.new(opts[:vertex_shader_source])
		@fragment_shader = GLFragmentShader.new(opts[:fragment_shader_source])

		@program = glCreateProgram
		glAttachShader(@program, @vertex_shader.shader)
		glAttachShader(@program, @fragment_shader.shader)

		glLinkProgram(@program)

		@uniform_to_location_hash = {}

		if (glGetProgramiv(@program, GL_LINK_STATUS) == true)
			ok!
			#puts 'Compilation Successful'
		else
			not_ok!
			puts "Shader Program compile error:"
			puts glGetProgramInfoLog(@program)
		end
	end

	def using
		glUseProgram(@program)
		yield self
		glUseProgram(0)
	end

	def find_uniform(name)
		location = @uniform_to_location_hash[name]
		return location if location

		location = glGetUniformLocation(@program, name) rescue nil
		puts "shader program ##{@program} uniform '#{name}' not found" unless location
		@uniform_to_location_hash[name] = location
		return location
	end

	def set_3f(name, value)
		id = find_uniform(name)
		glUniform3f(id, *(value.to_a)) if id
	end

	def set_f(name, value)
		id = find_uniform(name)
		glUniform1f(id, value) if id
	end

	def set_int(name, value)
		id = find_uniform(name)
		glUniform1i(id, value) if id
	end
end
