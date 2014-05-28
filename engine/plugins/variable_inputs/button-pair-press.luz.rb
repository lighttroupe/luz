class VariableInputButtonPairPress < VariableInput
	title				"Button Pair Press"
	description "Activation rises with each press of one button, lowers with each press of a different button."

	categories :button

	setting 'button_on', :button, :summary => '% on'
	setting 'number_on', :integer, :range => 1..100, :default => 1..100
	setting 'button_off', :button, :summary => '% off'
	setting 'number_off', :integer, :range => 1..100, :default => 1..100

	setting 'starting_value', :float, :simple => true, :default => 0.0..1.0

	def value
		return starting_value if first_frame?

		new_value = last_value
		new_value += (1.0 / number_on) if $engine.button_pressed_this_frame?(button_on)
		new_value -= (1.0 / number_off) if $engine.button_pressed_this_frame?(button_off)
		new_value
	end
end
