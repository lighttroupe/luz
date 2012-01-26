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

module DrawingColor
	def current_color_array
		GL.GetDoublev(GL::CURRENT_COLOR)
	end

	def current_color
		Color.new(current_color_array)
	end

	def with_color(color)
		saved = GL.GetColorArray
		c = color.to_a
		GL.Color([c[0], c[1], c[2], (c[3] || 1.0) * (saved[3] || 1.0)])		# NOTE: doesn't set alpha-- instead multiplies it
		yield
		GL.Color(*saved)
	end
	#conditional :with_color

	def with_color_and_alpha(color)
		saved = GL.GetColorArray
		GL.Color(*color.to_a)
		yield
		GL.Color(*saved)
	end
	#conditional :with_color_and_alpha

	def with_alpha(alpha)
		saved = GL.GetColorArray
		#GL.Color(*color.to_a)
		GL.Color([saved[0], saved[1], saved[2], alpha])
		yield
		GL.Color(*saved)
	end

	def with_multiplied_alpha(multiplier)
		return yield if multiplier == 1.0

		saved = GL.GetDoublev(GL::CURRENT_COLOR)
		c = saved.dup			# TODO: can we avoid this?
		c[3] *= multiplier
		GL.Color(*c)
		yield
		GL.Color(*saved)
	end

	def with_gl_blend_function(a, b)
		# TODO: get/set old mode
		GL.BlendFunc(a, b)
		yield
		GL.BlendFunc(GL::SRC_ALPHA, GL::ONE_MINUS_SRC_ALPHA)
	end

	def with_gl_color_logic_op(op)
		# TODO: get/set old mode
		GL.Enable(GL::COLOR_LOGIC_OP)
		GL.LogicOp(op)
		yield
		GL.Disable(GL::COLOR_LOGIC_OP)
	end

	def with_gl_blend_equation(mode)
		# TODO: get/set old mode
		GL.BlendEquationEXT(mode)
		yield
		GL.BlendEquationEXT(GL::FUNC_ADD_EXT)
	end

	DRAW_METHOD_OPTIONS = [[:average, 'Average'], [:brighten, 'Brighten'], [:darken, 'Darken'], [:multiply, 'Multiply'], [:invert, 'Invert'], [:min, 'Min'], [:max, 'Max']]
	def with_pixel_combine_function(name)
		return yield unless name

		case name
		#
		# Average, the default mode
		# Set ((source * alpha) + (dest * (1 - alpha))) as destination
		#
		when :average
			with_gl_blend_function(GL::SRC_ALPHA, GL::ONE_MINUS_SRC_ALPHA) {
				with_gl_blend_equation(GL::FUNC_ADD_EXT) {
					yield
				}
			}

		#
		# Brighten ("Screen" in Photoshop terms)
		# Add (source * alpha) to destination pixel
		#
		when :brighten
			with_gl_blend_equation(GL::FUNC_ADD_EXT) {
				with_gl_blend_function(GL::SRC_ALPHA, GL::ONE) {
					yield
				}
			}

		#
		# Darken
		# Subtract (source * alpha) from destination pixel
		#
		when :darken
			with_gl_blend_function(GL::SRC_ALPHA, GL::ONE) {
				with_gl_blend_equation(GL::FUNC_REVERSE_SUBTRACT_EXT) {		# (Cd*df - Cs*sf)
					yield
				}
			}

		#
		# Multiply
		# Set (source * destination) as destination pixel (NOTE: ignores alpha)
		#
		when :multiply
			with_gl_blend_function(GL::DST_COLOR, GL::ZERO) {
				with_gl_blend_equation(GL::FUNC_ADD_EXT) {
					yield
				}
			}

		#
		# Invert
		# Set (source ^ destination) as destination color (NOTE: ignores alpha)
		#
		# NOTE: XOR is like INVERT when source is white: (WHITE ^ destination) == (!destination)
		#       but, unlike INVERT, respects an alternate source color when set
		#
		when :invert then with_gl_color_logic_op(GL::XOR) { yield }

		#
		# Min
		# Sets min(source, destination) as destination (for each RGB component)
		#
		when :min then with_gl_blend_equation(GL::MIN_EXT) { yield }

		#
		# Max
		# Sets max(source, destination) as destination (for each RGB component)
		#
		when :max then with_gl_blend_equation(GL::MAX_EXT) { yield }

		else # do nothing
			yield
		end
	end

	#
	# Alpha Test
	#
	def with_alpha_test(alpha_cutoff)
		if GL.IsEnabled(GL::ALPHA_TEST)
			GL.AlphaFunc(GL::GREATER, alpha_cutoff)
			yield
		else
			GL.Enable(GL::ALPHA_TEST)
			GL.AlphaFunc(GL::GREATER, alpha_cutoff)
			yield
			GL.Disable(GL::ALPHA_TEST)
		end
	end
end
