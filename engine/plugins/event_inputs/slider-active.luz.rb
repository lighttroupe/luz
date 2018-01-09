class EventInputSliderActive < EventInput
	title				"Slider Active"
	description "Activates while slider is moving and turns off a short time after it stops moving."

	categories :slider

	setting 'slider', :slider, :summary => true
	setting 'seconds_after', :float, :simple => true, :summary => true, :range => 0.0..60.0 :default => 0.2..0.2

	def value
		now = Time.now.to_f
		if @on_until && now < @on_until
			true
		else
			@previous_value ||= slider
			if slider != @previous_value
				@on_until = now + seconds_after
				@previous_value = slider
				true
			else
				false
			end
		end
	end
end
