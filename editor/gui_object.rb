require 'gui_selected_behavior'

#
# Gui base class
#
class GuiObject
	include GuiPointerBehavior
	include GuiSelectedBehavior
	include ValueAnimation
	include Drawing
	include Engine::MethodsForUserObject

	easy_accessor :parent, :offset_x, :offset_y, :scale_x, :scale_y, :opacity, :color
	boolean_accessor :hidden
	boolean_accessor :draggable

	def initialize
		@parent = nil
		@offset_x, @offset_y = 0.0, 0.0
		@scale_x, @scale_y = 1.0, 1.0
		@opacity = 1.0
	end

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
		with_unique_hit_test_color_for_object(self, 0) {
			with_positioning {
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

	def click(pointer)
		@parent.click(pointer) if @parent			# Default is to pass it up the stack
	end

#	def scroll_up!(pointer)
#		@parent.scroll_up!(pointer) if @parent			# Default is to pass it up the stack
#	end

private

	def with_positioning
		with_translation(@offset_x, @offset_y) {
			# Record the scaling we do, so it's possible to undo it when proper aspect ratio is needed (ie text)
			with_env(:gui_scale_x, ($env[:gui_scale_x] || 1.0) * (@scale_x || 1.0)) {
				with_env(:gui_scale_y, ($env[:gui_scale_y] || 1.0) * (@scale_y || 1.0)) {
					with_scale(@scale_x || 1.0, @scale_y || 1.0) {
						with_multiplied_alpha(@opacity || 1.0) {
							yield
						}
					}
				}
			}
		}
	end
end
