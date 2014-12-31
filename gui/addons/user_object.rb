#
# GUI addons for the base class for all objects the user makes (eg Actors, Actor Effects, Themes, Event Inputs)
#
class UserObject
	include MethodsForGuiObject
	include Drawing

	LABEL_COLOR_CRASHY = [1,0,0,0.35]
	LABEL_COLOR_EVENT_OFF = [1,1,0,0.35]
	LABEL_COLOR_DISABLED = [1,1,1,0.35]
	LABEL_COLOR = [1,1,1,1]
	USER_OBJECT_TITLE_HEIGHT = 1.0

	SHAKE_DISTANCE = 0.007

	#
	# Class level
	#
	extend Drawing
	def self.gui_render_label
		with_color(LABEL_COLOR) {
			@@class_title_label ||= Hash.new { |hash, key| hash[key] = GuiLabel.new.set(:width => 14, :string => key, :scale_x => 0.95, :scale_y => USER_OBJECT_TITLE_HEIGHT) }
			@@class_title_label[title].gui_render
		}
	end

	#
	# Instance level
	#
	def grab_keyboard_focus!
		effects_list_grab_focus!
	end

	def effects_list_grab_focus!
		@gui_effects_list.grab_keyboard_focus! if @gui_effects_list
	end

	def settings_list_grab_focus!
		@gui_settings_list.grab_keyboard_focus! if @gui_settings_list
	end

	def select_next_setting!
		if @gui_settings_list
			@gui_settings_list.grab_keyboard_focus!
			@gui_settings_list.select_next!
		end
	end

	def select_previous_setting!
		if @gui_settings_list
			@gui_settings_list.grab_keyboard_focus!
			@gui_settings_list.select_previous!
		end
	end

	def open_add_child_window!
		@add_child_window.grab_keyboard_focus!
		@add_child_window.switch_state({:closed => :open}, duration=0.2)
	end

	# Creates and returns a GuiObject to serve as an editor for this object
	def gui_build_editor
		if respond_to? :effects
			@box = box = GuiBox.new

			# Effects list
			@gui_effects_list = GuiList.new(effects).set(:spacing_y => -0.8, :scale_x => 0.32, :offset_x => -0.328, :offset_y => -0.03, :scale_y => 0.72, :item_aspect_ratio => 4.5)
			box << @gui_effects_list
			@gui_effects_list.on_selection_change {
				selection = @gui_effects_list.selection.first
				gui_fill_settings_list(selection) if selection
			}

			# ...scrollbar
			@gui_effects_list_scrollbar = GuiScrollbar.new(@gui_effects_list).set(:scale_x => 0.025, :offset_x => -0.152, :offset_y => -0.03, :scale_y => 0.75)
			box << @gui_effects_list_scrollbar

			# Add Child Popup Button
			@add_child_button = GuiButton.new.set(:scale_x => 0.1, :scale_y => 0.07, :offset_x => -0.435, :offset_y => -0.5 + 0.035, :background_image => $engine.load_image('images/buttons/add.png'))
			@add_child_button.on_clicked { |pointer|
				open_add_child_window!
			}
			box << @add_child_button

			# Clone button
			box << (@clone_button=GuiButton.new.set(:opacity => 0.5, :scale_x => 0.05, :scale_y => 0.07, :offset_x => -0.36, :offset_y => -0.5 + 0.035, :background_image => $engine.load_image('images/buttons/clone.png')))
			@clone_button.on_clicked { |pointer|
				clone_selected
			}

			# Remove button
			box << (@remove_child_button=GuiButton.new.set(:scale_x => 0.05, :scale_y => 0.07, :offset_x => -0.31, :offset_y => -0.5 + 0.035, :background_image => $engine.load_image('images/buttons/remove.png')))
			@remove_child_button.on_clicked { |pointer|
				remove_selected
			}

			# Settings list
			@gui_settings_list = GuiList.new.set(:spacing_y => -1.0, :scale_x => 0.55, :offset_x => 0.195, :offset_y => -0.035, :scale_y => 0.72, :item_aspect_ratio => 5.0)
			box << @gui_settings_list
			gui_fill_settings_list(self)		# show this object's settings

			# ...scrollbar
			@gui_settings_list_scrollbar = GuiScrollbar.new(@gui_settings_list).set(:scale_x => 0.03, :offset_x => -0.104, :offset_y => -0.03, :scale_y => 0.75)
			box << @gui_settings_list_scrollbar

			# Add Child Popup
			@add_child_window = GuiAddWindow.new(self)
			@add_child_window.on_add { |new_object|
				@add_child_window.hide!

				@gui_effects_list.add_after_selection(new_object)
				@gui_effects_list.set_selection(new_object)
				@gui_effects_list.scroll_to_selection!
				gui_fill_settings_list(new_object)
			}
			box << @add_child_window

			box
		else
			GuiObject.new		# nothing
		end
	end

	def remove_selected
		@gui_effects_list.selection.each { |object|
			effects.delete(object)
		}
	end

	def clone_selected
		$gui.positive_message "Clone...not implemented."
		#if (original = @gui_effects_list.selection.first)
			#duplicate = original.deep_clone { |obj| !(obj.is_a?(ParentUserObject)) }
			#duplicate.parent = nil
			#duplicate.reset_pointer_behavior!
			# more needed
			#@gui_effects_list.add_after_selection(duplicate)
			#@gui_effects_list.set_selection(duplicate)
		#end
	end

	def gui_fill_settings_list(user_object)
		return unless @gui_settings_list

		# UX: if we're selecting the parent object, no children (effects) should be selected
		if user_object == self
			@gui_effects_list.clear_selection!
		else	# selecting a child (effect)
			remove_child_conditions_widgets!
			build_child_conditions_widgets!(user_object)
		end

		@gui_settings_list.clear!
		user_object.settings.each_with_index { |setting, index|
			@gui_settings_list << setting.gui_build_editor.set(:opacity => 0.0, :scale_y => 0.8).animate({:opacity => 1.0}, duration=index*0.1)
		}
	end

