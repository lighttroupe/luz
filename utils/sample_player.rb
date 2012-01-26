class SamplePlayer
	Sample = Struct.new(:time, :name, :value)

	def initialize(samples, time_offset=0.0)
		@samples, @time_offset = samples, time_offset
		@last_time = 0.0
		@next_index = 0
	end

	def on_sample(&proc)
		@proc = proc
	end

	def move_to_time(time)
		time += @time_offset

		if @last_time
			if time < @last_time
				# reset to 0 then go forward to time
				@last_time = 0.0
				@next_index = 0
				move_forward_to_time(time) if time > 0.0
			elsif time > @last_time
				# move forward to time
				move_forward_to_time(time)
			end
		else
			# move forward to time
			move_forward_to_time(time) if time > 0.0
		end
	end

private

	def move_forward_to_time(time)
		while (sample=@samples[@next_index]) and (time >= sample.time)
			@proc.call(sample.name, sample.value)
			@next_index += 1
		end
		@last_time = time
	end
end
