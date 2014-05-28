class VariableInputSliderLooperMeasure < VariableInput
	title				"Slider Looper Measure"
	description "Records named slider for the duration of a measure, then repeats for future measures."

	categories :slider

	setting 'slider', :slider, :summary => true
	setting 'record', :button
	setting 'number_of_measures', :integer, :range => 1..100, :default => 1..2

	def value
		if $engine.button_pressed_this_frame?(record)
			#
			# Begin Recording
			#
			@recording = true
			@record_next_measure = false
			@starting_measure = $env[:measure]
			@starting_measure_scale = $env[:measure_scale]
			@samples = Array.new
		end

		if @recording
			@samples << slider

			if $env[:measure] > (@starting_measure + number_of_measures)
				#
				# End Recording
				#
				@recording = false
			end

			return @samples.last		# Pass-through the current value

		else
			#
			# Not recording current value
			#
			if @samples
				progress = ($env[:measure_scale] + @starting_measure_scale) % 1.0
				@samples[(progress * (@samples.size - 1)).floor]
			else
				slider
			end
		end
	end
end
