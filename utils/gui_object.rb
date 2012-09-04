#
# Gui base class
#
class GuiObject
	include GuiHoverBehavior
	include ValueAnimation
	include Drawing

	easy_accessor :parent, :offset_x, :offset_y, :scale_x, :scale_y, :opacity
	boolean_accessor :hidden

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
			unit_square
		}
	end

private

	def with_positioning
		with_translation(@offset_x, @offset_y) {
			with_scale(@scale_x, @scale_y) {
				with_multiplied_alpha(@opacity) {
					yield
				}
			}
		}
	end
end
