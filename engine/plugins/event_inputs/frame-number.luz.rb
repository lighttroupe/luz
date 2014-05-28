class EventInputFrameNumber < EventInput
	title				"Frame Number"
	description "Activates once on chosen frame number."

	categories :special

	setting 'frame_number', :integer, :range => 1..1000000, :summary => true

	def value
		$env[:frame_number] == frame_number
	end
end
