class GuiPreferencesBox < GuiBox
	def initialize
		super
	end

	def build
		self << GuiObject.new.set(:color => [0.2, 0.5, 0.2, 0.9])
		self << (@fps_label=GuiLabel.new.set_string("Frames Per Second").set(:scale_x => 0.05, :scale_y => 0.06, :offset_x => -0.42, :offset_y => 0.45))

		# NOTE: Directly sets $application.frames_per_second
		self << GuiInteger.new($application, :frames_per_second, 20, 70).set(:offset_x => 0.4, :offset_y => 0.45, :scale_x => 0.2, :scale_y => 0.1)
		self
	end

	def fps
		$settings['performer-fps']
	end
	def fps=(fps)
		$settings['performer-fps'] = fps
	end
end
