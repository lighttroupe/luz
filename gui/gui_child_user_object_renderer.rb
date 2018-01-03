class	GuiChildUserObjectRenderer < GuiUserObjectRenderer
	LABEL_CHILD_INDEX_RANGE_COLOR = [1,1,0]
	LABEL_CHILD_SUMMARY_COLOR = [0.9,0.9,1]

	#
	# class level
	#
	def self.gui_render
		gui_render_label
	end

	#
	# instance level
	#
	def gui_render
		gui_render_background
		gui_render_label
		gui_render_summary
		gui_render_child_conditions
		gui_render_enable_checkbox
	end

	def hit_test_render!
		super
		enable_checkbox.hit_test_render!
	end

	def click(pointer)
		# TODO: move to user object editor
		super
		$gui.build_editor_for(@object, :pointer => pointer, :grab_keyboard_focus => true)
	end

private

	def label_width
		14
	end

	def gui_render_label
		with_translation(0.0, 0.25) {
			with_scale(0.8, 0.7) {
				super
			}
		}
	end

	def gui_render_summary
		@summary_label ||= GuiLabel.new.set(:text_align => :left, :width => 16)
		settings_summary = @object.settings_summary.join(',')
		@summary_label.set_string(settings_summary)

		with_translation(0.0, -0.3) {
			with_scale(0.8, 0.4) {
				with_color(LABEL_CHILD_SUMMARY_COLOR) {
					@summary_label.gui_render
				}
			}
		}
	end

	def gui_render_child_conditions
		if @object.conditions.enable_child_index
			#@conditions_index_range_label = nil
			@conditions_index_range_label ||= GuiLabel.new.set(:text_align => :right, :width => 8, :scale_x => 0.45, :scale_y => 0.45)
			with_translation(0.25, 0.3) {
				with_color(LABEL_CHILD_INDEX_RANGE_COLOR) {
					if (@cached_child_number_min != @object.conditions.child_number_min) || (@cached_child_number_max != @object.conditions.child_number_max)
						@cached_child_number_min, @cached_child_number_max = @object.conditions.child_number_min, @object.conditions.child_number_max
						if @cached_child_number_min == @cached_child_number_max
							@conditions_index_range_label.set_string("child #{@cached_child_number_min}")
						else
							@conditions_index_range_label.set_string("#{@cached_child_number_min}-#{@cached_child_number_max}")
						end
					end
					@conditions_index_range_label.gui_render
				}
			}
		end
	end

	def gui_render_enable_checkbox
		enable_checkbox.gui_render
	end

	def enable_checkbox
		@enable_checkbox ||= GuiToggle.new(@object, :enabled).set(:offset_x => -0.45, :offset_y => 0.0, :scale_x => 0.09, :scale_y => 0.9)
	end

	def label_color
		if @object.crashy?
			LABEL_COLOR_CRASHY
		elsif !@object.enabled?
			LABEL_COLOR_DISABLED
		elsif !@object.conditions.event_satisfied?
			LABEL_COLOR_EVENT_OFF
		else
			LABEL_COLOR
		end
	end
end
