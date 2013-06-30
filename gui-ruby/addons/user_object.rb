#
# GUI addons for the base class for all objects the user makes (eg Actors, Actor Effects, Themes, Event Inputs)
#
class UserObject
	include MethodsForGuiObject

	LABEL_COLOR_CRASHY = [1,0,0,0.5]
	LABEL_COLOR_ENABLED = [1,1,1,1]
	LABEL_COLOR_DISABLED = [1.0, 1.0, 1.0, 0.25]
	USER_OBJECT_TITLE_HEIGHT = 0.65

	SHAKE_DISTANCE = 0.007

	# Creates and returns a GuiObject to serve as an editor for this object
	def gui_build_editor
		if respond_to? :effects
			box = GuiBox.new

			# Effects list
			@gui_effects_list = GuiListWithControls.new(effects).set({:spacing_y => -0.8, :scale_x => 0.334, :offset_x => -0.33, :offset_y => -0.025, :scale_y => 0.75, :item_aspect_ratio => 4.5})
			box << @gui_effects_list

			# ...scrollbar
			@gui_effects_list_scrollbar = GuiScrollbar.new(@gui_effects_list).set({:scale_x => 0.025, :offset_x => -0.152, :offset_y => -0.03, :scale_y => 0.75})
			box << @gui_effects_list_scrollbar

			# Add Button
			@add_child_button = GuiButton.new.set(:scale_x => 0.07, :scale_y => 0.11, :offset_x => -0.46, :offset_y => -0.5 + 0.07, :background_image => $engine.load_image('images/buttons/add.png'))
			box << @add_child_button
			@add_child_button.on_clicked { |pointer|
				window = build_add_child_window_for_pointer(pointer)
				window.on_add { |new_object|
					@gui_effects_list.add_after_selection(new_object)
					@gui_effects_list.set_selection(new_object)
					@gui_effects_list.scroll_to_selection!

					gui_fill_settings_list(new_object)
				}
				$gui << window
			}

			# Clone button
			box << (@clone_button=GuiButton.new.set(:opacity => 0.5, :scale_x => 0.07, :scale_y => 0.11, :offset_x => -0.38, :offset_y => -0.5 + 0.07, :background_image => $engine.load_image('images/buttons/clone.png')))
			@clone_button.on_clicked { |pointer|
				clone_selected
			}

			# Remove button
			box << (@remove_child_button=GuiButton.new.set(:scale_x => 0.07, :scale_y => 0.11, :offset_x => -0.30, :offset_y => -0.5 + 0.07, :background_image => $engine.load_image('images/buttons/remove.png')))
			@remove_child_button.on_clicked { |pointer|
				remove_selected
			}

			# Settings list
			@gui_settings_list = GuiList.new.set({:spacing_y => -1.0, :scale_x => 0.55, :offset_x => 0.195, :offset_y => -0.04, :scale_y => 0.75, :item_aspect_ratio => 5.0})
			box << @gui_settings_list
			gui_fill_settings_list(self)		# show this object's settings

			# ...scrollbar
			@gui_settings_list_scrollbar = GuiScrollbar.new(@gui_settings_list).set({:scale_x => 0.03, :offset_x => -0.104, :offset_y => -0.03, :scale_y => 0.75})
			box << @gui_settings_list_scrollbar

			box
		else
			GuiObject.new		# nothing
		end
	end

	def build_add_child_window_for_pointer(pointer)
		window = GuiAddWindow.new(self)
		window.set({:offset_x => 0.0, :offset_y => -0.65, :opacity => 0.0, :scale_x => 0.5, :scale_y => 0.4, :hidden => false})
		window.animate({:offset_x => 0.0, :offset_y => -0.3, :scale_x => 0.5, :scale_y => 0.4, :opacity => 1.0}, duration=0.2)
		window
	end

	def remove_selected
		@gui_effects_list.selection.each { |object|
			effects.delete(object)
		}
	end

	def clone_selected
		$gui.positive_message 'Clone...not implemented.'
	end

	def gui_fill_settings_list(user_object)
		return unless @gui_settings_list

		@gui_effects_list.clear_selection! if user_object == self

		@gui_settings_list.clear!
		user_object.settings.each { |setting|
			@gui_settings_list << setting.gui_build_editor
		}
	end

	def has_settings_list?
		!@gui_settings_list.nil?
	end

	#
	# Draggable
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
	# Rendering
	#
	def gui_render!
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

	def gui_render_label_internal
		with_color(label_color) {
			@title_label ||= BitmapFont.new.set(:scale_x => 0.95, :scale_y => USER_OBJECT_TITLE_HEIGHT)
			@title_label.string = title
			if pointer_hovering?
				@title_label.gui_render!
			else
				with_vertical_clip_plane_right_of(0.5) {
					@title_label.gui_render!
				}
			end
		}
	end

	def self.gui_render_label
		with_color([1,1,1,1]) {
			@@class_title_label ||= Hash.new { |hash, key| hash[key] = BitmapFont.new.set(:string => key, :scale_x => 0.95, :scale_y => USER_OBJECT_TITLE_HEIGHT) }
			@@class_title_label[title].gui_render!
		}
	end

	def hit_test_render!
		with_unique_hit_test_color_for_object(self, 0) { unit_square }
	end

	#
	# Pointer
	#
	def click(pointer)
		$gui.build_editor_for(self, :pointer => pointer)
		@parent.child_click(pointer) if @parent
	end

	# TODO: called by the $gui... @gui_effects_list.on_selection_change { ... }
	def on_child_user_object_selected(user_object)
		gui_fill_settings_list(user_object)
		@gui_effects_list.set_selection(user_object) if @gui_effects_list
	end

	#
	# Helpers
	#

private

	def label_color
		if crashy?
			LABEL_COLOR_CRASHY
		elsif enabled?
			LABEL_COLOR_ENABLED
		else
			LABEL_COLOR_DISABLED
		end
	end
end
