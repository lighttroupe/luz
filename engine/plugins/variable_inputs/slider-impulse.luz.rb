class VariableInputSliderImpulse < VariableInput
	title				"Slider Impulse"
	description "Treats slider input value as an upward impulse. The value falls back down to 0% according to a chosen gravity."

	categories :slider

	hint "Only registers a second impulse after the input value has returned to 0. Works well with MIDI drums which send the velocity of impact, then immediately send a 0 value."

	setting 'slider', :slider, :summary => true
	setting 'gravity_per_second', :float, :range => 0.0..5.0

	setting 'velocity_multiplier', :float, :range => 0.0..1.0, :default => 1.0..0.0

	def value
		@velocity ||= 0.0

		# add to velocity
		if slider > 0.0 and slider_setting.last_value == 0.0

			# stop all downward velocity on a hit (is this right?)
			#@velocity = 0.0 if @velocity < 0.0

			@velocity += (slider * velocity_multiplier)
		end

		# move output value by velocity
		v = (last_value + (@velocity * $env[:frame_time_delta])).clamp(0.0, 1.0)

		# hit the ceiling?
		if v == 1.0 and @velocity > 0.0
			@velocity = 0.0

		# hit the floor?
		elsif v == 0.0 and @velocity < 0.0
			@velocity = 0.0

		else
			# floating...
			@velocity -= (gravity_per_second * $env[:frame_time_delta]) if v > 0.0
		end

		return v
	end
end
