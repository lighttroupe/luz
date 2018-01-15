multi_require 'beat_detector'

module EngineBeats
	def init_beats
		@beat_detector = BeatDetector.new
	end

	def beat!
		@beat_detector.beat!(@frame_time)
	end

	pipe :update_beats, :beat_detector, :method => :tick
	pipe :beat_zero!, :beat_detector
	pipe :next_beat_is_zero!, :beat_detector
	pipe :beat_double_time!, :beat_detector
	pipe :beat_half_time!, :beat_detector
	pipe :beats_per_minute, :beat_detector
	pipe :beats_per_minute=, :beat_detector
end
