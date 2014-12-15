class GuiEnterExitPopup < GuiWindow
	def initialize(object)
		@object = object
		super()
		create!
	end

	def create!
		# Background
		self << (@background=GuiObject.new.set(:background_image => $engine.load_image('images/enter-exit-popup.png')))

		self << (@enter_value_widget=GuiFloat.new(@object, :enter_value, @object.min, @object.max, digits=2).set(:scale_x => 0.20, :scale_y => 0.8, :float => :left))
		self << (@enter_curve_widget=GuiCurveIncreasing.new(@object, :enter_curve).set(:scale_x => 0.20, :scale_y => 0.8, :float => :left))
		self << (@enable_enter_toggle=GuiToggle.new(@object, :enable_enter_animation).set(:scale_x => 0.1, :float => :left, :color => [1,0,0,1], :image => $engine.load_image('images/buttons/enter.png')))

		@enter_widgets = [@enter_value_widget, @enter_curve_widget]

		@enable_enter_toggle.on_clicked_with_init {
			if @enable_enter_toggle.on?
				@enter_widgets.each_with_index { |widget, index| widget.animate({:opacity => 1.0}, duration = (0.05 + (index * 0.2))) }
			else
				@enter_widgets.each_with_index { |widget, index| widget.animate({:opacity => 0.2}, duration = (0.05 + (index * 0.1))) }
			end
		}

		self << (@enable_exit_toggle=GuiToggle.new(@object, :enable_exit_animation).set(:scale_x => 0.1, :float => :left, :color => [1,0,0,1], :image => $engine.load_image('images/buttons/exit.png')))
		self << (@exit_curve_widget=GuiCurveIncreasing.new(@object, :exit_curve).set(:scale_x => 0.20, :scale_y => 0.8, :float => :left))
		self << (@exit_value_widget=GuiFloat.new(@object, :exit_value, @object.min, @object.max, digits=2).set(:scale_x => 0.20, :scale_y => 0.8, :float => :left))

		@exit_widgets = [@exit_curve_widget, @exit_value_widget]

		@enable_exit_toggle.on_clicked_with_init {
			if @enable_exit_toggle.on?
				@exit_widgets.each_with_index { |widget, index| widget.animate({:opacity => 1.0}, duration = (0.05 + (index * 0.2))) }
			else
				@exit_widgets.each_with_index { |widget, index| widget.animate({:opacity => 0.2}, duration = (0.05 + (index * 0.1))) }
			end
		}
	end
end
