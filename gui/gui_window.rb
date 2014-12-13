class GuiWindow < GuiBox
	callback :open
	callback :close

	def open!
		switch_state({:closed => :open}, duration=0.3)
		open_notify
	end

	def open?
		in_state?(:open)
	end

	def close!
		switch_state({:open => :closed}, duration=0.1)
		close_notify
	end

	def closed?
		!open?
	end

	# scroll wheel over a window shouldn't leak to the background
	def scroll_up!(pointer) ; end
	def scroll_down!(pointer) ; end
	def scroll_left!(pointer) ; end
	def scroll_right!(pointer) ; end
end
