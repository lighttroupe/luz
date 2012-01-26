module CycleLogic
	def cycle_update(current_spot, desired_spot, time)
		return desired_spot if time.instant?

		current_spot ||= 0.0

		if current_spot != desired_spot
			travel_distance = time.delta		# percent we've traveled through crossfade time is also how far to travel between actors (distance 1.0)

			if current_spot < desired_spot
				current_spot += travel_distance
				current_spot = desired_spot if current_spot > desired_spot
			else
				current_spot -= travel_distance
				current_spot = desired_spot if current_spot < desired_spot
			end
		end

		return current_spot
	end

	def crossfade_render(first, second, progress)
		with_enter_and_exit(1.0, progress) { first.render! } if (first and (progress != 1.0))
		with_enter_and_exit(progress, 0.0) { second.render! } if (second and (progress != 0.0))
	end
end
