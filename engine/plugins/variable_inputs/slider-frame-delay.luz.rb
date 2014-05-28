class VariableInputSliderFrameDelay < VariableInput
	title				"Slider Frame Delay"
	description "Saves slider values, and replays them a chosen number of frames in the future."

	categories :slider

	setting 'slider', :slider, :summary => true
	setting 'frames', :integer, :range => 0..100, :default => 30..60, :summary => '% frames'

	def value
		@samples ||= Array.new

		# add one new value
		@samples << slider

		# save oldest value
		v = @samples.first

		# remove old values (more than one, because 'frames' can change on us)
		to_remove = @samples.size - (frames)		# this will be 1 most of the time
		to_remove.times { @samples.shift }

		v
	end
end
