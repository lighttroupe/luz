class UserObjectSetting
	include GuiPointerBehavior
	BACKGROUND_COLOR = [1,1,0,0.5]

	def gui_build_editor(container)
		container << GuiObject.new.set(:color => [0,1,1,1])
	end
end

class UserObjectSettingFloat
	def gui_build_editor(container)
		box = GuiBox.new
		box << GuiFloat.new(self, :animation_min, @min, @max).set(:scale_x => 0.3, :offset_x => -0.5 + 0.15)
		box << GuiCurve.new(self, :animation_curve).set(:scale_x => 0.3, :offset_x => 0.05)
		box << GuiFloat.new(self, :animation_max, @min, @max).set(:scale_x => 0.3, :offset_x => 0.5 - 0.15)
		box << GuiToggle.new(self, :enable_animation).set(:scale_x => 0.1, :offset_x => -0.15, :color => [1,0,0,1])
		container << box
	end
end

class UserObject
	SELECTION_COLOR = [1.0,1.0,1.0,0.25]
	BACKGROUND_COLOR = [0.0,0.0,0.0,0.5]

	include GuiPointerBehavior

	easy_accessor :selection_scale_x, :selection_scale_y

	empty_method :gui_tick!
	easy_accessor :parent

	boolean_accessor :draggable

	def gui_build_editor(container)
		if respond_to? :effects
			# Two-lists side by side
			@gui_effects_list = GuiList.new(effects).set({:spacing_y => -0.9, :scale_x => 0.5, :scale_y => 0.9, :offset_x => -0.25, :offset_y => -0.05, :item_aspect_ratio => 4.0})
			container << @gui_effects_list
			@gui_settings_list = GuiList.new.set({:spacing_y => -0.9, :scale_x => 0.5, :scale_y => 0.9, :offset_x => 0.25, :offset_y => -0.05, :item_aspect_ratio => 4.0})
			container << @gui_settings_list
		else
			# Just a settings list (not used as of 2012/09/21)
			@gui_settings_list = GuiList.new.set({:spacing_y => -0.9, :scale_x => 0.95, :scale_y => 0.9, :offset_x => 0.0, :offset_y => -0.05, :item_aspect_ratio => 4.0})
			container << @gui_settings_list
		end

		if @gui_settings_list
			gui_build_settings_list(self)
		end
	end

	def gui_build_settings_list(user_object)
		return unless @gui_settings_list
		@gui_settings_list.clear!
		user_object.settings.each { |setting|
			setting.gui_build_editor(@gui_settings_list)		# TODO: create a box container for each?
		}
	end

	def on_child_user_object_selected(user_object)
		gui_build_settings_list(user_object)
	end

	def gui_render!
		# Label
		gui_render_background
		gui_render_label
	end

	def gui_render_background
		with_color(BACKGROUND_COLOR) {
			unit_square
		}
	end

	def hit_test_render!
		with_unique_hit_test_color_for_object(self, 0) { unit_square }
	end

	def click(pointer)
		$gui.build_editor_for(self, :pointer => pointer)
	end

	def with_selection
		render_selection if pointer_hovering?
		yield
	end

	def render_selection
		with_color(SELECTION_COLOR) {
			with_scale(selection_scale_x || 1.0, selection_scale_y || 1.0) {		# TODO: avoid need for this
				unit_square
			}
		}
	end

	USER_OBJECT_TITLE_HEIGHT = 0.65
	def gui_render_label
		@title_label ||= BitmapFont.new.set(:string => title, :scale_x => 0.95, :scale_y => USER_OBJECT_TITLE_HEIGHT)
		if pointer_hovering?
			@title_label.gui_render!
		else
			with_vertical_clip_plane_right_of(0.5) {
				@title_label.gui_render!
			}
		end
	end
end

# HACK to render an object without reparenting it
class GuiObjectRenderer < GuiObject
	def initialize(object)
		@object = object
	end

	def gui_render!
		#with_positioning {
			@object.gui_render!		# TODO: send a symbol for customizable render method (ie simple curves)
		#}
	end

	def gui_tick!
		@object.gui_tick!
	end
end

class ChildUserObject
	def gui_render!
		render_selection if pointer_hovering?
		gui_render_label
	end
end

class Actor
	def gui_render!
		render_selection if pointer_hovering?
		render!

		# Label and shading effect
		if pointer_hovering?
			gui_render_background
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
	def gui_build_editor(container)
		container << GuiGrid.new(effects).set(:min_columns => 4)
		container << (@add_button=GuiButton.new.set(:scale_x => 0.15, :scale_y => 0.15, :offset_x => -0.5, :offset_y => 0.5, :background_image => $engine.load_image('images/buttons/menu.png')))
		@add_button.on_clicked {
			effects << Style.new
			GL.DestroyList(@gui_render_styles_list) ; @gui_render_styles_list = nil
		}
	end

	def gui_render!
		render_selection if pointer_hovering?

		# Background
		gui_render_background

		gui_render_styles

		# Label and shading effect
		if pointer_hovering?
			gui_render_background
			gui_render_label
		else
#			with_multiplied_alpha(0.5) {
#				gui_render_label
#			}
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

	def gui_build_editor(container)
		container.prepend(GuiObjectRenderer.new(self))
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
		if pointer_hovering?
			render_selection
		else
			gui_render_background
		end

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
		render_selection if pointer_hovering?

		# Status Indicator
		with_vertical_clip_plane_right_of(value - 0.5) {
			with_color(GUI_COLOR) {
				unit_square
			}
		}

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
		render_selection if pointer_hovering?

		# Status Indicator
		with_vertical_clip_plane_right_of(do_value - 0.5) {
			with_color(GUI_COLOR) {
				unit_square
			}
		}

		# Label
		gui_render_label
	end
end

class Event
	GUI_COLOR_ON = [1.0,1.0,0.0,1.0]
	GUI_COLOR_OFF = [1.0,1.0,0.0,0.1]

	def gui_render!
		render_selection if pointer_hovering?

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
		render_selection if pointer_hovering?

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
