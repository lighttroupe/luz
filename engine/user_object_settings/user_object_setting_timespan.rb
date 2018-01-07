require 'user_object_setting'

class UserObjectSettingTimespan < UserObjectSetting
	attr_accessor :time_number, :time_unit

	def to_yaml_properties
		super + ['@time_number', '@time_unit']
	end

	def after_load
		@time_number ||= (@options[:default] ? @options[:default][0] : (4))
		@time_unit ||= (@options[:default] ? @options[:default][1] : (:seconds))
	end

	#
	# ...
	#
	def instant?
		@time_number == 0
	end

	def to_seconds
		unit_and_number_to_time(@time_unit, @time_number)
	end

	def progress_since(time, beat=nil)
		return 1.0 if instant?

		if @time_unit == :beats
			return 0.0 if beat.nil?
			elapsed = $env[:beat] - beat
			(elapsed / @time_number).clamp(0.0, 1.0)
		else
			return 0.0 if time.nil?
			elapsed = $env[:time] - time
			elapsed = elapsed.abs		# NOTE: progress backwards in time works just as well
			(elapsed / self.to_seconds).clamp(0.0, 1.0)
		end
	end

	def delta
		return 1.0 if @time_number == 0.0

		if @time_unit == :beats
			$env[:beat_delta] / @time_number
		else
			$env[:time_delta] / @time_number
		end
	end

	def summary
		summary_format("#{@time_number} #{TIME_UNIT_SHORT[@time_unit]}")
	end
end
