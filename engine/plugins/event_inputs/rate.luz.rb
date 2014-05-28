class EventInputRate < EventInput
	title				"Rate"
	description "Activates repeatedly with controllable rate."

	categories :special

	setting 'fastest', :timespan
	setting 'slowest', :timespan
	setting 'speed', :slider

	def value
		period = (speed * (fastest.to_seconds - slowest.to_seconds)) + slowest.to_seconds

		time_since_last_activation >= period
	end
end
