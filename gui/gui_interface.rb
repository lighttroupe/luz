#
# GuiInterface is base class of all $gui implementations, such as GuiDefault.
#
class GuiInterface < GuiBox
	def initialize
		super
		@pointers = [PointerMouse.new.set_background_image($engine.load_image('images/pointer.png'))]
	end

	def gui_tick
		tick_value_animations!
		return if hidden?
		super
		if hit_test_needed?
			with_hit_testing {
				hit_test_render!
				hit_test_pointers!
			}
		end
		tick_pointers
	end

private

	def tick_value_animations!
		$value_animation_manager.tick_animations!
	end

	def hit_test_needed?
		true		# TODO (needed for hover and click)
	end

	def render_pointers
		@pointers.each(&:render!)
	end

	def tick_pointers
		@pointers.each(&:tick!)
	end

	def hit_test_pointers!
		@pointers.each { |pointer|
			object, _unused_user_data = hit_test_object_at_luz_coordinates(pointer.x, pointer.y)
			pointer.is_over(object)
		}
	end
end
