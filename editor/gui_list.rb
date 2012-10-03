class GuiList < GuiBox
	easy_accessor :spacing_x, :spacing_y, :item_aspect_ratio, :scroll_wrap
	easy_accessor :scroll, :scroll_velocity

	callback :scroll_change

	def initialize(*args)
		super
		@scroll = 0.0
		@scroll_velocity = 0.0
		@one_fake_scroll_change_notify = true
	end

	VELOCITY_PER_SCROLL = 2.0
	MAX_SCROLL_VELOCITY = 16.0
	def scroll_up!(pointer)
		@scroll_velocity = (@scroll_velocity - VELOCITY_PER_SCROLL).clamp(-MAX_SCROLL_VELOCITY, MAX_SCROLL_VELOCITY)
	end
	def scroll_down!(pointer)
		@scroll_velocity = (@scroll_velocity + VELOCITY_PER_SCROLL).clamp(-MAX_SCROLL_VELOCITY, MAX_SCROLL_VELOCITY) 
	end

	def hit_test_render!
		return if hidden?
		each_with_positioning { |gui_object| gui_object.hit_test_render! }
	end

	def velocity_damper
		0.94
	end

	def child_click(pointer)
		@scroll_velocity *= 0.05
	end

	def move_child_up(child)
		if (index = @contents.index(child)) > 0
			@contents[index], @contents[index-1] = @contents[index-1], @contents[index]
		end
	end

	def move_child_down(child)
		if (index = @contents.index(child)) < (@contents.size - 1)
			@contents[index], @contents[index+1] = @contents[index+1], @contents[index]
		end
	end

	def gui_tick!
		super
		if allow_scrolling?
			starting_scroll = @scroll

			@scroll += @scroll_velocity * $env[:frame_time_delta]
			@scroll = 0.0 if @scroll.abs < 0.001
			@scroll = @scroll.clamp(0.0, @scroll_max) if @scroll_max

			@scroll_velocity *= velocity_damper
			@scroll_velocity = 0.0 if @scroll_velocity.abs < 0.001		# floating points...

			scroll_change_notify if @scroll != starting_scroll
		end
	end

	BACKGROUND_COLOR = [0,0,0,0.8]
	def gui_render!
		return if hidden?
		with_positioning { with_color(BACKGROUND_COLOR) { unit_square } }
		each_with_positioning { |gui_object| gui_object.gui_render! }

		scroll_change_notify if @one_fake_scroll_change_notify
		@one_fake_scroll_change_notify = false
	end

	def scrolled_to_start?
		@scroll == 0.0
	end

	def scrolled_to_end?
		@scroll == @scroll_max
	end

	def allow_scrolling?
		@visible_slots && @contents.size > @visible_slots
	end

	def each_with_positioning
		with_positioning {
			if spacing_y && spacing_y != 0.0
				with_horizontal_clip_plane_above(0.5) {
					with_horizontal_clip_plane_below(-0.5) {
						final_spacing_y = (spacing_y || 1.0) / (item_aspect_ratio || 1.0)

						with_translation(0.0, 0.5) {
							with_aspect_ratio_fix_y { |fix_y|
								@visible_slots = ((1.0 / fix_y) / (final_spacing_y.abs))

								# Enable scrolling?
								if allow_scrolling?
									unless scroll_wrap
										@scroll_max = (@contents.size - @visible_slots) * final_spacing_y.abs
										@scroll = @scroll.clamp(0.0, @scroll_max)
									end

									first_index, remainder_scroll = @scroll.divmod(final_spacing_y.abs)
									total_shown = @contents.size
									last_index = first_index + (@visible_slots) + 1

									for fake_index in first_index..last_index
										index = fake_index % @contents.size		# this achieves endless looping!
										gui_object = @contents[index]
										next unless gui_object		# support for nils-- potentially useful feature?

										with_translation(fake_index * (spacing_x || 0.0), @scroll + (fake_index * final_spacing_y) + (final_spacing_y / 2.0)) {
											with_scale(1.0, final_spacing_y.abs) {
												yield gui_object
											}
										}
									end
								else
									with_translation(0.0, (final_spacing_y / 2.0)) {
										for index in 0..(@contents.size-1)
											gui_object = @contents[index]
											with_translation(index * (spacing_x || 0.0), (index * final_spacing_y)) {
												with_scale(1.0, final_spacing_y.abs) {
													yield gui_object
												}
											}
										end
									}
								end
							}
						}
					}
				}
			else
				# more primitive support for horizontal layout
				with_vertical_clip_plane_right_of(1.5) {		# ...uhr?
					with_vertical_clip_plane_left_of(-0.5) {
						final_spacing_x = (spacing_x || 0.0) #/ (item_aspect_ratio || 1.0)

						with_translation(-0.5, 0.0) {
							with_aspect_ratio_fix {
								with_translation(@scroll, 0.0) {
									@contents.each_with_index { |gui_object, index|
										with_translation((final_spacing_x / 2.0) + index * (final_spacing_x), 0.0) {
											with_scale(final_spacing_x.abs, 1.0) {
												yield gui_object
											}
										}
									}
								}
							}
						}
					}
				}
			end
		}
	end
end

class GuiListWithControls < GuiBox
	def scroll_wrap=(v) ; @list.scroll_wrap = v ; end
	def spacing_y=(v) ; @list.spacing_y = v ; end
	def item_aspect_ratio=(v) ; @list.item_aspect_ratio = v ; end

	def initialize(contents)
		super()
		self << @list=GuiList.new(contents)

		# up
		self << @up_button=GuiButton.new.set(:scale_x => 1.0, :scale_y => 0.12, :offset_y => 0.5 - 0.06, :opacity => 0.5)
		@up_button.on_clicked { @list.scroll_velocity -= 0.4 }
		@up_button.on_holding { @list.scroll_velocity -= 0.2 }

		# down
		self << @down_button=GuiButton.new.set(:scale_x => 1.0, :scale_y => 0.12, :offset_y => -0.5 + 0.06, :opacity => 0.5)
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
end
