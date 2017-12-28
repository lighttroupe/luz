multi_require 'user_object', 'drawing'

class Style < UserObject
	title 'Style'

	include Drawing

	setting 'color', :color, :default => [1.0,1.0,1.0,1.0], :only_literal => true
	setting 'image', :image

	pipe :color=, :color_setting

	def new_renderer
		GuiStyleRenderer.new(self)
	end

	def default_title
		''
	end

	def using
		image.using {
			with_color(color_setting.color) {		# TODO: seems to be a caching issue with using 'color' directly?
				yield
			}
		}
	end

	def using_amount(amount)
		return yield if amount == 0.0
		# NOTE: currently ignores image
		with_color(current_color.fade_to(amount, color_setting.color)) {
			yield
		}
	end
end
