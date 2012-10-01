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
		@drag_out_notify_potential = true
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
				@long_click_potential = true
			else
				$gui.pointer_click_on_nothing(self) if $gui.respond_to? :pointer_click_on_nothing
			end

		elsif hold?
			@hover_object.click_hold(self) if @hover_object.respond_to?(:click_hold)		# repeated calls once per frame

			if dragging?
				update_drag

			elsif @long_click_potential && hold_time > LONG_CLICK_HOLD_TIME && (drag_delta_x < SMALL_DISTANCE && drag_delta_y < SMALL_DISTANCE)
				@hover_object.long_click(self) if @hover_object.respond_to?(:long_click)
				@long_click_potential = false
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
		# do no work for the common case of "still hovering" (this gets called repeatedly with the same value)
		if @hover_object == object
			@drag_out_notify_potential = true
			return
		end

		# now hovering over something new!
		#puts "now over #{object ? object.class : 'nil'} #{$env[:frame_number]}"

		if @drag_object
			# drag_out notify.  callee can check in with us about which direction using eg. drag_delta_y
			if @drag_out_notify_potential
				if @drag_object.respond_to?(:drag_out)
					@drag_object.drag_out(self)
					@click_x, @click_y = x, y		# TODO: more effectively begin a new drag here?
				end
				@drag_out_notify_potential = false		# don't notify of this repeatedly
			end

			# don't hover over anything but 'drag object' while dragging (TODO: allow for drop?!)
			return if object != @drag_object
		end

		exit_hover_object!		# pointer exits current object (if present)

		if object		# NOTE: can be nil
			# enter new object
			object.pointer_enter(self) if object.respond_to?(:pointer_enter)
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
