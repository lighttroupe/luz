require 'gui_pointer_behavior'
require 'gui_selected_behavior'

module MethodsForGuiObject
	include GuiPointerBehavior
	include GuiSelectedBehavior
	include ValueAnimation

	BACKGROUND_COLOR = [0.0,0.0,0.0,0.5]
	BACKGROUND_COLOR_HOVERING = [1.0,1.0,1.0,0.25]
	BACKGROUND_COLOR_SELECTED = [1.0,1.0,1.0,0.15]

	easy_accessor :parent, :offset_x, :offset_y, :scale_x, :scale_y, :opacity, :color
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

	# 
	def gui_tick!
		tick_animations!
	end

	def hit_test_render!
		return if hidden?
		with_positioning {
			with_unique_hit_test_color_for_object(self, 0) {
				unit_square
			}
		}
	end

	def gui_render!
		return if hidden?
		with_positioning {
			with_color(color) {
				unit_square
			}
		}
	end

	def gui_render_background
		with_color(background_color) {
			unit_square
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
		@parent.click(pointer) if @parent			# Default is to pass it up the stack
	end

	def begin_drag(pointer)
	end

	def update_drag(pointer)
	end

	def end_drag(pointer)
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
end

#
# Gui base class
#
class GuiObject
	include Drawing
	include Engine::MethodsForUserObject
	include MethodsForGuiObject
end
