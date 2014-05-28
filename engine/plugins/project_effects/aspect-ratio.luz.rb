class ProjectEffectAspectRatio < ProjectEffect
	title				"Aspect Ratio"
	description "Adjusts aspect ratio for the display in use to ensure that square objects appear square."

	hint "Place this before drawing Directors."

	setting 'mode', :select, :default => :stretched, :options => [[:stretched, 'Stretched'], [:square_horizontal, 'Square (stretch horizontally)'], [:square_vertical, 'Square (stretch vertically)']]

	def render
		ratio = ($application.width.to_f / $application.height)

		# ratio is a number above 1.0 for most monitors
		case mode
		when :stretched		# 1x1 shapes appear stretched horizontally (normal luz behavior)
			yield

		when :square_horizontal
			with_scale(1.0 / ratio, 1.0) {
				with_env(:aspect_scale, ratio) {		# this informs anything about the need to scale larger to fill the screen
					yield
				}
			}

		when :square_vertical
			with_scale(1.0, 1.0 * ratio) {
				yield
			}

		else
			raise "unhandled mode '#{mode}'"
		end
	end
end
