class GuiBeatLight < GuiObject
	BEAT_ON_COLOR = [1,1,1,1]
	BEAT_OFF_COLOR = [0,0,0,1]

	easy_accessor :beat_index

	def on?
		($env[:beat_number] % 4) == beat_index
	end

	def gui_render!
		with_color(on? ? BEAT_ON_COLOR : BEAT_OFF_COLOR) {
			unit_square
		}
	end
end

class GuiBeatMonitor < GuiList
	def initialize
		super
		4.times { |i| self << GuiBeatLight.new.set_beat_index(i) }
	end

	def click(pointer)
		$engine.beat!
	end
end
