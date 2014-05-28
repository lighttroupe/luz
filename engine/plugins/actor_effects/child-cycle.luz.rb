require 'cycle_logic'

class ActorEffectChildCycle < ActorEffect
	include CycleLogic

	title				"Child Cycle"
	description "Causes children to enter and exit, where at most two are visible at a time."

	categories :child_consumer

	setting 'forwards', :event, :summary => '% forward'
	setting 'backwards', :event, :summary => '% backward'
	setting 'crossfade_time', :timespan, :summary => true

	hint "Future effects should respond to enter and exit."

	def tick
		@current_spot = cycle_update(@current_spot, (forwards.count - backwards.count), crossfade_time)
	end

	def render
		low_index = @current_spot.floor % total_children
		high_index = (low_index + 1) % total_children
		progress = (@current_spot - @current_spot.floor)
		if (child_index == low_index) && (progress != 1.0)
			with_enter_and_exit(1.0, progress) {
				yield
			}
		end

		if (child_index == high_index) && (progress != 0.0)
			with_enter_and_exit(progress, 0.0) {
				yield
			}
		end
	end
end
