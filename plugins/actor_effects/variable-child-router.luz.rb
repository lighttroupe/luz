 ###############################################################################
 #  Copyright 2012 Ian McIntosh <ian@openanswers.org>
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

class ActorEffectVariableChildRouter < ActorEffect
	title				"Variable Child Router"
	description "Routes values from one of a consecutive series of input variables to the chosen output variable. The routing depends on the child number: the first input variable while rendering the first child, the second for the second child, etc."

	hint "Put this after an effect that creates children, and before one or more effects that respond to the chosen output variable."

	setting 'first_input', :variable, :summary => '% input'
	setting 'input_count', :integer, :range => 1..999, :summary => true

	setting 'output', :variable, :summary => '% output'

	def render
		output_variable = output_setting.variable
		return yield unless output_variable

		first_index = $engine.project.variables.index(first_input_setting.variable)
		return yield unless first_index

		index = first_index + (child_index % input_count)

		input_variable = $engine.project.variables[index]
		return yield unless input_variable

		value = input_variable.do_value

		output_variable.with_value(value) {
			yield
		}
	end
end
