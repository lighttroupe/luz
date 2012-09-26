class Pointer
	easy_accessor :number, :background_image, :color, :size
	DEFAULT_COLOR = [1,1,1,0.7]
	HOLD_COLOR = [1,1,1,0.4]

	LONG_CLICK_HOLD_TIME = 1.0
	SMALL_DISTANCE = 0.02

	boolean_accessor :click
	boolean_accessor :dragging
	attr_accessor :click_x, :click_y		# point at which mouse was clicked, only while holding

	def initialize
		@number = 1
		@size = 0.08
		@color = DEFAULT_COLOR
	end

	def hold_time
		@click_time ? Time.now - @click_time : 0.0
	end

	def drag_delta_x
		x - @click_x
	end

	def drag_delta_y
		y - @click_y
	end

	# Dragging
	def dragging?
		!@drag_object.nil?
	end

	def begin_drag(object)
		@drag_object = object		# NOTE: only dragging if @dragging is then set (below)
		@drag_object.begin_drag(self)
	end

	#def drag_distance
	#	return 0.0 unless dragging?
	#	Math.sqrt(drag_delta_x**2 + drag_delta_y**2)
	#end

	def update_drag
		@drag_object.update_drag(self)
	end

	def end_drag
		@drag_object.end_drag(self)
		@drag_object = nil
	end

	def tick!
		if click?
			if @hover_object
				@hover_object.click(self) if @hover_object.respond_to?(:click)
				@click_x, @click_y, @click_time = x, y, Time.now
				begin_drag(@hover_object) if @hover_object.draggable?
			else
				$gui.pointer_click_on_nothing(self) if $gui.respond_to? :pointer_click_on_nothing
			end

		elsif hold?
			if dragging?
				update_drag

			elsif hold_time > LONG_CLICK_HOLD_TIME && (drag_delta_x < SMALL_DISTANCE && drag_delta_y < SMALL_DISTANCE)
				@hover_object.long_click(self) if @hover_object.respond_to?(:long_click)
			end

		elsif dragging?
			end_drag
		end

		target = @drag_object || @hover_object
		if target
			target.scroll_up!(self) if scroll_up? && target.respond_to?(:scroll_up!)
			target.scroll_down!(self) if scroll_down? && target.respond_to?(:scroll_down!)
			target.scroll_left!(self) if scroll_left? && target.respond_to?(:scroll_left!)
			target.scroll_right!(self) if scroll_right? && target.respond_to?(:scroll_right!)
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
