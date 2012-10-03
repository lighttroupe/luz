require 'gui_selected_behavior'

class UserObjectSetting
	include GuiPointerBehavior
	BACKGROUND_COLOR = [1,1,0,0.5]

	def gui_build_editor
		GuiObject.new.set(:color => [0,1,1,1])
	end

	def create_user_object_setting_name_label
		@name_label ||= BitmapFont.new.set(:color => [1.0,1.0,1.0,0.9], :string => name.gsub('_',' '), :scale_x => 1.0, :scale_y => 0.35, :offset_x => -0.02, :offset_y => 0.44, :color => [0.5,0.5,0])
	end
end

class UserObjectSettingTheme
	def gui_build_editor
		box = GuiBox.new
		box << GuiTheme.new(self, :theme).set(:scale_x => 0.25, :scale_y => 0.75, :float => :left, :offset_x => 0.02, :offset_y => -0.08)
		box << create_user_object_setting_name_label
		box
	end
end

class UserObjectSettingFloat
	def gui_build_editor
		box = GuiBox.new
		box << create_user_object_setting_name_label
		row = GuiBox.new.set(:scale_y => 0.5, :offset_y => 0.23)
			row << GuiFloat.new(self, :animation_min, @min, @max).set(:scale_x => 0.15, :float => :left)
			row << (@enable_animation_toggle=GuiToggle.new(self, :enable_animation).set(:scale_x => 0.07, :float => :left, :color => [1,0,0,1], :image => $engine.load_image('images/buttons/play.png')))
			row << (@animation_curve_widget=GuiCurve.new(self, :animation_curve).set(:scale_x => 0.15, :scale_y => 0.8, :float => :left, :opacity => 0.4))
			row << (@animation_max_widget=GuiFloat.new(self, :animation_max, @min, @max).set(:scale_x => 0.15, :float => :left, :opacity => 0.4))
			row << (@animation_every_text=BitmapFont.new.set(:string => 'every', :offset_x => 0.025, :scale_x => 0.1, :scale_y => 0.5, :float => :left, :opacity => 0.4))
			row << (@animation_repeat_number_widget=GuiFloat.new(self, :animation_repeat_number, 0.25, 128.0).set(:step_amount => 0.25, :scale_x => 0.2, :float => :left, :opacity => 0.4))
			row << (@animation_repeat_unit_widget=GuiSelect.new(self, :animation_repeat_unit, TIME_UNIT_OPTIONS).set(:scale_x => 0.15, :float => :left, :opacity => 0.4))
			box << row

			@animation_widgets = [@animation_curve_widget, @animation_max_widget, @animation_every_text, @animation_repeat_number_widget, @animation_repeat_unit_widget]

			@enable_animation_toggle.on_clicked_with_init {
				if @enable_animation_toggle.on?
					@animation_widgets.each_with_index { |widget, index| widget.animate({:opacity => 1.0}, duration = (0.05 + (index * 0.2))) }
				else
					@animation_widgets.each_with_index { |widget, index| widget.animate({:opacity => 0.2}, duration = (0.05 + (index * 0.1))) }
				end
			}

		# Row 2
		row = GuiBox.new.set(:scale_y => 0.5, :offset_y => -0.25)
			row << (@enable_activation_toggle=GuiToggle.new(self, :enable_activation).set(:scale_x => 0.07, :float => :left, :offset_x => 0.15, :color => [1,0,0,1], :image => $engine.load_image('images/buttons/play.png')))
			row << (@activation_curve_widget=GuiCurveIncreasing.new(self, :activation_curve).set(:scale_x => 0.15, :scale_y => 0.8, :float => :left, :opacity => 0.4))
			row << (@activation_direction_widget=GuiSelect.new(self, :activation_direction, ACTIVATION_DIRECTION_OPTIONS).set(:scale_x => 0.1, :float => :left, :opacity => 0.4))
			row << (@activation_value_widget=GuiFloat.new(self, :activation_value, @min, @max).set(:scale_x => 0.15, :float => :left, :opacity => 0.4))

			row << (@activation_when_text=BitmapFont.new.set(:string => 'when', :offset_x => 0.025, :scale_x => 0.1, :scale_y => 0.5, :float => :left, :opacity => 0.4))
			row << (@activation_variable_widget=GuiVariable.new(self, :activation_variable).set(:scale_x => 0.26, :float => :left, :opacity => 0.4, :no_value_text => 'variable'))
			box << row

			@activation_widgets = [@activation_curve_widget, @activation_value_widget, @activation_direction_widget, @activation_when_text, @activation_variable_widget]

			@enable_activation_toggle.on_clicked_with_init {
				if @enable_activation_toggle.on?
					@activation_widgets.each_with_index { |widget, index| widget.animate({:opacity => 1.0}, duration = (0.05 + (index * 0.2))) }
				else
					@activation_widgets.each_with_index { |widget, index| widget.animate({:opacity => 0.2}, duration = (0.05 + (index * 0.1))) }
				end
			}

		box
	end
