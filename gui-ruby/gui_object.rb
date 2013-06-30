require 'gui_pointer_behavior'
require 'gui_selected_behavior'

module MethodsForGuiObject
	include GuiPointerBehavior
	include GuiSelectedBehavior
	include ValueAnimation
	include ValueAnimationStates
	include Drawing

	BACKGROUND_COLOR = [0.0,0.0,0.0,0.0]
	BACKGROUND_COLOR_HOVERING = [1.0,1.0,1.0,0.25]
	BACKGROUND_COLOR_SELECTED = [1.0,1.0,1.0,0.15]

	easy_accessor :parent, :offset_x, :offset_y, :scale_x, :scale_y, :opacity, :color, :background_image, :background_scale_x, :background_scale_y, :float
	boolean_accessor :hidden
	boolean_accessor :draggable

	def set(hash)
		hash.each { |key, value|
			self.send(key.to_s + '=', value)
		}
		self
	end

	def set_scale(scale)
		@scale_x, @scale_y = scale, scale
		self
	end
	alias :scale= :set_scale

	def show!
		self.hidden = false
	end

	def visible?
		!hidden?
	end

	#
	# Keyboard focus
	#
	def cancel_keyboard_focus!
		$gui.cancel_keyboard_focus_for(self)
	end

	def grab_keyboard_focus!(&proc)
		$gui.grab_keyboard(self, &proc)
	end

	def keyboard_focus?
		$gui.has_keyboard_focus?(self)
	end

	def on_key_press(value)
		@parent.on_key_press(value) if @parent		# Default is to pass it up the stack
	end

	#
	# 
	#
	def gui_tick!
		tick_animations!
	end

	def hit_test_render!
		return if hidden?
		with_positioning {
			render_hit_test_unit_square
		}
	end

	def render_hit_test_unit_square
		with_unique_hit_test_color_for_object(self, 0) {
			unit_square
		}
	end

	def gui_render!
		return if hidden?
		with_positioning {
			gui_render_background
			gui_render_placeholder unless background_image
		}
	end

	def gui_render_placeholder
		with_color(color) {
			unit_square
		}
	end

	def gui_render_background
		if background_image
			with_scale(background_scale_x || 1.0, background_scale_y || 1.0) {
				background_image.using {
					unit_square
				}
			}
		else
			with_color(background_color) {
				unit_square
			}
		end
	end

	boolean_accessor :exiting
	def exit!
		return if exiting?
		exiting!
		after_exit_animation {
			remove_from_parent!
		}
	end

	def after_exit_animation
		set_opacity(opacity || 1.0).animate({:scale_x => 0.0, :scale_y => 0.0, :opacity => 0.0}, duration=0.2) {
			yield
		}
	end

	def background_color
		if pointer_hovering?
			BACKGROUND_COLOR_HOVERING
		elsif selected?
			BACKGROUND_COLOR_SELECTED
		else
			BACKGROUND_COLOR
		end
	end

	def click(pointer)
		@parent.click(pointer) if @parent			# Default is to pass it up the stack		TODO: change this to "child_click" ? (see UserObject monkeypatching)
	end
	def scroll_up!(pointer)
		@parent.scroll_up!(pointer) if @parent			# Default is to pass it up the stack		TODO: change this to "child_click" ? (see UserObject monkeypatching)
	end
	def scroll_down!(pointer)
		@parent.scroll_down!(pointer) if @parent			# Default is to pass it up the stack		TODO: change this to "child_click" ? (see UserObject monkeypatching)
	end

	def begin_drag(pointer)
	end

	def update_drag(pointer)
	end

	def end_drag(pointer)
	end

	def with_gui_object_properties
		return if hidden?
		with_positioning {
			gui_render_background
			yield
		}
	end

	def with_positioning
		with_translation(@offset_x, @offset_y) {
			# Record the scaling we do, so it's possible to undo it when proper aspect ratio is needed (ie text)
			with_env(:gui_scale_x, ($env[:gui_scale_x] || 1.0) * (@scale_x || 1.0)) {
				with_env(:gui_scale_y, ($env[:gui_scale_y] || 1.0) * (@scale_y || 1.0)) {
					with_scale(@scale_x || 1.0, @scale_y || 1.0) {
						with_color(color) {
							with_multiplied_alpha(@opacity || 1.0) {
								yield
							}
						}
					}
				}
			}
		}
	end

	def remove_from_parent!
		@parent.remove(self) if @parent
	end

	def add_to_root(object)
		return @parent.add_to_root(object) if @parent
		self << object
	end
end

#
# Gui base class
#
class GuiObject
	include Engine::MethodsForUserObject
	include MethodsForGuiObject
end
