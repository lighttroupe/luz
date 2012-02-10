 ###############################################################################
 #  Copyright 2012 Ian McIntosh <ian@openanswers.org>
 #  Copyright 2012 ...
 ###############################################################################

include Drawing

class DirectorEffectGamePacMap < DirectorEffect
	title				'PacMap'
	description ""

	setting 'hero', :actor
	setting 'enemy', :actor

	#
	# after_load is called once at startup, and again after Ctrl-Shift-R reloads
	#
	def after_load
		super
	end

	#
	# tick is called once per frame, before rendering
	#
	def tick
		# $env[:frame_time_delta]  see Engine#update_environment in engine/engine.rb for more data
	end

	#
	# render is responsible for all drawing, and must yield to continue down the effects list
	#
	def render
		# TODO: draw map and creatures
		hero.one { |hero_actor|
			with_scale(0.1, 0.1) {
				hero_actor.render!
			}
		}
		yield
	end
end
