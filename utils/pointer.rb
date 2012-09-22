class Pointer
	easy_accessor :number, :background_image, :color, :size
	DEFAULT_COLOR = [1,1,1,0.7]
	HOLD_COLOR = [1,1,1,0.4]

	boolean_accessor :click
	boolean_accessor :dragging

	def initialize
		@number = 1
		@size = 0.08
		@color = DEFAULT_COLOR
	end

	def hold_time
		@click_time ? Time.now - @click_time : 0.0
	end

	LONG_CLICK_HOLD_TIME = 1.0

	def drop!
		puts 'dropped!'
	end

	def tick!
		if @hover_object
			if click?
				@hover_object.click(self) if @hover_object.respond_to?(:click)
				@click_potential = true		# something could happen!
				@click_time = Time.now

			elsif dragging?
				drop! unless hold?

			elsif !@click_potential
				# nothing...

			elsif hold?
				# TODO: check for dragging
				if hold_time > LONG_CLICK_HOLD_TIME
					@hover_object.long_click(self) if @hover_object.respond_to?(:long_click)
					@click_potential = false
				end

			else
				@click_potential = false
			end
			@hover_object.scroll_up!(self) if scroll_up? && @hover_object.respond_to?(:scroll_up!)
			@hover_object.scroll_down!(self) if scroll_down? && @hover_object.respond_to?(:scroll_down!)
			@hover_object.scroll_left!(self) if scroll_left? && @hover_object.respond_to?(:scroll_left!)
			@hover_object.scroll_right!(self) if scroll_right? && @hover_object.respond_to?(:scroll_right!)
		end
	end

	def color
		if hold?
			HOLD_COLOR
		else
			DEFAULT_COLOR
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

		exit_hover_object!		# pointer exits current object

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
