module EngineTime
	def init_time
		@simulation_speed = 1.0
		@last_frame_time = 0.0
		@total_frame_times = 0.0
		@add_to_engine_time = 0.0
		@time = 0.0
	end

	def reset_time!
		@time = 0.0
	end

	def add_to_engine_time(amount)
		@add_to_engine_time += amount
	end

	def update_time(outside_time)
		@frame_time = outside_time		# Real-World Time
		@frame_time_delta = @frame_time - @last_frame_time

		# Engine time (modified by simulation speed)
		@time_delta = (@simulation_speed * (@frame_time_delta)) + @add_to_engine_time
		@time += @time_delta
		@add_to_engine_time = 0.0
	end

	def record_frame_time
		frame_start = Time.now
		yield
		@total_frame_times += (Time.now - frame_start)
	end

	def average_frame_time
		@total_frame_times / @frame_number
	end

	def average_frames_per_second
		@frame_number / @total_frame_times
	end
end
