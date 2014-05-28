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
