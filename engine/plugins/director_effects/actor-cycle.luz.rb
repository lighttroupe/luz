require 'cycle_logic'

class DirectorEffectActorCycle < DirectorEffect
	virtual

	include CycleLogic

	title				"Actor Cycle"
	description "Moves between chosen actors using forwards and backwards events, showing at most two at a time."

	setting 'actors', :actors, :summary => 'tagged %'

	setting 'forwards', :event, :summary => '% forward'
	setting 'backwards', :event, :summary => '% backward'

	setting 'crossfade_time', :timespan, :summary => true

	def render
		@current_spot = cycle_update(@current_spot, (forwards.count - backwards.count), crossfade_time)

		low_index = @current_spot.floor
		crossfade_render(actors.one(low_index), actors.one(low_index+1), (@current_spot - low_index))

		yield
	end
end
