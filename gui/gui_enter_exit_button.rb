class GuiEnterExitButton < GuiButton
	easy_accessor :enter_image, :exit_image

	def initialize(object)
		@object = object
		@enter_image = $engine.load_image('images/buttons/enter.png')
		@exit_image = $engine.load_image('images/buttons/exit.png')
	end

	def gui_render
		with_gui_object_properties {
			with_translation(-0.25, 0.0) {
				with_scale(0.5, 1.0) {
					with_alpha(@object.enable_enter_animation ? 1.0 : 0.4) {
						enter_image.using {
							unit_square
						}
					}
				}
			}
			with_translation(0.25, 0.0) {
				with_scale(0.5, 1.0) {
					with_alpha(@object.enable_exit_animation ? 1.0 : 0.4) {
						exit_image.using {
							unit_square
						}
					}
				}
			}
		}
	end
end
