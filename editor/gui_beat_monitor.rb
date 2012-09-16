class GuiBeatLight < GuiObject
	BEAT_ON_COLOR = [1,1,1,1]
	BEAT_OFF_COLOR = [0,0.1,0.1,0.5]

	easy_accessor :beat_index
	easy_accessor :beats_per_measure

	def on?
		($env[:beat_number] % beats_per_measure) == beat_index		# or only on the one frame... && $env[:is_beat]
	end

	def gui_render!
		with_color(on? ? BEAT_ON_COLOR : BEAT_OFF_COLOR) {
#			with_scale(on? ? ($env[:beat_scale].scale(1.5, 1.0)) : 1.0) {
			with_multiplied_alpha(on? ? ($env[:beat_scale].scale(2.0, 0.25)) : 0.25) {
				unit_square
			}
		}
	end
end

class GuiBeatMonitor < GuiList
	def initialize(beats_per_measure)
		super()
		beats_per_measure.times { |i| self << GuiBeatLight.new.set_beat_index(i).set_beats_per_measure(beats_per_measure) }
	end

	def click(pointer)
		$engine.beat!
	end
end
