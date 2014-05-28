class VariableInputButtonPress < VariableInput
	title				"Button Press"
	description "Activation rises with each press of a button, lowers constantly."

	categories :button

	setting 'button_on', :button
	setting 'number_on', :integer, :range => 1..100, :default => 1..100
	setting 'off_time', :timespan

	setting 'starting_value', :float, :simple => true, :default => 0.0..1.0

	def value
		return starting_value if first_frame?

		if $engine.button_pressed_this_frame?(button_on)
			last_value + (1.0 / number_on)
		elsif off_time.instant?
			0.0
		else
			last_value - ($env[:frame_time_delta] / off_time.to_seconds)
		end
	end
end
