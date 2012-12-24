#
# This is a list with up and down arrows for easy scrolling.
#
class GuiListWithControls < GuiBox
	# List configuration goes to list
	pipe :scroll_wrap=, :list
	pipe :spacing_y=, :list
	pipe :item_aspect_ratio=, :list
	pipe :set_selection, :list
	pipe :add_to_selection, :list

	def initialize(contents)
		super()
		self << @list=GuiList.new(contents)

		# up
		self << @up_button=GuiButton.new.set(:scale_x => 1.0, :scale_y => 0.16, :offset_y => 0.5 - 0.08, :opacity => 0.75, :background_image => $engine.load_image('images/buttons/scroll-up.png'))
		@up_button.on_clicked { @list.scroll_velocity -= 0.4 }
		@up_button.on_holding { @list.scroll_velocity -= 0.2 }

		# down
		self << @down_button=GuiButton.new.set(:scale_x => 1.0, :scale_y => -0.16, :offset_y => -0.5 + 0.08, :opacity => 0.75, :background_image => $engine.load_image('images/buttons/scroll-up.png'))
		@down_button.on_clicked { @list.scroll_velocity += 0.4 }
		@down_button.on_holding { @list.scroll_velocity += 0.2 }

		@list.on_scroll_change { update_scroll_buttons }
	end

	def update_scroll_buttons
		if @list.scroll_wrap
			@up_button.set_hidden(!@list.allow_scrolling?)		# endlessly scrolling list...without enough elements to bother?   TODO: this gets the wrong value...
			@down_button.set_hidden(!@list.allow_scrolling?)
		elsif @list.allow_scrolling?												# scrolling without scroll_wrap uses smart buttons-- up disappears when arriving at top of list
			@up_button.set_hidden(@list.scrolled_to_start?)
			@down_button.set_hidden(@list.scrolled_to_end?)
		else
			@up_button.hidden!			# no scrolling allowed!
			@down_button.hidden!
		end
	end

	def includes_gui_object?(object)
		(@up_button == object) || (@down_button == object)
	end

	def scroll_up!(pointer)
		@list.scroll_up!(pointer)
	end

	def scroll_down!(pointer)
		@list.scroll_down!(pointer)
	end
	
	def scroll_to(value)
		@list.scroll_to(value)
	end
end
