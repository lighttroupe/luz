# Subclasses are expected to implement:
#  x_name, y_name, button_one_name, scroll_up_name, scroll_down_name, scroll_left_name, scroll_right_name

class Pointer
	easy_accessor :number, :background_image, :color, :size
	DEFAULT_COLOR = [1,1,1,0.7]
	HOLD_COLOR = [1,1,1,0.4]

	LONG_CLICK_HOLD_TIME = 0.6
	SMALL_DISTANCE = 0.02

	boolean_accessor :click
	boolean_accessor :dragging
	attr_accessor :click_x, :click_y		# point at which mouse was clicked, only while holding

	def initialize
		@number = 1
		@size = 0.08
		@color = DEFAULT_COLOR
	end

	#
	# Basic API
	#
	def x
		$engine.slider_value(x_name) - 0.5
	end

	def y
		$engine.slider_value(y_name) - 0.5
	end

	def click?
		$engine.button_pressed_this_frame?(button_one_name)
	end

	def hold?
		$engine.button_down?(button_one_name)
	end

	def scroll_up?
		$engine.button_pressed_this_frame?(scroll_up_name)
	end

	def scroll_down?
		$engine.button_pressed_this_frame?(scroll_down_name)
	end

	def scroll_left?
		$engine.button_pressed_this_frame?(scroll_left_name)
	end

	def scroll_right?
		$engine.button_pressed_this_frame?(scroll_right_name)
	end

	#
	# Dragging
	#
	def dragging?
		!@drag_object.nil?
	end

	def begin_drag(object)
		@drag_object = object		# NOTE: only dragging if @dragging is then set (below)
		@drag_out_notify_potential = true
		@drag_object.begin_drag(self)
	end

	def update_drag
		@drag_object.update_drag(self)
	end

	def end_drag
		@drag_object.end_drag(self)
		@drag_object = nil
	end

	def update_velocity
		current_x, current_y = self.x, self.y
		if @last_x
			delta_x, delta_y = (x - @last_x), (y - @last_y)
			@velocity_squared, @velocity = (delta_x**2 + delta_y**2), nil
		end
		@last_x, @last_y = current_x, current_y
	end

	def velocity
		return 0.0 unless @velocity_squared
		@velocity ||= Math.sqrt(@velocity_squared)
	end

	def drag_delta_x
		x - @click_x
	end

	def drag_delta_y
		y - @click_y
	end

	#
	# Capturing (see tick below)
	#
	def capture_object!(object, &proc)
		@capture_object = object
		@capture_drop_proc = proc
	end

	def uncapture_object!
		@capture_object, @capture_drop_proc = nil, nil
	end

	#
	# This is the entrance for most features
	#
	def tick!
		if click?
			respond_to_click

		elsif hold?
			update_hold

		elsif dragging?
			end_drag
		end

		update_scroll_wheel
		update_velocity
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

	def is_over(object)		# NOTE: object is nil if no object
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
					@long_click_potential = false
				end
				@drag_out_notify_potential = false		# don't notify of this repeatedly
			end

			# don't hover over anything but 'drag object' while dragging (TODO: allow for drop?!)
			return if object != @drag_object
		end

		exit_hover_object!		# pointer exits current object (if present)

		if object
			# enter new object
			object.pointer_enter(self) if object.respond_to?(:pointer_enter)
			@hover_object = object
			#puts "hovering over #{@hover_object.title}"
		end

		self
	end

private

	def respond_to_click
		#
		# Pointer capture feature: all clicks go to the "capture object", which can uncapture via return value
		#
		if @capture_object
			if @capture_drop_proc.call(@hover_object) != true		# returns: still captured?
				@capture_object, @capture_drop_proc = nil, nil
			end
			return if @capture_object
		end

		#
		# 
		#
		if @hover_object
			@hover_object.click(self) if @hover_object.respond_to?(:click)
			@click_x, @click_y, @click_time = x, y, Time.now
			begin_drag(@hover_object) if @hover_object.draggable?
			@long_click_potential = true
			@click_object = @hover_object
		else
			$gui.pointer_click_on_nothing(self) if $gui.respond_to? :pointer_click_on_nothing
		end
	end

	def update_hold
		@hover_object.click_hold(self) if @hover_object.respond_to?(:click_hold)		# repeated calls once per frame

		if dragging?
			update_drag
		end

		if @long_click_potential && @hover_object == @click_object
			if (drag_delta_x < SMALL_DISTANCE && drag_delta_y < SMALL_DISTANCE)
				if hold_time > LONG_CLICK_HOLD_TIME
					@hover_object.long_click(self) if @hover_object.respond_to?(:long_click)
					@long_click_potential = false
				end
			else
				@long_click_potential = false		# wandered too far
			end
		end
	end

	def update_scroll_wheel
		# Update Scrolling
		if (target = (@drag_object || @hover_object))
			target.scroll_up!(self) if scroll_up? && target.respond_to?(:scroll_up!)
			target.scroll_down!(self) if scroll_down? && target.respond_to?(:scroll_down!)
			target.scroll_left!(self) if scroll_left? && target.respond_to?(:scroll_left!)
			target.scroll_right!(self) if scroll_right? && target.respond_to?(:scroll_right!)
		end
	end

	def exit_hover_object!
		@hover_object.pointer_exit(self) if @hover_object && @hover_object.respond_to?(:pointer_exit)
		@hover_object = nil
	end

	#
	# Calculations
	#
	def hold_time
		@click_time ? Time.now - @click_time : 0.0
	end

	def color
		if hold?
			HOLD_COLOR
		else
			DEFAULT_COLOR
		end
	end
end
