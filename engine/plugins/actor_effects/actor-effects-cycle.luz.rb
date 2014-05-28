class ActorEffectActorEffectsCycle < ActorEffect
	require 'cycle-logic'
	include CycleLogic

	title				'Actor Effects Cycle'
	description ""

	categories :special

	setting 'actors', :actors, :summary => 'tagged %'

	setting 'forwards', :event, :summary => '% forward'
	setting 'backwards', :event, :summary => '% backward'

	setting 'crossfade_time', :timespan, :summary => true

	def render
		@current_spot = cycle_update(@current_spot, (forwards.count - backwards.count), crossfade_time)
		low_index = @current_spot.floor
		first, second, progress = actors.one(low_index), actors.one(low_index+1), (@current_spot - low_index)
		use_first = (first && (progress != 1.0))
		use_second = (second && (progress != 0.0))
		if use_first
			with_enter_and_exit(1.0, progress) {
				first.render_recursive {
					if use_second
						with_enter_and_exit(progress, 0.0) {
							second.render_recursive { yield }
						}
					else
						yield
					end
				}
			}
		elsif use_second
			with_enter_and_exit(progress, 0.0) {
				second.render_recursive { yield }
			}
		end 
	end
end
