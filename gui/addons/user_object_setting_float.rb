class UserObjectSettingFloat
	attr_accessor :min, :max, :enable_enter_animation, :enable_exit_animation

	pipe :grab_keyboard_focus, :vbox

	def gui_build_editor
		box = GuiBox.new
		box << create_user_object_setting_name_label
		box << @vbox = GuiVBox.new.set(:scale_y => 0.9)

		row = GuiHBox.new	#.set(:scale_y => 0.5, :offset_y => 0.23)
			row << GuiFloat.new(self, :animation_min, @min, @max).set(:scale_x => 0.15, :float => :left)

			unless @options[:simple]
				row << (@enable_animation_toggle=GuiToggle.new(self, :enable_animation).set(:scale_x => 0.07, :float => :left, :color => [1,0,0,1], :image => $engine.load_image('images/buttons/play.png')))
				row << (@animation_curve_widget=GuiCurve.new(self, :animation_curve).set(:scale_x => 0.13, :scale_y => 0.8, :float => :left, :opacity => 0.0, :hidden => true))
				row << (@animation_max_widget=GuiFloat.new(self, :animation_max, @min, @max).set(:scale_x => 0.15, :float => :left, :opacity => 0.0, :hidden => true))
				row << (@animation_every_text=GuiLabel.new.set(:width => 4, :text_align => :center, :string => 'every', :offset_x => 0.025, :scale_x => 0.1, :float => :left, :opacity => 0.0, :hidden => true))
				row << (@animation_repeat_number_widget=GuiFloat.new(self, :animation_repeat_number, 0.25, 128.0).set(:step_amount => 0.25, :scale_x => 0.2, :float => :left, :opacity => 0.0, :hidden => true))
				row << (@animation_repeat_unit_widget=GuiSelect.new(self, :animation_repeat_unit, UserObjectSettingFloat::TIME_UNIT_OPTIONS).set(:width => 5, :text_align => :left, :scale_x => 0.15, :float => :left, :opacity => 0.0, :hidden => true))

				@animation_widgets = [@animation_curve_widget, @animation_max_widget, @animation_every_text, @animation_repeat_number_widget, @animation_repeat_unit_widget]

				@enable_animation_toggle.on_clicked_with_init {
					if @enable_animation_toggle.on?
						@animation_widgets.each_with_index { |widget, index| widget.animate({:opacity => 1.0, :hidden => false}, duration = (0.05 + (index * 0.3))) }
					else
						@animation_widgets.each_with_index { |widget, index| widget.animate({:opacity => 0.05, :hidden => true}, duration = (0.2)) }
					end
				}
			end
		@vbox << row

		# Row 2
		row = GuiHBox.new	#.set(:scale_y => 0.5, :offset_y => -0.25)
		unless @options[:simple]
			row << (@enable_enter_exit_button=GuiEnterExitButton.new(self).set(:scale_x => 0.15, :scale_y => 0.9, :offset_x => -0.425, :offset_y => -0.08))

			@enable_enter_exit_button.on_clicked { |pointer|
				if @enter_exit_popup
					@enter_exit_popup.animate({:scale_x => 0.0, :scale_y => 0.0}, 0.05) {
						@enter_exit_popup.remove_from_parent!
						@enter_exit_popup = nil
					}
				else
					$gui << (@enter_exit_popup=GuiEnterExitPopup.new(self).set(:offset_x => pointer.x, :offset_y => pointer.y - 0.035, :scale_x => 0.0, :scale_y => 0.03).animate({:scale_x => 0.25, :scale_y => 0.05}, duration=0.25))

					pointer.capture_object!(@enter_exit_popup) { |click_object|		# callback is for a click
						if @enter_exit_popup.include?(click_object)
							pointer.click_on(click_object)
							true
						else
							@enter_exit_popup.animate({:scale_x => 0.0, :scale_y => 0.0}, 0.05) {
								@enter_exit_popup.remove_from_parent!
								@enter_exit_popup = nil
							}
							pointer.uncapture_object!
							false
						end
					}
				end
			}

			row << (@enable_activation_toggle=GuiToggle.new(self, :enable_activation).set(:scale_x => 0.07, :float => :left, :offset_x => 0.15, :color => [1,0,0,1], :image => $engine.load_image('images/buttons/play.png')))
			row << (@activation_curve_widget=GuiCurveIncreasing.new(self, :activation_curve).set(:scale_x => 0.13, :scale_y => 0.8, :float => :left, :opacity => 0.0, :hidden => true))
			row << (@activation_direction_widget=GuiSelect.new(self, :activation_direction, UserObjectSettingFloat::ACTIVATION_DIRECTION_OPTIONS).set(:width => 4, :text_align => :center, :scale_x => 0.1, :float => :left, :opacity => 0.0, :hidden => true))
			row << (@activation_value_widget=GuiFloat.new(self, :activation_value, @min, @max).set(:scale_x => 0.15, :float => :left, :opacity => 0.0, :hidden => true))

			row << (@activation_when_text=GuiLabel.new.set(:string => 'when', :width => 4, :text_align => :center, :scale_x => 0.1, :float => :left, :opacity => 0.0, :hidden => true))
			row << (@activation_variable_widget=GuiVariable.new(self, :activation_variable).set(:no_value_text => 'variable', :scale_x => 0.26, :float => :left, :opacity => 0.0, :hidden => true))

			@activation_widgets = [@activation_curve_widget, @activation_value_widget, @activation_direction_widget, @activation_when_text, @activation_variable_widget]

			@enable_activation_toggle.on_clicked_with_init {
				if @enable_activation_toggle.on?
					@activation_widgets.each_with_index { |widget, index| widget.animate({:opacity => 1.0, :hidden => false}, duration = (0.05 + (index * 0.3))) }
				else
					@activation_widgets.each_with_index { |widget, index| widget.animate({:opacity => 0.05, :hidden => true}, duration = (0.2)) }
				end
			}
		end
		@vbox << row
		box
	end
end
