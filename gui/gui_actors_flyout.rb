multi_require 'gui_actor_class_flyout'

class GuiActorsFlyout < GuiWindow
	def initialize
		super
		create!
	end

	def on_key_press(key)
		if key == 'down' && !key.control?
			@actors_list.select_next!
			@actors_list.scroll_to_selection!
		elsif key == 'up' && !key.control?
			@actors_list.select_previous!
			@actors_list.scroll_to_selection!
		elsif key == 'return'
			actor = @actors_list.selection.first
			$gui.build_editor_for(actor) if actor
		elsif key == 'n' && key.control?
			@actor_class_flyout.switch_state({:open => :closed, :closed => :open}, duration=0.2)
			@actor_class_flyout.grab_keyboard_focus! if @actor_class_flyout.open?
		else
			super
		end
	end

	def create!
		# Background
		self << (@background=GuiObject.new.set(:background_image => $engine.load_image('images/actor-flyout-background.png')))

		# Edit director button
		self << @director_edit_button = GuiButton.new.set(:offset_y => 0.5 - 0.025, :scale_y => 0.05, :background_image => $engine.load_image('images/buttons/director-settings.png'), :background_image_hover => $engine.load_image('images/buttons/director-settings-hover.png'))
		@director_edit_button.on_clicked {
			$gui.build_editor_for($gui.chosen_director)
		}

		# View directors button
		self << @director_view_button = GuiButton.new.set(:offset_y => 0.5 - 0.067, :scale_y => 0.03, :background_image => $engine.load_image('images/buttons/director-view.png'), :background_image_hover => $engine.load_image('images/buttons/director-view-hover.png'))
		@director_view_button.on_clicked {
			$gui.mode = :director
		}

		# Actor list				# TODO: item_aspect_ratio is related to screen ratio
		self << @actors_list = GuiList.new([]).set(:scroll_wrap => false, :scale_x => 0.88, :scale_y => 0.82, :offset_x => 0.05, :offset_y => 0.0, :spacing_y => -1.0, :item_aspect_ratio => 0.75)
		@actors_list.on_selection_change { on_list_selection_change }

		# ...scrollbar
		@gui_actors_list_scrollbar = GuiScrollbar.new(@actors_list).set(:scale_x => 0.08, :scale_y => 0.82, :offset_x => -0.43, :offset_y => 0.0)
		self << @gui_actors_list_scrollbar

#			klass = ActorStarFlower
#			@actors_list.add_after_selection(actor = klass.new)
#			$gui.build_editor_for(actor, :pointer => pointer)

		# Actor Class flyout (for creating new actors)
		self << @actor_class_flyout = GuiActorClassFlyout.new.set(:scale_x => 0.9, :scale_y => 0.2).
			add_state(:open, {:offset_y => -0.35, :hidden => false}).
			set_state(:closed, {:offset_y => -0.8, :hidden => true})

		@actor_class_flyout.on_actor_class_selected { |pointer, klass|
			actor = klass.new
			@actors_list.add_after_selection(actor)
			$engine.project_changed!
			$gui.build_editor_for(actor, :pointer => pointer, :grab_keyboard_focus => true)
			@actor_class_flyout.switch_state({:open => :closed}, duration=0.2)
		}

		# New actor button
		self << @new_button = GuiButton.new.set(:offset_y => -0.5 + 0.025, :scale_y => 0.05, :color => [1,1,1], :background_image => $engine.load_image('images/buttons/new-actor-button.png'), :background_image_hover => $engine.load_image('images/buttons/new-actor-button-hover.png'))

		@new_button.on_clicked { |pointer|
			@actor_class_flyout.switch_state({:open => :closed, :closed => :open}, duration=0.2)
			@actor_class_flyout.grab_keyboard_focus! if @actor_class_flyout.open?
		}
	end

	def on_list_selection_change
		return unless (selection = @actors_list.selection.first)
		$gui.build_editor_for(selection)		#.object)		# NOTE: undoing above wrapping
	end

	def actors=(actors)
		@actors_list.contents = actors
	end

	def remove(actor)
		@actors_list.remove(actor)
	end
end
