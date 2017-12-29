#
# GuiUserObjectEditor is the main editor window
#
class GuiUserObjectEditor < GuiWindow
	attr_accessor :pointer

	BACKGROUND_COLOR = [0,0,0,0.95]

	def initialize(user_object, options)
		@user_object, @options = user_object, options
		super([])
		create!
		set(options)
	end

	#
	# Keyboard interactions
	#
	def on_key_press(key)
		if key.control?
			if key == 'd'
				clone_selected
			elsif key == 'e'
				if (effect = selected_effect)
					$engine.view_source(effect.class)
				else
					$engine.view_source(@user_object.class)
				end
			elsif key == 'n'
				open_add_child_window!
			elsif key == 'delete'
				remove_selected_effect
			else
				super
			end
		else
			if key == 'left'
				effects_list_grab_focus!
			elsif key == 'right'
				settings_list_grab_focus!
			elsif key == 'tab'
				if key.shift?
					effects_list_grab_focus!
				else
					select_next_setting!
				end
			else
				super
			end
		end
	end

	def gui_render
		super
		if @class_icon_button
			if @user_object.ticked_recently?
				@class_icon_button.switch_state({:inactive => :active}, duration=0.1)
			else
				@class_icon_button.switch_state({:active => :inactive}, duration=0.1)
			end
		end
	end

	def create!
		# Background
		self << (@background=GuiObject.new.set(:background_image => $engine.load_image('images/user-object-editor-background.png')))

		#
		# Icon and Title
		#
		if @user_object.is_a? Actor
			self << (@class_icon_button=GuiClassInstanceRendererButton.new(@user_object.class).set(:offset_x => -0.5 + 0.049, :offset_y => 0.5 - 0.075, :scale_x => 0.04, :scale_y => 0.06))
			@class_icon_button.add_state(:active, {:opacity => 1.0})
			@class_icon_button.set_state(:inactive, {:opacity => 0.25})
			@class_icon_button.on_clicked {
				gui_fill_settings_list(@user_object)
				@title_text.cancel_keyboard_focus!
			}

			self << (@view_button=GuiButton.new.set(:offset_x => 0.50 - 0.05, :offset_y => 0.5 - 0.07, :scale_x => 0.05, :scale_y => 0.1, :background_image => $engine.load_image('images/actor-view-background.png')))
			@view_button.on_clicked { |pointer|
				$gui.chosen_actor = @user_object
				$gui.mode = :actor
			}
		end

		self << (@title_text=GuiString.new(@user_object, :title).set(:width => 14, :offset_x => -0.30 + 0.07, :offset_y => 0.5 - 0.07, :scale_x => 0.35, :scale_y => 0.1))		#.set(:background_image => $engine.load_image('images/buttons/menu.png'))

		#
		# Delete Button
		#
		self << (@delete_button = GuiDeleteButton.new.set(:scale_x => 0.10, :scale_y => 0.07, :offset_x => 0.45, :offset_y => -0.5 + 0.035, :background_image => $engine.load_image('images/buttons/delete-background.png')))
		@delete_button.on_clicked { |pointer|
			$gui.trash!(@user_object)
		}

		#
		# Close Button
		#
		self << (@close_button=GuiButton.new.set(:scale_x => 0.15, :scale_y => 0.07, :offset_x => 0.0, :offset_y => -0.5 + 0.035, :background_image => $engine.load_image('images/buttons/close.png'), :background_image_hover => $engine.load_image('images/buttons/close-hover.png')))
		@close_button.on_clicked { $gui.clear_user_object_editor }

		#
		# Let object build its own content (eg. lists of effects and settings: gui/addons/user_object.rb)
		#
		self << gui_build_editor		# find gui_build_editor implementations in gui/addons
	end

	# Creates and returns a GuiObject to serve as an editor for this object
	def gui_build_editor
		if @user_object.respond_to? :effects
			box = GuiBox.new

			# Effects list
			@gui_effects_list = GuiList.new(@user_object.effects.map(&:new_renderer)).set(:spacing_y => -0.8, :scale_x => 0.32, :offset_x => -0.328, :offset_y => -0.03, :scale_y => 0.72, :item_aspect_ratio => 4.5)
			box << @gui_effects_list
			@gui_effects_list.on_selection_change {
				selection = @gui_effects_list.selection.first
				gui_fill_settings_list(selection.object) if selection
			}
			@gui_effects_list.on_contents_change { set_user_object_effects_from_gui! }

			# ...scrollbar
			@gui_effects_list_scrollbar = GuiScrollbar.new(@gui_effects_list).set(:scale_x => 0.025, :offset_x => -0.152, :offset_y => -0.03, :scale_y => 0.75)
			box << @gui_effects_list_scrollbar

			# Add Child Popup Button
			@add_child_button = GuiButton.new.set(:scale_x => 0.1, :scale_y => 0.07, :offset_x => -0.435, :offset_y => -0.5 + 0.035, :background_image => $engine.load_image('images/buttons/add.png'), :background_image_hover => $engine.load_image('images/buttons/add-hover.png'))
			@add_child_button.on_clicked { |pointer|
				open_add_child_window!
			}
			box << @add_child_button

			# Clone button
			box << (@clone_button=GuiButton.new.set(:opacity => 0.5, :scale_x => 0.05, :scale_y => 0.07, :offset_x => -0.36, :offset_y => -0.5 + 0.035, :background_image => $engine.load_image('images/buttons/clone.png'), :background_image_hover => $engine.load_image('images/buttons/clone-hover.png')))
			@clone_button.on_clicked { |pointer|
				clone_selected
			}

			# Remove button
			box << (@remove_child_button=GuiButton.new.set(:scale_x => 0.05, :scale_y => 0.07, :offset_x => -0.31, :offset_y => -0.5 + 0.035, :background_image => $engine.load_image('images/buttons/remove.png'), :background_image_hover => $engine.load_image('images/buttons/remove-hover.png')))
			@remove_child_button.on_clicked { |pointer|
				remove_selected_effect
			}

			# Settings list
			@gui_settings_list = GuiList.new.set(:spacing_y => -1.0, :scale_x => 0.55, :offset_x => 0.195, :offset_y => -0.035, :scale_y => 0.72, :item_aspect_ratio => 5.0)
			box << @gui_settings_list
			gui_fill_settings_list(@user_object)		# show this object's settings

			# ...scrollbar
			@gui_settings_list_scrollbar = GuiScrollbar.new(@gui_settings_list).set(:scale_x => 0.03, :offset_x => -0.104, :offset_y => -0.03, :scale_y => 0.75)
			box << @gui_settings_list_scrollbar

			# Add Child Popup
			@add_child_window = GuiAddWindow.new(@user_object)
			@add_child_window.on_add { |new_effect|
				@add_child_window.hide!
				add_and_select_new_effect(new_effect)
				settings_list_grab_focus!
			}
			box << @add_child_window

			box
		else
			GuiObject.new		# nothing
		end
	end

	def gui_fill_settings_list(user_object)
		return unless @gui_settings_list

		# UX: if we're selecting the parent object, no children (effects) should be selected
		if user_object == @user_object
			@gui_effects_list.clear_selection!
		else	# selecting a child (effect)
			remove_child_conditions_widgets!
			build_child_conditions_widgets!(user_object)
		end
		build_settings_list_for(user_object)
	end

	def build_settings_list_for(user_object)
		@gui_settings_list.clear!
		user_object.settings.each_with_index { |setting, index|
			# each UserObjectSetting builds its own gui editor, see gui/addons
			@gui_settings_list << setting.gui_build_editor.set(:opacity => 0.0, :scale_y => 0.8).animate({:opacity => 1.0}, duration=index*0.1)
		}
	end

	#
	# child conditions (eg only-while-event and only-children-2-to-5)
	#
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

		self << conditions_container
	end
	def remove_child_conditions_widgets!
		@gui_child_conditions_enable_event.remove_from_parent! if @gui_child_conditions_enable_event
		@gui_child_conditions_event.remove_from_parent! if @gui_child_conditions_event
		@gui_child_conditions_enable_child_index.remove_from_parent! if @gui_child_conditions_enable_child_index
		@gui_child_conditions_child_number_min.remove_from_parent! if @gui_child_conditions_child_number_min
		@gui_child_conditions_child_number_max.remove_from_parent! if @gui_child_conditions_child_number_max
	end

	#
	# Helpers
	#
	def grab_keyboard_focus!
		effects_list_grab_focus!
	end

	def edit_title
		@title_text.grab_keyboard_focus!
	end

	def open_add_child_window!
		@add_child_window.grab_keyboard_focus!
		@add_child_window.switch_state({:closed => :open}, duration=0.2)
	end

	def clone_selected
		#$gui.positive_message "Clone...not implemented."
		if (selected = @gui_effects_list.selection.first)
			original = selected.object
			duplicate = original.deep_clone_user_object
			renderer = duplicate.new_renderer
			@gui_effects_list.add_after_selection(renderer)
			@gui_effects_list.set_selection(renderer)
		end
	end

	def hide!
		#switch_state({:open => :closed}, duration=0.1)
		remove_from_parent!
		$gui.default_focus!
	end

	def close!
		animate({:opacity => 0.0, :offset_y => offset_y - 0.2, :scale_x => scale_x * 1.1}, duration=0.2) { set_hidden(true) }
		$gui.show_reopen_button!
	end

	#
	# Effects list
	#
	def effects_list_grab_focus!
		@gui_effects_list.grab_keyboard_focus! if @gui_effects_list
	end

	def set_user_object_effects_from_gui!
		@user_object.effects = @gui_effects_list.map(&:object)
		$engine.project_changed!
	end

	def selected_effect
		selection = @gui_effects_list.selection
		if selection.count == 1
			selection.first.object
		end
	end

	def add_and_select_new_effect(new_effect)
		renderer = new_effect.new_renderer
		@gui_effects_list.add_after_selection(renderer)
		@gui_effects_list.set_selection(renderer)
		@gui_effects_list.scroll_to_selection!
		@user_object.effects = @gui_effects_list.map(&:object)
		gui_fill_settings_list(new_effect)
		$engine.project_changed!
	end

	def remove_selected_effect
		@gui_effects_list.selection.each { |renderer|
			@user_object.effects.delete(renderer.object)
			@gui_effects_list.remove(renderer)
		}
		@gui_effects_list.clear_selection!		# needed?
		@gui_settings_list.clear!							# (was showing for selected/deleted object)
		#build_settings_list_for(self)
	end

	#
	# Settings list
	#
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
end
