class EventInputTimePeriod < EventInput
	title				"Time Period"
	description "Activates periodically."

	categories :special

	setting 'period', :timespan, :summary => true

	def value
		return false if period.instant?
		($env[:time] / period.to_seconds).floor > ($env[:previous_time] / period.to_seconds)
	end
end
