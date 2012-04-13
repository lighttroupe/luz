 ###############################################################################
 #  Copyright 2011 Ian McIntosh <ian@openanswers.org>
 #
 #  This program is free software; you can redistribute it and/or modify
 #  it under the terms of the GNU General Public License as published by
 #  the Free Software Foundation; either version 2 of the License, or
 #  (at your option) any later version.
 #
 #  This program is distributed in the hope that it will be useful,
 #  but WITHOUT ANY WARRANTY; without even the implied warranty of
 #  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 #  GNU Library General Public License for more details.
 #
 #  You should have received a copy of the GNU General Public License
 #  along with this program; if not, write to the Free Software
 #  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 ###############################################################################

require 'gl_fragment_shader', 'gl_vertex_shader', 'gl_shader_program'

module DrawingShaderSnippets
	#
	# Shader Snippets Stitching
	#
	FRAGMENT_SHADER_STUB = "
		uniform sampler2D texture0;

		float rand(vec2 co)
		{
			return fract(sin(dot(co.xy, vec2(12.9898,78.233))) * 43758.5453);
		}

		void main(void)
		{
			vec4 output_rgba = gl_Color;				// the color from glColor
			vec2 texture_st = gl_TexCoord[0].st;	// the assigned texture coordinates
			output_rgba *= texture2D(texture0, texture_st);
			gl_FragColor = output_rgba;		// apply final color
		}
		"

	VERTEX_SHADER_STUB = "
		void main(void)
		{
			gl_Position = ftransform();
			gl_TexCoord[0] = gl_TextureMatrix[0] * gl_MultiTexCoord0;
			gl_FrontColor = gl_Color;
		}
		"

	$fragment_shader_snippet_stack = []		# clears when reloading this file
	$fragment_shader_object_stack = []
	$fragment_shader_uniform_stack = []
	$fragment_shader_snippet_cache ||= {}

	$vertex_shader_snippet_stack = []		# clears when reloading this file
	$vertex_shader_object_stack = []
	$vertex_shader_uniform_stack = []
	$vertex_shader_snippet_cache = {}

	$shader_program_cache ||= Hash.new { |hash, key| hash[key] = {} }

	def enable_shaders?
		return $enable_shaders unless $enable_shaders.nil?		# no decision yet?
		$enable_shaders = !(($settings['no-shaders'] == true) || (($settings['no-shaders-in-1.8'] == true) && RUBY_VERSION <= '1.9.0'))		# respect no-shader request only in 1.8, where we have known shader compilation crashes on Intel 3100-ish cards
	end

	def with_fragment_shader_snippet(snippet, object)
		return yield unless (snippet and enable_shaders?)		# allow nil

		index = $fragment_shader_object_stack.count

		$fragment_shader_snippet_stack.push(snippet)
		$fragment_shader_object_stack.push(object)

		uniform_count = 0
		object.settings.each { |setting|
			if setting.shader?
				name = "fragment_snippet_#{index}_#{setting.name}"
				value = setting.immediate_value
				$fragment_shader_uniform_stack.push([name, value])
				uniform_count += 1
			end
		}

		yield

		uniform_count.times {
			$fragment_shader_uniform_stack.pop
		}
		$fragment_shader_object_stack.pop
		$fragment_shader_snippet_stack.pop
	end

	def with_vertex_shader_snippet(snippet, object)
		return yield unless (snippet and enable_shaders?) 		# allow nil

		index = $vertex_shader_object_stack.count

		$vertex_shader_snippet_stack.push(snippet)
		$vertex_shader_object_stack.push(object)

		uniform_count = 0
		object.settings.each { |setting|
			if setting.shader?
				name = "vertex_snippet_#{index}_#{setting.name}"
				value = setting.immediate_value
				$vertex_shader_uniform_stack.push([name, value])
				uniform_count += 1
			end
		}

		yield

		uniform_count.times {
			$vertex_shader_uniform_stack.pop
		}
		$vertex_shader_object_stack.pop
		$vertex_shader_snippet_stack.pop
	end

	def with_compiled_shader
		return yield unless enable_shaders?

		return yield if $fragment_shader_snippet_stack.empty? and $vertex_shader_snippet_stack.empty?
		$next_texture_number ||= 0

		fragment_shader_source = $fragment_shader_snippet_cache[$fragment_shader_snippet_stack]
		unless fragment_shader_source
			fragment_shader_source = join_fragment_shader_snippet_stack($fragment_shader_uniform_stack, $fragment_shader_snippet_stack, $fragment_shader_object_stack)
			#puts fragment_shader_source
			$fragment_shader_snippet_cache[$fragment_shader_snippet_stack] = fragment_shader_source
		end
		vertex_shader_source = $vertex_shader_snippet_cache[$vertex_shader_snippet_stack]
		unless vertex_shader_source
			vertex_shader_source = join_vertex_shader_snippet_stack($vertex_shader_uniform_stack, $vertex_shader_snippet_stack, $vertex_shader_object_stack)
			#puts vertex_shader_source
			$vertex_shader_snippet_cache[$vertex_shader_snippet_stack] = vertex_shader_source
		end

		program = $shader_program_cache[fragment_shader_source][vertex_shader_source]
		unless program
			program = GLShaderProgram.new(:vertex_shader_source => vertex_shader_source, :fragment_shader_source => fragment_shader_source)
			$shader_program_cache[fragment_shader_source][vertex_shader_source] = program
		end

		if program.ok?
			program.using { |program|
				uniform_sampler_count = 0

				# texture0 is always the first texture unit (0)
				program.set_int('texture0', 0)

				#
				# Set collected uniform values
				#
				($fragment_shader_uniform_stack + $vertex_shader_uniform_stack).each { |name_and_value|
					case name_and_value[1]
					when Float
						program.set_f(name_and_value[0], name_and_value[1])
					when Integer
						program.set_int(name_and_value[0], name_and_value[1])
					when UserObjectSettingImage
						image = name_and_value[1].one		# get one Image from the UserObjectSettingImage
						texture_id = ((image) ? (image.texture_id) : 0)
						next if texture_id == 0

						# Choose next texture unit and put texture in it
						$next_texture_number += 1

						#puts "setting unit #{$next_texture_number} to #{texture_id}"

						GL.ActiveTexture(GL_TEXTURE0 + $next_texture_number)
						GL.BindTexture(GL::TEXTURE_2D, texture_id)
						program.set_int(name_and_value[0], $next_texture_number)
						uniform_sampler_count += 1
					end
				}

				yield

				# The only thing that needs to be undone is the selected texture unit
				if uniform_sampler_count > 0
					$next_texture_number -= uniform_sampler_count
					GL.ActiveTexture(GL_TEXTURE0 + $next_texture_number)
					#puts "setting texture unit #{$next_texture_number}"
				end
			}
		else
			yield
		end
	end

	def join_fragment_shader_snippet_stack(uniforms, snippets, objects)
		return FRAGMENT_SHADER_STUB if snippets.empty?

		#
		# Source code for uniforms declarations at top of shader scripts
		#
		uniforms = uniforms.collect { |name_and_value|
			case name_and_value[1]
			when Float
				"uniform float #{name_and_value[0]};"
			when Integer
				"uniform int #{name_and_value[0]};"
			when UserObjectSettingImage
				"uniform sampler2D #{name_and_value[0]};"
			end
		}.join("\n\t\t")

		#
		# Static header
		#
		header = "
		uniform sampler2D texture0;
		#{uniforms}

		float rand(vec2 co)
		{
			return fract(sin(dot(co.xy, vec2(12.9898,78.233))) * 43758.5453);
		}

		void main(void)
		{
			vec4 output_rgba = gl_Color;				// the color from glColor
			vec2 texture_st = gl_TexCoord[0].st;	// the assigned texture coordinates
			vec4 pixel_xyzw = gl_FragCoord;	// the assigned texture coordinates

		"

		#
		# Replace uses of setting/uniform 'name' with 'snippet_0_name'
		#
		snippets_with_variables = snippets.collect_with_index { |snippet, index|
			object = objects[index]
			object.settings.each { |setting|
				if setting.shader?
					# TODO: improve find-and-replace
					snippet = snippet.gsub(setting.name, "fragment_snippet_#{index}_#{setting.name}")
				end
			}

			# Add brackets {} around snippet for local variable scoping and helpful comment
			snippet = "\n\t\t\t{ // fragment shader snippet #{index}: #{object.class.title}\n#{snippet}\n\t\t\t}\n"

			snippet
		}.join("\n")

		# sample the set GL texture (texture0), based on final texture_st, if the snippets don't do it
		# TODO: only if a texture is set?
		forced_texture_sample = snippets.last.include?('texture2D(texture0') ? '' : "\n\t\t\toutput_rgba *= texture2D(texture0, texture_st);" unless snippets.empty?

		footer = "
			gl_FragColor = output_rgba;		// apply final color
		}
		"

		return [header, snippets_with_variables, forced_texture_sample, footer].join
	end

	def join_vertex_shader_snippet_stack(uniforms, snippets, objects)
		return VERTEX_SHADER_STUB if snippets.empty?

		#
		# Source code for uniforms declarations at top of shader scripts
		#
		uniforms = uniforms.collect { |name_and_value|
			case name_and_value[1]
			when Float
				"uniform float #{name_and_value[0]};"
			when Integer
				"uniform int #{name_and_value[0]};"
			when UserObjectSettingImage
				"uniform sampler2D #{name_and_value[0]};"
			end
		}.join("\n\t\t")

		#
		# Static header
		#
		header = "
		#{uniforms}

		float rand(vec2 co)
		{
			return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
		}

		void main(void)
		{
			vec4 vertex = ftransform();
			vec4 texture_st = (gl_TextureMatrix[0] * gl_MultiTexCoord0);
		"

		#
		# Replace uses of setting/uniform 'name' with 'snippet_0_name'
		#
		snippets_with_variables = snippets.collect_with_index { |snippet, index|
			object = objects[index]
			object.settings.each { |setting|
				if setting.shader?
					# TODO: improve find-and-replace
					snippet = snippet.gsub(setting.name, "vertex_snippet_#{index}_#{setting.name}")
				end
			}

			# Add brackets {} around snippet for local variable scoping and helpful comment
			snippet = "\n\t\t\t//{ // vertex shader snippet #{index}: #{object.class.title}\n#{snippet}\n\t\t\t//}\n"

			snippet
		}.join("\n")

		footer = "
			gl_Position = vertex;
			gl_TexCoord[0] = texture_st;
			gl_FrontColor = gl_Color;
		}
		"

		return [header, snippets_with_variables, footer].join
	end
end
