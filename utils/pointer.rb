class Pointer
	easy_accessor :number, :background_image, :color, :size
	DEFAULT_COLOR = [1,1,1]

	def initialize
		@number = 1
		@size = 0.03
		@color = DEFAULT_COLOR
	end

	def tick!
		if @hover_object && click?
			@hover_object.click(self) if @hover_object.respond_to?(:click)
		end
	end

	def render!
		background_image.using {
			with_color(color) {
				with_translation(x, y) {
					with_scale(size) {
						unit_square
					}
				}
			}
		}
	end

	def is_over(object)
		return if @hover_object == object

		exit_hover_object!

		if object
			# enter new object
			object.pointer_enter(self) if object.respond_to?(:pointer_enter)

			# save
			@hover_object = object
			#puts "hovering over #{@hover_object.title}"
		end
		self
	end

	def exit_hover_object!
		@hover_object.pointer_exit(self) if @hover_object && @hover_object.respond_to?(:pointer_exit)
		@hover_object = nil
	end
end
