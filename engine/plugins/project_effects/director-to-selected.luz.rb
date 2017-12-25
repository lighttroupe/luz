require 'cycle_logic'

class ProjectEffectDirectorToSelected < ProjectEffect
	include CycleLogic

	title				"Director Fade to Selected"
	description ""

	setting 'starting_director', :director

	setting 'forwards', :event, :summary => '% forward'

	setting 'crossfade_time', :timespan, :summary => true

	def tick
		@from_director ||= starting_director.one
		@to_directors_queue ||= []

		if forwards.now?
			chosen_director = $gui.chosen_next_director
			if chosen_director
				if @to_director
					@to_directors_queue << chosen_director
				else
					begin_transition_to_director(chosen_director)
				end
			end
		end
	end

	def render
		if @to_director
			progress = crossfade_time.progress_since(@crossfade_start, @crossfade_start_beat)
			crossfade_render(@from_director, @to_director, progress)
			if progress == 1.0
				@from_director = @to_director
				begin_transition_to_director(@to_directors_queue.shift)
			end
		else
			@from_director.render! if @from_director
		end
		yield
	end

	def begin_transition_to_director(director)
		@to_director = director
		@crossfade_start_time = $env[:time]
		@crossfade_start_beat = $env[:beat]
	end
end