end

class UserObjectSettingInteger
	def gui_build_editor
		box = GuiBox.new
		box << create_user_object_setting_name_label
		box << GuiInteger.new(self, :animation_min, @min, @max).set(:scale_x => 0.3, :float => :left, :scale_y => 0.5, :offset_y => 0.25)
		box
	end
end

class UserObjectSettingSelect
	def gui_build_editor
		box = GuiBox.new
		box << create_user_object_setting_name_label
		box << GuiSelect.new(self, :selected, @options[:options]).set(:scale_x => 1.0, :scale_y => 0.5, :offset_y => 0.25)
		box
	end
end

class UserObjectSettingCurve
	def gui_build_editor
		box = GuiBox.new
		box << create_user_object_setting_name_label
		box << GuiCurve.new(self, :curve).set(:scale_x => 0.15, :scale_y => 0.4, :float => :left, :offset_x => 0.04, :offset_y => 0.14)
		box
	end
end

class UserObjectSettingCurveIncreasing
	def gui_build_editor
		box = GuiBox.new
		box << create_user_object_setting_name_label
		box << GuiCurveIncreasing.new(self, :curve).set(:scale_x => 0.15, :scale_y => 0.4, :float => :left, :offset_x => 0.04, :offset_y => 0.14)
		box
	end
end

class UserObjectSettingActor
	def gui_build_editor
		box = GuiBox.new
		box << create_user_object_setting_name_label
		box << GuiActor.new(self, :actor)
		box
	end
end

class UserObjectSettingEvent
	def gui_build_editor
		box = GuiBox.new
		box << create_user_object_setting_name_label
		box << GuiEvent.new(self, :event)
		box
	end
end

class UserObjectSettingVariable
	def gui_build_editor
		box = GuiBox.new
		box << create_user_object_setting_name_label
		box << GuiVariable.new(self, :variable)
		box
	end
end

class UserObjectSettingTimespan
	def gui_build_editor
		box = GuiBox.new
		box << create_user_object_setting_name_label
		box << GuiFloat.new(self, :time_number, 0.0, 999.0).set(:float => :left, :scale_x => 0.20, :scale_y => 0.5)
		box << GuiSelect.new(self, :time_unit, TIME_UNIT_OPTIONS).set(:float => :left, :scale_x => 0.25, :scale_y => 0.5)
		box
	end
end

class UserObjectSettingButton
	def gui_build_editor
		box = GuiBox.new
		box << create_user_object_setting_name_label
		box << GuiEngineButton.new(self, :button).set(:scale_y => 0.5)
		box
	end
end

class UserObjectSettingSlider
	def gui_build_editor
		box = GuiBox.new
		box << create_user_object_setting_name_label
		box << GuiEngineSlider.new(self, :slider).set(:scale_x => 0.5, :float => :left, :scale_y => 0.5, :offset_y => 0.0)
		box
	end
end

class UserObject
	include MethodsForGuiObject

	def has_settings_list?
		!@gui_settings_list.nil?
	end

	def gui_build_editor
		if respond_to? :effects
			box = GuiBox.new

			# Two-lists side by side
			@gui_effects_list = GuiList.new(effects).set({:spacing_y => -0.8, :scale_x => 0.29, :offset_x => -0.35, :scale_y => 0.87, :offset_y => -0.06, :item_aspect_ratio => 3.0})
			box << @gui_effects_list

			@gui_settings_list = GuiList.new.set({:spacing_y => -1.0, :scale_x => 0.69, :offset_x => 0.15, :scale_y => 0.87, :offset_y => -0.06, :item_aspect_ratio => 4.0})
			box << @gui_settings_list

			gui_fill_settings_list(self)		# show this object's settings

			box
		else
			GuiObject.new		# nothing
		end
	end

	def gui_fill_settings_list(user_object)
		return unless @gui_settings_list

		@gui_effects_list.clear_selection! if user_object == self

		@gui_settings_list.clear!
		user_object.settings.each { |setting|
			@gui_settings_list << setting.gui_build_editor
		}
	end

	def on_child_user_object_selected(user_object)
		gui_fill_settings_list(user_object)
		@gui_effects_list.set_selection(user_object) if @gui_effects_list
	end

	#
	#
	#
	def gui_render!
		# Label
		gui_render_background
		gui_render_label
	end

	def hit_test_render!
		with_unique_hit_test_color_for_object(self, 0) { unit_square }
	end

	def click(pointer)
		$gui.build_editor_for(self, :pointer => pointer)
		@parent.child_click(pointer)
	end

	LABEL_COLOR_CRASHY = [1,0,0,0.5]
	LABEL_COLOR_ENABLED = [1,1,1,1]
	LABEL_COLOR_DISABLED = [1.0, 1.0, 1.0, 0.25]
	USER_OBJECT_TITLE_HEIGHT = 0.65
	def label_color
		if crashy?
			LABEL_COLOR_CRASHY
		elsif enabled?
			LABEL_COLOR_ENABLED
		else
			LABEL_COLOR_DISABLED
		end
	end

	def gui_render_label
		with_color(label_color) {
			@title_label ||= BitmapFont.new.set(:string => title, :scale_x => 0.95, :scale_y => USER_OBJECT_TITLE_HEIGHT)
			if pointer_hovering?
				@title_label.gui_render!
			else
				with_vertical_clip_plane_right_of(0.5) {
					@title_label.gui_render!
				}
			end
		}
	end
