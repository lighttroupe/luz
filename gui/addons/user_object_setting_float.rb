class UserObjectSettingRenderer < GuiBox
	def create_user_object_setting_name_label
		@name_label ||= GuiLabel.new.set(:width => 30, :string => @setting.name.gsub('_',' '), :color => [1.0,1.0,1.0,1.0], :scale_x => 1.0, :scale_y => 0.35, :offset_x => -0.02, :offset_y => 0.40)
	end
end

class UserObjectSettingFloatRenderer < UserObjectSettingRenderer
	def initialize(setting)
		super()
		@setting = setting
		@min = @setting.min
		@max = @setting.max
		create!
	end

	def grab_keyboard_focus!
		@vbox.grab_keyboard_focus!
	end

private

	def create!
		self << create_user_object_setting_name_label
		self << @vbox = GuiVBox.new

		row = GuiHBox.new	#.set(:scale_y => 0.5, :offset_y => 0.23)
			row << GuiFloat.new(@setting, :animation_min, @min, @max).set(:scale_x => 0.15, :float => :left)

			unless @setting.options[:simple]
				row << (@enable_animation_toggle=GuiToggle.new(@setting, :enable_animation).set(:scale_x => 0.07, :float => :left, :color => [1,0,0,1], :image => $engine.load_image('images/buttons/play.png')))
				row << (@animation_curve_widget=GuiCurve.new(@setting, :animation_curve).set(:scale_x => 0.15, :scale_y => 0.8, :float => :left, :opacity => 0.4))
				row << (@animation_max_widget=GuiFloat.new(@setting, :animation_max, @min, @max).set(:scale_x => 0.15, :float => :left, :opacity => 0.4))
				row << (@animation_every_text=GuiLabel.new.set(:width => :fill, :string => 'every', :offset_x => 0.025, :scale_x => 0.1, :scale_y => 0.5, :float => :left, :opacity => 0.4))
				row << (@animation_repeat_number_widget=GuiFloat.new(@setting, :animation_repeat_number, 0.25, 128.0).set(:step_amount => 0.25, :scale_x => 0.2, :float => :left, :opacity => 0.4))
				row << (@animation_repeat_unit_widget=GuiSelect.new(@setting, :animation_repeat_unit, UserObjectSettingFloat::TIME_UNIT_OPTIONS).set(:scale_x => 0.15, :float => :left, :opacity => 0.4))

				@animation_widgets = [@animation_curve_widget, @animation_max_widget, @animation_every_text, @animation_repeat_number_widget, @animation_repeat_unit_widget]

				@enable_animation_toggle.on_clicked_with_init {
					if @enable_animation_toggle.on?
						@animation_widgets.each_with_index { |widget, index| widget.animate({:opacity => 1.0}, duration = (0.05 + (index * 0.2))) }
					else
						@animation_widgets.each_with_index { |widget, index| widget.animate({:opacity => 0.2}, duration = (0.05 + (index * 0.1))) }
					end
				}
			end
		@vbox << row

		# Row 2
		row = GuiHBox.new	#.set(:scale_y => 0.5, :offset_y => -0.25)
		unless @setting.options[:simple]
			row << (@enable_enter_exit_button=GuiEnterExitButton.new(@setting).set(:scale_x => 0.15, :scale_y => 0.9, :offset_x => -0.425, :offset_y => -0.08))

			@enable_enter_exit_button.on_clicked { |pointer|
				if @enter_exit_popup
					@enter_exit_popup.animate({:scale_x => 0.0, :scale_y => 0.0}, 0.05) {
						@enter_exit_popup.remove_from_parent!
						@enter_exit_popup = nil
					}
				else
					$gui << (@enter_exit_popup=GuiEnterExitPopup.new(@setting).set(:offset_x => pointer.x, :offset_y => pointer.y - 0.035, :scale_x => 0.0, :scale_y => 0.03).animate({:scale_x => 0.25, :scale_y => 0.05}, duration=0.25))

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

			row << (@enable_activation_toggle=GuiToggle.new(@setting, :enable_activation).set(:scale_x => 0.07, :float => :left, :offset_x => 0.15, :color => [1,0,0,1], :image => $engine.load_image('images/buttons/play.png')))
			row << (@activation_curve_widget=GuiCurveIncreasing.new(@setting, :activation_curve).set(:scale_x => 0.15, :scale_y => 0.8, :float => :left, :opacity => 0.4))
			row << (@activation_direction_widget=GuiSelect.new(@setting, :activation_direction, UserObjectSettingFloat::ACTIVATION_DIRECTION_OPTIONS).set(:scale_x => 0.1, :float => :left, :opacity => 0.4))
			row << (@activation_value_widget=GuiFloat.new(@setting, :activation_value, @min, @max).set(:scale_x => 0.15, :float => :left, :opacity => 0.4))

			row << (@activation_when_text=GuiLabel.new.set(:width => :fill, :string => 'when', :offset_x => 0.025, :scale_x => 0.1, :scale_y => 0.5, :float => :left, :opacity => 0.4))
			row << (@activation_variable_widget=GuiVariable.new(@setting, :activation_variable).set(:scale_x => 0.26, :float => :left, :opacity => 0.4, :no_value_text => 'variable'))

			@activation_widgets = [@activation_curve_widget, @activation_value_widget, @activation_direction_widget, @activation_when_text, @activation_variable_widget]

			@enable_activation_toggle.on_clicked_with_init {
				if @enable_activation_toggle.on?
					@activation_widgets.each_with_index { |widget, index| widget.animate({:opacity => 1.0}, duration = (0.05 + (index * 0.2))) }
				else
					@activation_widgets.each_with_index { |widget, index| widget.animate({:opacity => 0.2}, duration = (0.05 + (index * 0.1))) }
				end
			}
		end
		@vbox << row
	end
end

class UserObjectSettingFloat
	attr_accessor :min, :max, :enable_enter_animation, :enable_exit_animation, :options

	def gui_build_editor
		UserObjectSettingFloatRenderer.new(self)
	end
end
