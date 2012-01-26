 ###############################################################################
 #  Copyright 2006 Ian McIntosh <ian@openanswers.org>
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

class BeatDetector
	BEATS_FOR_CALCULATION = 3
	ACCEPTABLE_BEAT_VARIATION = 0.04		# in seconds

	attr_reader :is_beat, :progress, :seconds_per_beat, :beat_number, :beats_per_measure

	def initialize
		self.beats_per_minute = 60		# One beat per second (arbitrary)

		@time = @last_beat_time = 0.0		# This works for both controlled time and human time
		@beats = [@time] * BEATS_FOR_CALCULATION				# By starting full, we don't have to handle the "filling" condition below

		@next_planned_beat_time = @last_beat_time + @seconds_per_beat
		@progress = 0.0
		@beat_number = 0
		@beats_per_measure = 4
		@last_tapped_beat_frame = -1

		@beat_double = 0
	end

	def beat_double_time! ; @beat_double += 1 ; end
	def beat_half_time! ; @beat_double -= 1 ; end

	def tick(time)
		@time = time
		elapsed = (@time - @last_beat_time)

		if @time > @next_planned_beat_time
			@is_beat = true
			@beat_number += 1

			if @next_beat_is_zero
				unless (@beat_number % @beats_per_measure) == 0
					@beat_number += @beats_per_measure - (@beat_number % @beats_per_measure)
				end
				@next_beat_is_zero = false
			end

			if @new_seconds_per_beat
				# Install new BPM time, if present
				@seconds_per_beat, @new_seconds_per_beat = @new_seconds_per_beat, nil
			end

			if @beat_double != 0
				@seconds_per_beat /= (2 ** @beat_double)
				@seconds_per_beat = 8.0 if @seconds_per_beat > 8.0
				@seconds_per_beat = 0.1 if @seconds_per_beat < 0.1
				@beat_double = 0
			end

			# Now in the past, make a note that this beat was reported
			@last_beat_time = @next_planned_beat_time

			# Move @next_planned_beat_time forward, depending on whether we recently got a tap
			if @last_tapped_beat_time
				@next_planned_beat_time = @last_tapped_beat_time + @seconds_per_beat		# TODO: be able to skip ahead beats?
				@last_tapped_beat_time = nil

				# Move ahead one extra beat if it would produce a closer-to-normal beat time (avoid a really short beat)
				@next_planned_beat_time += @seconds_per_beat if (@next_planned_beat_time - @last_beat_time) < (@seconds_per_beat / 2.0)

			# Have we been sleeping for a long time?
			elsif elapsed > (4 * @seconds_per_beat)
				# ...skip ahead.  This probably means the beat is now wrong, but that was almsot certainly the case anyway
				# ...this elsif block prevents the beat monitor from flipping out
				@last_beat_time = @time
				@next_planned_beat_time = @time + @seconds_per_beat
			else
				@next_planned_beat_time += @seconds_per_beat
			end
		else
			@is_beat = false
		end
		@progress = (@time - @last_beat_time) / (@next_planned_beat_time - @last_beat_time)
	end

	def next_beat_is_zero!
		@next_beat_is_zero = true
	end

	def beat_zero!
		@next_beat_is_zero = true
		beat!
	end

	def beat!(beat_time)
		# Ignore cases of two beat signals very close together (plus it's just not reasonable to have beats as close as one frame apart)
		return if (@last_tapped_beat_frame >= ($env[:frame_number] - 1))

		@beats.shift
		@beats.push(beat_time)

		# Update beat time if the last N taps were very evenly spaced (likely-intentional beat tapping)
		min, max, avg = @beats.delta_min_max_avg
		@new_seconds_per_beat = avg if (max - min) <= ACCEPTABLE_BEAT_VARIATION

		@last_tapped_beat_time, @last_tapped_beat_frame = beat_time, $env[:frame_number]
	end

	def beats_per_minute
		60.0 / @seconds_per_beat	# TODO: could produce a 1/0 here ?
	end

	def beats_per_minute=(rhs)
		@seconds_per_beat = 60.0 / rhs
	end
end