end

# HACK to render an object without reparenting it
class GuiObjectRenderer < GuiObject
	callback :clicked

	attr_reader :object

	def initialize(object)
		@object = object
	end

	def gui_render!
		return if hidden?
		gui_render_background
		if @object.respond_to? :gui_render!
			@object.gui_render!		# TODO: send a symbol for customizable render method (ie simple curves)
		else
			with_color([rand,rand,rand,1]) {
				unit_square
			}
		end
	end

	def gui_tick!
		@object.gui_tick! if @object.respond_to? :gui_tick!
	end

	def click(pointer)
		clicked_notify(pointer)
	end
end

class ChildUserObject

	def long_click(pointer)
		toggle_enabled!
	end

	def draggable?
		true		# needed for list reordering
	end

	def drag_out(pointer)
		if pointer.drag_delta_y > 0
			parent.move_child_up(self)
		else
			parent.move_child_down(self)
		end
	end

	def gui_render!
		gui_render_background
		gui_render_label
	end
end

class Actor
	def gui_render!
		gui_render_background
		render!

		# Label and shading effect
		if pointer_hovering?
			# TODO: add a shading helper
			with_translation(-0.35, -0.35) {
				with_scale(0.25, 0.25) {
					gui_render_label
				}
			}
		else
#			with_multiplied_alpha(0.5) {
#				gui_render_label
#			}
		end
	end
end

class Theme
	def gui_build_editor
		box = GuiBox.new
		box << GuiGrid.new(effects).set(:min_columns => 4)
		box << (@add_button=GuiButton.new.set(:scale_x => 0.075, :scale_y => 0.15, :offset_x => -0.5, :offset_y => 0.5, :background_image => $engine.load_image('images/buttons/menu.png')))
		@add_button.on_clicked {
			effects << Style.new
			GL.DestroyList(@gui_render_styles_list) ; @gui_render_styles_list = nil
		}
		box
	end

	def gui_render!
		gui_render_styles

		# Label and shading effect
		if pointer_hovering?
			# TODO: draw darkening layer
			gui_render_label
		end
	end

	def gui_render_styles
		@gui_render_styles_list = GL.RenderCached(@gui_render_styles_list) {
			if effects.size > 8
				num_rows = 4
			else
				num_rows = 2
			end
			num_columns = num_rows * 2

			width = 1.0 / num_columns
			height = 1.0 / num_rows

			with_scale(width, height) {
				with_translation(-num_columns/2.0 + 0.5, -num_rows/2.0 - 0.5) {
					index = 0
					for y in (0...num_rows)
						for x in (0...num_columns)
							with_translation(x, (num_rows - y)) {
								break if index >= effects.size
								with_scale(0.85) {
									effects[index].gui_render!
								}
							}
							index += 1
						end
					end
				}
			}
		}
	end
end

