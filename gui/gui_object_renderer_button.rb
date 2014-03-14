require 'gui_button'

class GuiObjectRendererButton < GuiButton
	attr_accessor :object

	def initialize(object)
		super()
		@object = object
	end

	def gui_render!
		super
		with_positioning {
			if pointer_hovering?
				with_hover_effect {
					@object.render!
				}
			else
				@object.render!
			end
		}
	end

	# for overriding
	def with_hover_effect
		yield
	end
end
