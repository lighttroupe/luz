 ###############################################################################
 #  Copyright 2011 Ian McIntosh <ian@openanswers.org>
 #
 #  This program is free software; you can redistribute it and/or modify
 #  it under the terms of the GNU General Public License as published by
 #  the Free Software Foundation; either version 2 of the License, or
 #  (at your option) any later version.
 #
 #  This program is distributed in the hope that it will be useful,
 #  but WITHOUT ANY WARRANTY; without even the implied warranty of
 #  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 #  GNU Library General Public License for more details.
 #
 #  You should have received a copy of the GNU General Public License
 #  along with this program; if not, write to the Free Software
 #  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 ###############################################################################

require 'cycle-logic'
require 'safe_eval'

class ProjectEffectGameLevelControl < ProjectEffect
	include CycleLogic

	title				"Game Level Control"
	description "Manages level rendering, level switching."

	setting 'directors', :directors, :summary => true
	setting 'reset', :event

	setting 'on_level_switch', :string, :multiline => true
	setting 'on_reset', :string, :multiline => true

	YES, NO = 'yes', 'no'

	include SafeEval

	def render
		#
		# Sane defaults
		#
		@crossfade_progress ||= 0.0
		@last_progress ||= 0.0
		@current_director = directors.one if @kickstarted.nil?
		@kickstarted = true

		#
		# 
		#
		if reset.on_this_frame?
			puts "game-level-control: hard reset"
			@crossfade_progress = 0.0
			@last_progress = 0.0
			@current_director, @next_director, @crossfade_actor = nil, directors.one, nil
			@next_director_crossfade_start_time = $env[:time]
			@next_director_crossfade_duration = 2.0
			safe_eval(on_reset)
		end

		#if @do_level_init
		#	@do_level_init = false
		#end

		#
		# Map Feature: 'next-director: director name' on triggers
		#
		if ((next_director=$env[:next_director]) and @next_director.nil?)
			$stderr.puts "game-level-control: switching to #{next_director}..."
			@next_director = find_director_by_name(next_director)
			if @next_director
				@next_director_crossfade_start_time = $env[:time]
				@next_director_crossfade_duration = ($env[:next_director_fade_time] || 0.0)
				@crossfade_actor = find_actor_by_name($env[:next_director_fade_actor])
				@crossfade_progress = 0.0

				if @next_director_crossfade_duration <= 0.0
					@current_director = @next_director
					@next_director = nil
				end

				# Reset this for good measure
				$env[:next_director] = nil
			else
				$stderr.puts "game-level-control: error: director #{next_director} not found"
			end
		end

		# Figure out progress of enter/exit crossfading
		if @next_director
			@crossfade_progress += ((1.0/30.0) * (1.0 / @next_director_crossfade_duration))

			if @crossfade_progress < 0.5
				with_enter_and_exit(1.0, @crossfade_progress / 0.5) {
					@current_director.render!
				} if @current_director
			elsif (@crossfade_progress >= 0.5 and @last_progress < 0.5)
				@crossfade_progress = 0.5		# draw perfectly 0.5 this frame
				@reset_level = true					# next frame, we'll reset the level

				with_env(:game_level_shutdown, true) {
					@current_director.render!
				} if @current_director

				safe_eval(on_level_switch)

			else
				with_enter_and_exit((@crossfade_progress - 0.5) / 0.5, 0.0) {
					# reset level?
					with_env(:game_level_reset, @reset_level) {
						@next_director.render!
					}
					@reset_level = false
				} if @next_director
			end

			# Render the crossfade actor on top if present
			with_enter_exit_progress(@crossfade_progress) {
				#puts sprintf("%0.2f at %0.5f frame %d", @crossfade_progress, Time.now.to_f, $env[:frame_number])
				aspect_scale = $env[:aspect_scale] || 1.0
				with_scale(aspect_scale, aspect_scale) {
					@crossfade_actor.render!
				}
			} if @crossfade_actor

			# Make the switch final if done
			@current_director, @next_director = @next_director, nil if @crossfade_progress >= 1.0

			@last_progress = @crossfade_progress
		else
			# Normal rendering of a level
			@current_director.render! if @current_director
		end

		yield
	end
end