class Curve
	UP_COLOR = [0.35, 0.75, 0.25, 1.0]
	DOWN_COLOR = [0.80, 0.0, 0.0, 1.0]
	MIDDLE_COLOR = [0.95, 0.50, 0.0, 1.0]
	LOOPING_COLOR = [0.8, 0.8, 0.0, 1.0]
	MISC_COLOR = [0.5, 0.5, 0.8, 1.0]
	FLOOR_COLOR = [0.0, 0.0, 0.0, 0.9]

	def gui_build_editor
		GuiObjectRenderer.new(self)
	end

	def gui_icon_color
		if up?					# lower left to upper right (/)
			UP_COLOR
		elsif down?			# upper left to lower right (\)
			DOWN_COLOR
		elsif middle?		# starts and ends on 0.5 (~)
			MIDDLE_COLOR
		elsif looping?	# starts and ends on same value
			LOOPING_COLOR
		else						# anything else
			MISC_COLOR
		end
	end

	POINTS_IN_ICON = 200

	def gui_render!
		gui_render_background

		if pointer_hovering?
			progress = ($env[:beat] % 4.0) / 4.0

			with_clip_box {
				with_scale(8.0) {
					with_translation(0.5 - progress, 0.5 - value(progress)) {
						#unit_square_outline
						with_translation(-1.0, 0.0) {
							gui_render_curve
						}
						gui_render_curve
						with_translation(1.0, 0.0) {
							gui_render_curve
						}
						with_translation(0.0, -1) {
							with_scale(3.0, 1.0) {
								with_color(FLOOR_COLOR) {
									unit_square
								}
							}
						}
					}
				}
			}

			gui_render_label
		else
			gui_render_curve
		end
	end

	def gui_render_curve
		with_color(gui_icon_color) {
			@gui_render_list = GL.RenderCached(@gui_render_list) {
				with_translation(-0.5, -0.5) {
					vertices = []
					GL.Begin(GL::TRIANGLE_STRIP)
						GL.Vertex(0.0, 0.0)
						POINTS_IN_ICON.times { |i|
							GL.Vertex(x=(i * 1.0/POINTS_IN_ICON), value(x))
							GL.Vertex(((i+1) * 1.0/POINTS_IN_ICON), 0.0)
						}
						GL.Vertex(1.0, value(1.0))
						GL.Vertex(1.0, 0.0)
					GL.End
				}
			}
		}
	end
end

class Style
	def gui_render!
		using_listsafe { unit_square }
	end
end

class Variable
	GUI_COLOR = [0.0,1.0,0.5,0.7]
	MARKER_COLOR = [0.8,0.0,0.0,0.15]

	def gui_render!
		gui_render_background

		# Status Indicator
		#with_vertical_clip_plane_right_of(value - 0.5) {
		if (v=do_value) > 0.0
			with_translation(-0.5 + v/2.0, 0.0) {
				with_scale_unsafe(v, 1.0) {
					with_color(GUI_COLOR) {
						unit_square
					}
				}
			}
		end

		#Value Display
		with_translation(0.45, 0.25) {
			@value_label ||= BitmapFont.new.set(:scale_x => 0.35, :scale_y => 0.35)
			@value_label.set_string((value * 100).to_i.to_s + '%')
			@value_label.gui_render!
		}

		# Status Marker
		#with_translation(0.0, -0.4) {
		#	with_scale(0.01, 0.25) {
		#		with_color(MARKER_COLOR) {
		#			unit_square
		#		}
		#	}
		#}
		#with_translation(0.25, -0.45) {
		#	with_scale(0.01, 0.15) {
		#		with_color(MARKER_COLOR) {
		#			unit_square
		#		}
		#	}
		#}
		#with_translation(-0.25, -0.45) {
		#	with_scale(0.01, 0.15) {
		#		with_color(MARKER_COLOR) {
		#			unit_square
		#		}
		#	}
		#}

		# Label
		gui_render_label
	end
end

class VariableInput
	GUI_COLOR = [0.0,1.0,0.5,0.7]

	def gui_render!
		gui_render_background

		# Status Indicator
		if (v=value) > 0.0
			with_translation(-0.5 + v/2.0, 0.0) {
				with_scale_unsafe(v, 1.0) {
					with_color(GUI_COLOR) {
						unit_square
					}
				}
			}
		end

		# Label
		gui_render_label
	end
end

class Event
	GUI_COLOR_ON = [1.0,1.0,0.0,1.0]
	GUI_COLOR_OFF = [1.0,1.0,0.0,0.1]

	def gui_render!
		gui_render_background

		# Status Indicator
		with_translation(-0.5 + 0.1, 0.0) {
			with_scale(0.1, 0.35) {
				with_color(now? ? GUI_COLOR_ON : GUI_COLOR_OFF) {
					unit_square
				}
			}
		}

		with_translation(0.23, 0.05) {
			# Label
			gui_render_label
		}
	end
end

class EventInput
	GUI_COLOR_ON = [1.0,1.0,0.0,1.0]
	GUI_COLOR_OFF = [1.0,1.0,0.0,0.1]

	def gui_render!
		gui_render_background

		# Status Indicator
		with_translation(-0.5 + 0.1, 0.0) {
			with_scale(0.1, 0.35) {
				with_color(now? ? GUI_COLOR_ON : GUI_COLOR_OFF) {
					unit_square
				}
			}
		}

		with_translation(0.17, 0.05) {
			# Label
			gui_render_label
		}
	end
end
