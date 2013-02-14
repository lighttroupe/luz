class UserObjectSettingFloat
	def gui_build_editor
		box = GuiBox.new
		box << create_user_object_setting_name_label
		box << vbox = GuiVBox.new

		row = GuiBox.new	#.set(:scale_y => 0.5, :offset_y => 0.23)
			row << GuiFloat.new(self, :animation_min, @min, @max).set(:scale_x => 0.15, :float => :left)
			row << (@enable_animation_toggle=GuiToggle.new(self, :enable_animation).set(:scale_x => 0.07, :float => :left, :color => [1,0,0,1], :image => $engine.load_image('images/buttons/play.png')))
			row << (@animation_curve_widget=GuiCurve.new(self, :animation_curve).set(:scale_x => 0.15, :scale_y => 0.8, :float => :left, :opacity => 0.4))
			row << (@animation_max_widget=GuiFloat.new(self, :animation_max, @min, @max).set(:scale_x => 0.15, :float => :left, :opacity => 0.4))
			row << (@animation_every_text=BitmapFont.new.set(:string => 'every', :offset_x => 0.025, :scale_x => 0.1, :scale_y => 0.5, :float => :left, :opacity => 0.4))
			row << (@animation_repeat_number_widget=GuiFloat.new(self, :animation_repeat_number, 0.25, 128.0).set(:step_amount => 0.25, :scale_x => 0.2, :float => :left, :opacity => 0.4))
			row << (@animation_repeat_unit_widget=GuiSelect.new(self, :animation_repeat_unit, TIME_UNIT_OPTIONS).set(:scale_x => 0.15, :float => :left, :opacity => 0.4))

			@animation_widgets = [@animation_curve_widget, @animation_max_widget, @animation_every_text, @animation_repeat_number_widget, @animation_repeat_unit_widget]

			@enable_animation_toggle.on_clicked_with_init {
				if @enable_animation_toggle.on?
					@animation_widgets.each_with_index { |widget, index| widget.animate({:opacity => 1.0}, duration = (0.05 + (index * 0.2))) }
				else
					@animation_widgets.each_with_index { |widget, index| widget.animate({:opacity => 0.2}, duration = (0.05 + (index * 0.1))) }
				end
			}
		vbox << row

		# Row 2
		row = GuiBox.new	#.set(:scale_y => 0.5, :offset_y => -0.25)
			row << (@enable_activation_toggle=GuiToggle.new(self, :enable_activation).set(:scale_x => 0.07, :float => :left, :offset_x => 0.15, :color => [1,0,0,1], :image => $engine.load_image('images/buttons/play.png')))
			row << (@activation_curve_widget=GuiCurveIncreasing.new(self, :activation_curve).set(:scale_x => 0.15, :scale_y => 0.8, :float => :left, :opacity => 0.4))
			row << (@activation_direction_widget=GuiSelect.new(self, :activation_direction, ACTIVATION_DIRECTION_OPTIONS).set(:scale_x => 0.1, :float => :left, :opacity => 0.4))
			row << (@activation_value_widget=GuiFloat.new(self, :activation_value, @min, @max).set(:scale_x => 0.15, :float => :left, :opacity => 0.4))

			row << (@activation_when_text=BitmapFont.new.set(:string => 'when', :offset_x => 0.025, :scale_x => 0.1, :scale_y => 0.5, :float => :left, :opacity => 0.4))
			row << (@activation_variable_widget=GuiVariable.new(self, :activation_variable).set(:scale_x => 0.26, :float => :left, :opacity => 0.4, :no_value_text => 'variable'))

			@activation_widgets = [@activation_curve_widget, @activation_value_widget, @activation_direction_widget, @activation_when_text, @activation_variable_widget]

			@enable_activation_toggle.on_clicked_with_init {
				if @enable_activation_toggle.on?
					@activation_widgets.each_with_index { |widget, index| widget.animate({:opacity => 1.0}, duration = (0.05 + (index * 0.2))) }
				else
					@activation_widgets.each_with_index { |widget, index| widget.animate({:opacity => 0.2}, duration = (0.05 + (index * 0.1))) }
				end
			}
		vbox << row

		box
	end
end
