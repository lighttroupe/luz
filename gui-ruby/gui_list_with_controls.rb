#
# This is a list with up and down arrows for easy scrolling.
#

# TODO: this should be a subclass, with custom render?  or built in behavior for 

class GuiListWithControls < GuiList
	CLICK_VELOCITY = 3.8
	HOLD_VELOCITY = 1.2

	# List configuration goes to list
#	pipe :scroll_wrap=, :list
#	pipe :spacing_y=, :list
#	pipe :item_aspect_ratio=, :list
#	pipe :set_selection, :list
#	pipe :add_to_selection, :list
#	pipe :selection, :list
#	pipe :scroll_to_selection!, :list
#	def add(object)
#		self << object			# HACK: to avoid adding items to THIS container... remove this when GuiListWithControls becomes a subclass
#	end

=begin
	def initialize(contents=[])
		super
		#self << @list=GuiList.new(contents)

		# up
		@up_button = GuiButton.new.set(:scale_x => 1.0, :scale_y => 0.16, :offset_y => 0.5 - 0.08, :opacity => 0.75, :background_image => $engine.load_image('images/buttons/scroll-up.png'))
		@up_button.on_clicked { self.scroll_velocity -= CLICK_VELOCITY }
		@up_button.on_holding { self.scroll_velocity -= HOLD_VELOCITY }

		# down
		@down_button = GuiButton.new.set(:scale_x => 1.0, :scale_y => -0.16, :offset_y => -0.5 + 0.08, :opacity => 0.75, :background_image => $engine.load_image('images/buttons/scroll-up.png'))
		@down_button.on_clicked { self.scroll_velocity += CLICK_VELOCITY }
		@down_button.on_holding { self.scroll_velocity += HOLD_VELOCITY }

		self.on_scroll_change { update_scroll_buttons }
	end

	def gui_render!
		return if hidden?
		super
		@up_button.gui_render!
		@down_button.gui_render!
	end

	def hit_test_render!
		return if hidden?
		super
		@up_button.hit_test_render!
		@down_button.hit_test_render!
	end

	def update_scroll_buttons
		if self.scroll_wrap
			@up_button.set_hidden(!self.allow_scrolling?)		# endlessly scrolling list...without enough elements to bother?   TODO: this gets the wrong value...
			@down_button.set_hidden(!self.allow_scrolling?)
		elsif self.allow_scrolling?												# scrolling without scroll_wrap uses smart buttons-- up disappears when arriving at top of list
			@up_button.set_hidden(self.scrolled_to_start?)
			@down_button.set_hidden(self.scrolled_to_end?)
		else
			@up_button.hidden!			# no scrolling allowed!
			@down_button.hidden!
		end
	end
=end

	# HACK: to avoid closing popups when user clicks on an arrow
	def includes_gui_object?(object)
		(@up_button == object) || (@down_button == object)
	end

#	def scroll_up!(pointer)
#		@list.scroll_up!(pointer)
#	end

#	def scroll_down!(pointer)
#		@list.scroll_down!(pointer)
#	end

#	def scroll_to(value)
#		@list.scroll_to(value)
#	end
end
