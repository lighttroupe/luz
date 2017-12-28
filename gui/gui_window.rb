#
# GuiWindow is base class for "windows" (top level containers)
#
class GuiWindow < GuiBox
	callback :open
	callback :close

	def open?
		in_state?(:open)
	end
	def open!
		switch_state({:closed => :open}, duration=0.3)
		open_notify
	end

	def closed?
		in_state?(:closed)
	end
	def close!
		switch_state({:open => :closed}, duration=0.1)
		close_notify
	end

	# scroll wheel over a window shouldn't leak to the background
	def scroll_up!(pointer) ; end
	def scroll_down!(pointer) ; end
	def scroll_left!(pointer) ; end
	def scroll_right!(pointer) ; end
end
