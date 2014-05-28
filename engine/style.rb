multi_require 'user_object', 'drawing'

class Style < UserObject
	title 'Style'

	def default_title
		''
	end

	include Drawing

	setting 'color', :color, :default => [1.0,1.0,1.0,1.0], :only_literal => true
	setting 'image', :image

	pipe :color=, :color_setting

	def set_color(color)
		self.color = color
		self
	end

	def using
		image.using {
			with_color(color_setting.color) {		# TODO: seems to be a caching issue with using 'color' directly?
				yield
			}
		}
	end

	def using_listsafe
		image.using {
			with_color_listsafe(color_setting.color) {		# TODO: seems to be a caching issue with using 'color' directly?
				yield
			}
		}
	end

	def using_amount(amount)
		return yield if amount == 0.0
		# note: currently ignores image

		with_color(current_color.fade_to(amount, color_setting.color)) {
			yield
		}
	end

	def set_pixels(pixels, width, height)
		image_setting.set_pixels(pixels, width, height)
	end
end
