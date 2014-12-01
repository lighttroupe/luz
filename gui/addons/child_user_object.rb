#
# Addons for base class of all "effects" of UserObjects 
#
class ChildUserObject < UserObject
	LABEL_CHILD_INDEX_RANGE_COLOR = [1,1,0]

	#
	# Rendering
	#
	def self.gui_render!
		gui_render_label
	end

	def gui_render!
		gui_render_background
		gui_render_label
		gui_render_child_conditions
		gui_render_enable_checkbox
	end

	def gui_render_child_conditions
		if conditions.enable_child_index
			#@conditions_index_range_label = nil
			@conditions_index_range_label ||= GuiLabel.new.set(:scale_x => 0.45, :scale_y => 0.45)
			with_translation(0.20, -0.3) {
				with_color(LABEL_CHILD_INDEX_RANGE_COLOR) {
					if (@cached_child_number_min != conditions.child_number_min) || (@cached_child_number_max != conditions.child_number_max)
						@cached_child_number_min, @cached_child_number_max = conditions.child_number_min, conditions.child_number_max
						if @cached_child_number_min == @cached_child_number_max
							@conditions_index_range_label.set_string("only child #{@cached_child_number_min}")
						else
							@conditions_index_range_label.set_string("only children #{@cached_child_number_min}-#{@cached_child_number_max}")
						end
					end
					@conditions_index_range_label.gui_render!
				}
			}
		end
	end

	def gui_render_enable_checkbox
		enable_checkbox.gui_render!
	end

	def enable_checkbox
		@enable_checkbox ||= GuiToggle.new(self, :enabled).set(:offset_x => 0.45, :offset_y => 0.0, :scale_x => 0.09, :scale_y => 0.9)
	end

	def hit_test_render!
		super
		enable_checkbox.hit_test_render!
	end

	def label_color
		if crashy?
			LABEL_COLOR_CRASHY
		elsif !enabled?
			LABEL_COLOR_DISABLED
		elsif !conditions.event_satisfied?
			LABEL_COLOR_EVENT_OFF
		else
			LABEL_COLOR
		end
	end
end
