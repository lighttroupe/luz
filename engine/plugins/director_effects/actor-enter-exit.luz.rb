class DirectorEffectActorEnterExit < DirectorEffect
	virtual

	title				"Actor Enter/Exit"
	description "Puts a single actor on stage with enter and exit events."

	setting 'actor', :actor, :summary => true
	setting 'enter', :event, :summary => true
	setting 'enter_time', :timespan
	setting 'exit', :event, :summary => true
	setting 'exit_time', :timespan

	def render
		# If we weren't drawn last frame, reset to off
		if (@last_update_frame.nil?) or (@last_update_frame < ($env[:frame_number] - 1))
			@entering, @exiting = false, false
			@enter, @exit = 0.0, 0.0
		end

		#
		# Change state?
		#
		if enter.on_this_frame?
			@entering, @exiting = true, false
			@enter, @exit = 0.0, 0.0
		end
		if exit.on_this_frame?
			@exiting = true 
		end

		# Make progress...
		@enter = ((enter_time.instant?) ? 1.0 : (@enter + ($env[:frame_time_delta] / enter_time.to_seconds))).clamp(0.0, 1.0) if @entering
		@exit = ((exit_time.instant?) ? 1.0 : (@exit + ($env[:frame_time_delta] / exit_time.to_seconds))).clamp(0.0, 1.0) if @exiting

		#
		# Render
		#
		if @enter > 0.0 and @exit < 1.0
			with_enter_and_exit(@enter, @exit) {
				actor.render!
			}
		end

		yield

		@last_update_frame = $env[:frame_number]
	end
end
