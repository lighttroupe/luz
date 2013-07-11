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
		else
			super
		end
	end

	def create!
		# Background
		self << (@background=GuiObject.new.set(:background_image => $engine.load_image('images/actor-flyout-background.png')))

		# View directors button
		self << @director_view_button = GuiButton.new.set(:offset_y => 0.5 - 0.025, :scale_y => 0.05, :background_image => $engine.load_image('images/buttons/director-view.png'))
		@director_view_button.on_clicked {
			$gui.build_editor_for($gui.chosen_director)
		}

		# Actor list				# TODO: item_aspect_ratio is related to screen ratio
		self << @actors_list = GuiList.new([]).set(:scroll_wrap => true, :scale_x => 0.91, :scale_y => 0.82, :offset_x => 0.036, :offset_y => 0.0, :spacing_y => -1.0, :item_aspect_ratio => 0.75)
		@actors_list.on_selection_change { on_list_selection_change }

#			klass = ActorStarFlower
#			@actors_list.add_after_selection(actor = klass.new)
#			$gui.build_editor_for(actor, :pointer => pointer)

		# Actor Class flyout (for creating new actors)
		self << @actor_class_flyout = GuiActorClassFlyout.new.set(:scale_x => 0.5, :scale_y => 0.3).
			add_state(:open, {:offset_y => -0.3, :hidden => false}).
			set_state(:closed, {:offset_y => -0.8, :hidden => true})

		@actor_class_flyout.on_actor_class_selected { |pointer, klass|
			actor = klass.new
			@actors_list.add_after_selection(actor)
			$gui.build_editor_for(actor, :pointer => pointer)
			@actor_class_flyout.switch_state({:open => :closed}, duration=0.2)
		}

		# New actor button
		self << @new_button = GuiButton.new.set(:offset_y => -0.5 + 0.025, :scale_y => 0.05, :color => [1,1,1], :background_image => $engine.load_image('images/buttons/new-actor-button.png'))

		@new_button.on_clicked { |pointer|
			@actor_class_flyout.switch_state({:open => :closed, :closed => :open}, duration=0.2)
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
