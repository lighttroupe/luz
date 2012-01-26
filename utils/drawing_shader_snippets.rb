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
	VERTEX_SHADER_HACK = "\nvoid main(void)\n{\ngl_Position = ftransform();\ngl_TexCoord[0] = gl_TextureMatrix[0] * gl_MultiTexCoord0;\ngl_FrontColor = gl_Color;\n}"

	$fragment_shader_snippet_stack = []		# clears when reloading this file
	$fragment_shader_object_stack = []
	$fragment_shader_uniform_stack = []
	$fragment_shader_snippet_cache ||= {}

	def with_fragment_shader_snippet(snippet, object)
		return yield unless snippet		# allow nil

		index = $fragment_shader_object_stack.count

		$fragment_shader_snippet_stack.push(snippet)
		$fragment_shader_object_stack.push(object)

		uniform_count = 0
		object.settings.each { |setting|
			if setting.shader?
				name = "snippet_#{index}_#{setting.name}"
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

	def with_compiled_shader
		return yield if $settings['no-shaders']

		return yield if $fragment_shader_snippet_stack.empty?
		$next_texture_number ||= 0

		program = $fragment_shader_snippet_cache[$fragment_shader_snippet_stack]
		unless program
			# Generate program for final code
			#section("Compiling shader program from #{$fragment_shader_snippet_stack.count} snippet(s)") {

				fragment_shader_source = join_fragment_shader_snippet_stack($fragment_shader_uniform_stack, $fragment_shader_snippet_stack, $fragment_shader_object_stack)
				vertex_shader_source = VERTEX_SHADER_HACK

				#puts fragment_shader_source

				program = GLShaderProgram.new(:vertex_shader_source => vertex_shader_source, :fragment_shader_source => fragment_shader_source)
				$fragment_shader_snippet_cache[$fragment_shader_snippet_stack] = program
			#}
		end

		if program.ok?
			program.using { |program|
				uniform_sampler_count = 0

				# texture0 is always the first texture unit (0)
				program.set_int('texture0', 0)

				#
				# Set collected uniform values
				#
				$fragment_shader_uniform_stack.each { |name_and_value|
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
			return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
		}

		void main(void)
		{
			vec4 output_rgba = gl_Color;				// the color from glColor
			vec2 texture_st = gl_TexCoord[0].st;	// the assigned texture coordinates

		"

		#
		# Replace uses of setting/uniform 'name' with 'snippet_0_name'
		#
		snippets_with_variables = snippets.collect_with_index { |snippet, index|
			object = objects[index]
			object.settings.each { |setting|
				if setting.shader?
					# TODO: improve find-and-replace
					snippet = snippet.gsub(setting.name, "snippet_#{index}_#{setting.name}")
				end
			}

			# Add brackets {} around snippet for local variable scoping and helpful comment
			snippet = "\n\t\t\t{ // shader snippet #{index}: #{object.class.title}\n" + snippet + "\n\t\t\t}\n"

			snippet
		}.join("\n")

		# sample the set GL texture (texture0), based on final texture_st, if the snippets don't do it
		# TODO: only if a texture is set?
		forced_texture_sample = snippets.last.include?('texture2D(texture0') ? '' : "\n\t\t\toutput_rgba *= texture2D(texture0, texture_st);"

		static_footer = "
			gl_FragColor = output_rgba;		// apply final color
		}
		"

		return [header, snippets_with_variables, forced_texture_sample, static_footer].join
	end
end
