require 'cycle_logic'

class ProjectEffectDirectorCycle < ProjectEffect
	include CycleLogic

	title				"Director Cycle"
	description "Moves between chosen directors using forwards and backwards events, showing at most two at a time."

	setting 'directors', :directors, :summary => true

	setting 'forwards', :event, :summary => '% forward'
	setting 'backwards', :event, :summary => '% back'

	setting 'crossfade_time', :timespan, :summary => true

	def render
		@current_spot = cycle_update(@current_spot, (forwards.count - backwards.count), crossfade_time)

		low_index = @current_spot.floor
		crossfade_render(directors.one(low_index), directors.one(low_index+1), (@current_spot - low_index))
		yield
	end
end
