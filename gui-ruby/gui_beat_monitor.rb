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
			with_scale(on? ? ($env[:beat_scale].scale(1.1, 1.0)) : 1.0) {
				with_multiplied_alpha(on? ? ($env[:beat_scale].scale(1.0, 0.1)) : 0.0) {
					unit_square
				}
			}
		}
	end
end

class GuiBeatMonitor < GuiList
	def initialize(beats_per_measure)
		super()
		self << (@halve_bpm_button = GuiButton.new.set(:scale_x => 1.0, :scale_y => 1.0, :offset_x => 0.0, :offset_y => 0.0, :background_image => $engine.load_image('images/buttons/halve.png')))
		@halve_bpm_button.on_clicked { $engine.beat_half_time! }
		beats_per_measure.times { |i| self << GuiBeatLight.new.set_beat_index(i).set_beats_per_measure(beats_per_measure) }
		self << (@double_bpm_button = GuiButton.new.set(:scale_x => 1.0, :scale_y => 1.0, :offset_x => 0.0, :offset_y => 0.0, :background_image => $engine.load_image('images/buttons/double.png')))
		@double_bpm_button.on_clicked { $engine.beat_double_time! }
	end

	def click(pointer)
		$engine.beat!
	end
end
