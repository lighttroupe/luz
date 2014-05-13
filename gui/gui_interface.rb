#
# Baseclass of all $gui implementations, such as GuiDefault.
#
class GuiInterface < GuiBox
	def initialize
		super
		@pointers = [PointerMouse.new.set_background_image($engine.load_image('images/pointer.png'))]
	end

	def gui_render!
		super
		render_pointers
	end

	def gui_tick!
		return if hidden?		# or alpha == 0.0
		super
		with_hit_testing {
			hit_test_render!
			hit_test_pointers!
		} if hit_test_needed?
		tick_pointers
	end

private

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
