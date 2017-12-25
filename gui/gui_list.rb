require 'gui_box'

class GuiList < GuiBox
	VELOCITY_PER_SCROLL = 3.0
	MAX_SCROLL_VELOCITY = 16.0
	VELOCITY_DAMPER = 0.7					# TODO: setting

	easy_accessor :spacing_x, :spacing_y, :item_aspect_ratio, :scroll_wrap, :scroll, :scroll_velocity

	callback :scroll_change

	def initialize(*args)
		super
		@scroll = 0.0										# in local units
		@scroll_velocity = 0.0
		@one_fake_scroll_change_notify = true
		@visible_slots = 0.0
	end

	def on_key_press(key)
		return super if key.any_modifiers?
		case key
		when 'down'
			select_next!
			scroll_to_selection!
		when 'up'
			select_previous!
			scroll_to_selection!
		#when 'return'		OOPS: this breaks variable flyout enter key behavior-- where is it needed??
			#selected = selection.first
			#selected.grab_keyboard_focus! if selected
		else
			super
		end
	end

	#
	# tick, render
	#
	def gui_tick
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
	ALT_COLOR = [0.1,0.1,0.12,0.7]
	def gui_render
		return if hidden?
#		with_positioning { with_color(BACKGROUND_COLOR) { unit_square } }
		toggle = false		# TODO: improve
		each_with_positioning { |gui_object|
			with_color(ALT_COLOR) { unit_square } if toggle
			toggle = !toggle
			gui_object.gui_render
		}

		if keyboard_focus?
			with_positioning {
				gui_render_keyboard_focus
			}
		end

		# this allows those that respond to our scroll changes to init themselves
		scroll_change_notify if @one_fake_scroll_change_notify
		@one_fake_scroll_change_notify = false
	end

	def hit_test_render!
		return if hidden?
		with_positioning { render_hit_test_unit_square }										# list blank space is clickable
		each_with_positioning { |gui_object| gui_object.hit_test_render! }
	end

	#
	# Pointer interaction
	#
	# NOTE: these are mousewheel-like activity
	def scroll_up!(pointer)
		@scroll_velocity = (@scroll_velocity - VELOCITY_PER_SCROLL).clamp(-MAX_SCROLL_VELOCITY, MAX_SCROLL_VELOCITY)
	end

	def scroll_down!(pointer)
		@scroll_velocity = (@scroll_velocity + VELOCITY_PER_SCROLL).clamp(-MAX_SCROLL_VELOCITY, MAX_SCROLL_VELOCITY)
	end

	def scroll_by(pointer, amount)
		@scroll += amount
	end

	#
	# Scrolling
	#
	def scrolled_to_start?
		@scroll == 0.0
	end

	def scrolled_to_end?
		@scroll == @scroll_max
	end

	def scroll_percentage
		return 0.0 unless @scroll_max
		@scroll / @scroll_max
	end

	def visible_percentage
		return 1.0 if @contents.empty?
		(@visible_slots / @contents.size).clamp(0.0, 1.0)
	end

	def scroll_to_selection!
		scroll_to(selection.first)
	end

	def allow_scrolling?
		@contents.size > @visible_slots
	end

	# instant-scroll a list to given value
	def scroll_to(value)
		if((index = index_of(value)) && @contents.size > 1)
			animate({:scroll => (index.to_f / (@contents.size - 1)) * @scroll_max}, duration=0.2) if @scroll_max
		end
		self
	end

	def velocity_damper
		VELOCITY_DAMPER
	end

	#
	# Reordering
	#
	def move_child_up(child)
		return unless (index = @contents.index(child))
		if index > 0
			@contents[index], @contents[index-1] = @contents[index-1], @contents[index]
			contents_change_notify
		end
	end

	def move_child_down(child)
		return unless (index = @contents.index(child))
		if index < (@contents.size - 1)
			@contents[index], @contents[index+1] = @contents[index+1], @contents[index]
			contents_change_notify
		end
	end

	#
	# Helpers
	#
	def index_of(value)
		@contents.index(value)
	end

	def distance_between_items
		(spacing_y || 1.0) / (item_aspect_ratio || 1.0)		# TODO: this would be prettier if easy_attributes had defaults
	end

	#
	# Iteration
	#
	def each_with_positioning(&proc)
		with_positioning {
			if spacing_y && spacing_y != 0.0
				each_with_positioning_vertical(&proc)
			else
				each_with_positioning_horizontal(&proc)
			end
		}
	end

	def clear!
		super
		@scroll = 0.0
	end

private

	def each_with_positioning_vertical(&proc)
		with_horizontal_clip_plane_above(0.5) {
			with_horizontal_clip_plane_below(-0.5) {
				each_with_positioning_vertical_within_clipping(&proc)
			}
		}
	end

	def each_with_positioning_vertical_within_clipping
		final_spacing_y = distance_between_items

		with_translation(0.0, 0.5) {
			with_aspect_ratio_fix_y { |fix_y|
				@visible_slots = ((1.0 / fix_y) / (final_spacing_y.abs))

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
	end

	def each_with_positioning_horizontal
		# more primitive support for horizontal layout
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
	end
end