private

	def build_child_conditions_widgets!(user_object)
		return unless user_object.respond_to? :conditions

		conditions_container = GuiBox.new.set(:scale_x => 0.45, :scale_y => 0.05, :offset_x => 0.18, :offset_y => 0.40)

		# only while event
		conditions_container << @gui_child_conditions_enable_event = GuiToggle.new(user_object.conditions, :enable_event).set(:scale_x => 0.035, :float => :left)
		conditions_container << @gui_child_conditions_event_invert = GuiToggle.new(user_object.conditions, :event_invert).set(:scale_x => 0.035, :float => :left)
		conditions_container << @gui_child_conditions_event = GuiEvent.new(user_object.conditions, :event).set(:scale_x => 0.4, :float => :left, :item_aspect_ratio => 5.0)

		# only applying to children 2-4
		if user_object.is_a? ActorEffect
			conditions_container << @gui_child_conditions_enable_child_index = GuiToggle.new(user_object.conditions, :enable_child_index).set(:offset_x => 0.05, :scale_x => 0.035, :float => :left)
			conditions_container << @gui_child_conditions_child_number_min = GuiInteger.new(user_object.conditions, :child_number_min, 1, 100).set(:scale_x => 0.1, :float => :left, :text_align => :center)
			conditions_container << @gui_child_conditions_child_number_max = GuiInteger.new(user_object.conditions, :child_number_max, 1, 100).set(:scale_x => 0.1, :float => :left, :text_align => :center)
		end

		@box << conditions_container
	end

	def remove_child_conditions_widgets!
		@gui_child_conditions_enable_event.remove_from_parent! if @gui_child_conditions_enable_event
		@gui_child_conditions_event.remove_from_parent! if @gui_child_conditions_event
		@gui_child_conditions_enable_child_index.remove_from_parent! if @gui_child_conditions_enable_child_index
		@gui_child_conditions_child_number_min.remove_from_parent! if @gui_child_conditions_child_number_min
		@gui_child_conditions_child_number_max.remove_from_parent! if @gui_child_conditions_child_number_max
	end

public

	#
	# Dragging
	#
	def draggable?
		true		# needed for list reordering
	end

	def drag_out(pointer)
		if pointer.drag_delta_y > 0
			parent.move_child_up(self)
		else
			parent.move_child_down(self)
		end
	end

	#
	# Ticking
	#
	def gui_tick! ; end
	def self.gui_tick! ; end

	#
	# Rendering
	#
	def gui_render
		gui_render_background
		gui_render_label
	end

	def gui_render_label
		if pointer_dragging?
			with_translation(SHAKE_DISTANCE * rand, SHAKE_DISTANCE * rand) {
				gui_render_label_internal
			}
		else
			gui_render_label_internal
		end
	end

	def hit_test_render!
		with_unique_hit_test_color_for_object(self) { unit_square }
	end

	#
	# Pointer
	#
	def click(pointer)
		$gui.build_editor_for(self, :pointer => pointer, :grab_keyboard_focus => true)
		@parent.child_click(pointer) if @parent
	end

	# TODO: called by the $gui...
	def on_child_user_object_selected(user_object)
		@gui_effects_list.set_selection(user_object) if @gui_effects_list
	end

private

	def gui_render_label_internal
		with_color(label_color) {
			@title_label ||= GuiLabel.new.set(:width => label_ems, :scale_y => USER_OBJECT_TITLE_HEIGHT)
			@title_label.string = title
			@title_label.gui_render
		}
	end

	def label_ems
		12
	end

	def label_color
		if crashy?
			LABEL_COLOR_CRASHY
		elsif !usable?
			LABEL_COLOR_UNUSABLE
		else
			LABEL_COLOR
		end
	end
end
