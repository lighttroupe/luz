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
		in_state?(:closed)
	end
end
