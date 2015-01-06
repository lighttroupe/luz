class GuiSettingsWindow < GuiWindow
	FRAMES_PER_SECONDS_MIN = 12
	FRAMES_PER_SECONDS_MAX = 70

	def initialize
		super
		self << @background = GuiObject.new.set(:background_image => $engine.load_image('images/settings-window-background.png'))

		# FPS
		self << GuiLabel.new.set_string("Frames Per Second").set(:width => 13, :text_align => :left, :scale_x => 0.5, :scale_y => 0.06, :offset_x => -0.13, :offset_y => 0.47)
		self << GuiInteger.new(self, :frames_per_second, FRAMES_PER_SECONDS_MIN, FRAMES_PER_SECONDS_MAX).set(:width => 2, :offset_x => -0.45, :scale_x => 0.1, :offset_y => 0.47, :scale_y => 0.05)

		# live editing
		#self << GuiLabel.new.set_string("Live Editing").set(:width => 13, :text_align => :left, :scale_x => 0.5, :scale_y => 0.06, :offset_x => -0.13, :offset_y => 0.41)
		#self << GuiToggle.new(self, :live_editing).set(:offset_x => -0.425, :scale_x => 0.05, :offset_y => 0.40, :scale_y => 0.05)

		# value animation time
		self << GuiLabel.new.set_string("Value Animation Time").set(:width => 13, :text_align => :left, :scale_x => 0.5, :scale_y => 0.06, :offset_x => -0.13, :offset_y => 0.35)
		self << GuiFloat.new(self, :value_animation_time, 0.1, 30.0, digits=1).set(:width => 3, :offset_x => -0.45, :scale_x => 0.1, :offset_y => 0.345, :scale_y => 0.05)
		self << GuiLabel.new.set_string("seconds").set(:color => [0.35,0.35,0.35], :width => 5, :text_align => :right, :scale_x => 0.15, :scale_y => 0.03, :offset_x => -0.39, :offset_y => 0.31)

		# default to value animation
		#self << GuiLabel.new.set_string("Animate Value Changes").set(:width => 13, :text_align => :right, :scale_x => 0.5, :scale_y => 0.06, :offset_x => -0.25, :offset_y => 0.41)
		#self << GuiToggle.new(self, :live_editing).set(:offset_x => 0.05, :scale_x => 0.05, :offset_y => 0.40, :scale_y => 0.05)
	end

	def frames_per_second
		$settings['frames-per-second']
	end
	def frames_per_second=(fps)
		$application.frames_per_second = fps
		$settings['frames-per-second'] = fps
	end

	def live_editing
		$settings['live-editing']
	end
	def live_editing=(le)
		$settings['live-editing'] = le
	end

	def value_animation_time
		$settings['value-animation-time']
	end
	def value_animation_time=(le)
		$settings['value-animation-time'] = le
	end
end