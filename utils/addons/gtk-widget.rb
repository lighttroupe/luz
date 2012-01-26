class Gtk::Widget
	def on_expose
		signal_connect('expose-event') { yield ; true }		# false = unhandled
	end

	def on_focus
		signal_connect('focus-in-event') { yield ; true }		# false = unhandled
	end

	def toggle_visibility
		self.set_visible(!self.visible?)
	end

	# Button presses / releases
	def on_button_press
		add_events(Gdk::Event::BUTTON_PRESS_MASK)
		signal_connect('button-press-event') { |obj, event| yield event if event.event_type == Gdk::Event::BUTTON_PRESS ; false }		# false = unhandled
	end

	def on_button_release
		add_events(Gdk::Event::BUTTON_RELEASE_MASK)
		signal_connect('button-release-event') { |obj, event| yield event if event.event_type == Gdk::Event::BUTTON_RELEASE ; false }		# false = unhandled
	end

	def on_double_click
		add_events(Gdk::Event::BUTTON_PRESS_MASK)
		signal_connect('button-press-event') { |obj, event| yield event if event.event_type == Gdk::Event::BUTTON2_PRESS ; false }		# false = unhandled
	end

	def on_scroll_wheel
		add_events(Gdk::Event::SCROLL_MASK)
		signal_connect('scroll-event') { |obj, event| yield event ; false }		# false = unhandled
	end

	def on_scroll_wheel_up
		add_events(Gdk::Event::SCROLL_MASK)
		on_scroll_wheel { |event| yield if event.direction == Gdk::EventScroll::UP ; false }		# false = unhandled
	end

	def on_scroll_wheel_down
		add_events(Gdk::Event::SCROLL_MASK)
		on_scroll_wheel { |event| yield if event.direction == Gdk::EventScroll::DOWN ; false }		# false = unhandled
	end

	def on_primary_mouse_button_down
		on_button_press { |event| yield event.x, event.y if (event.event_type == Gdk::Event::BUTTON_PRESS and event.button == 1) ; false }
	end
	alias :on_click :on_primary_mouse_button_down

	def on_primary_mouse_button_up
		on_button_release { |event| yield event.x, event.y if (event.event_type == Gdk::Event::BUTTON_RELEASE and event.button == 1) }
	end

	def on_primary_mouse_button_double_click
		on_button_press { |event| yield event.x, event.y if (event.event_type == Gdk::Event::BUTTON_PRESS and event.button == 1) }
	end
	alias :on_click :on_primary_mouse_button_down

	def on_secondary_mouse_button_down
		on_button_press { |event| yield event.x, event.y if (event.event_type == Gdk::Event::BUTTON_PRESS and event.button == 3) }
	end
	alias :on_click :on_primary_mouse_button_down

	def on_secondary_mouse_button_up
		on_button_release { |event| yield event.x, event.y if (event.event_type == Gdk::Event::BUTTON_RELEASE and event.button == 3) }
	end

	def on_context_menu
		on_button_press { |event|
			if (event.event_type == Gdk::Event::BUTTON_PRESS and event.button == 3)
				if (path = get_path_at_pos(event.x, event.y))
					if selected.size <= 1
						unselect_all
						selection.select_path(path[0])
					end
				end
				yield event
			end
		}
	end

	def on_mouse_motion
		add_events(Gdk::Event::POINTER_MOTION_MASK)
		signal_connect('motion-notify-event') { |obj, event| yield event.x, event.y ; false } # false = unhandled
	end

	def width
		allocation.width
	end

	def height
		allocation.height
	end

	def queue_draw
		queue_draw_area(0, 0, allocation.width, allocation.height)
	end

	def on_key_press_event(event)
		modifiers = nil		# TODO: extract from event ?
		if @key_press_handlers and @key_press_handlers[modifiers] and @key_press_handlers[modifiers][event.keyval]
			@key_press_handlers[modifiers][event.keyval].each { |proc| proc.call(event) }
			true
		else
			false
		end
	end

	def on_key_press(keyval, modifiers = nil, &proc)
		if @key_press_handlers.nil?
			# On first use of on_key_press() setup GLib signal handler
			self.signal_connect('key-press-event') { |obj, event| on_key_press_event(event) }
			@key_press_handlers = {}
		end

		@key_press_handlers[modifiers] ||= {}
		@key_press_handlers[modifiers][keyval] ||= []
		@key_press_handlers[modifiers][keyval] << proc
	end

	def on_activate
		signal_connect('activate') { yield }
	end

	def on_close
		signal_connect('delete_event') { yield ; true }		# true = handled
	end

	def on_delete
		signal_connect('delete_event') { yield }
	end
end
