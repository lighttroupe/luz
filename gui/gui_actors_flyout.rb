#
# GuiActorsFlyout is the right-side list of Actors
#
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
			renderer = @actors_list.selection.first
			$gui.build_editor_for(renderer.object, :grab_keyboard_focus => true) if renderer
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
		self << @director_edit_button = GuiDirectorEditButton.new.set(:offset_y => 0.5 - 0.025, :scale_y => 0.05, :background_image => $engine.load_image('images/buttons/director-settings.png'), :background_image_hover => $engine.load_image('images/buttons/director-settings-hover.png'), :background_image_on => $engine.load_image('images/buttons/director-settings-on.png'))
		@director_edit_button.on_clicked {
			# create/view offscreen render actor
			#$gui.edit_chosen_director_offscreen_render_actor!(ActorRectangle)
			$gui.build_editor_for($gui.chosen_director)
		}

		# View directors button
		self << @director_view_button = GuiDirectorViewButton.new.set(:offset_y => 0.5 - 0.067, :scale_y => 0.03, :background_image => $engine.load_image('images/buttons/director-view.png'), :background_image_hover => $engine.load_image('images/buttons/director-view-hover.png'), :background_image_on => $engine.load_image('images/buttons/director-view-on.png'))
		@director_view_button.on_clicked {
			$gui.mode = :director
		}

		# Actor list				# TODO: item_aspect_ratio is related to screen ratio
		self << @actors_list = GuiList.new([]).set(:scroll_wrap => false, :scale_x => 0.88, :scale_y => 0.82, :offset_x => 0.05, :offset_y => 0.0, :spacing_y => -1.0, :item_aspect_ratio => 0.75)
		@actors_list.on_selection_change { on_list_selection_change }
		@actors_list.on_contents_change { on_list_contents_changed }

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
			actor = new_actor_with_defaults(klass)

			$gui.build_editor_for(actor, :pointer => pointer, :grab_keyboard_focus => true)

			renderer = create_renderer_for_actor(actor)
			@actors_list.add_after_selection(renderer)
			@actor_class_flyout.switch_state({:open => :closed}, duration=0.2)
		}

		# New actor button
		self << @new_button = GuiButton.new.set(:offset_y => -0.5 + 0.025, :scale_y => 0.05, :color => [1,1,1], :background_image => $engine.load_image('images/buttons/new-actor-button.png'), :background_image_hover => $engine.load_image('images/buttons/new-actor-button-hover.png'))

		@new_button.on_clicked { |pointer|
			@actor_class_flyout.switch_state({:open => :closed, :closed => :open}, duration=0.2)
			@actor_class_flyout.grab_keyboard_focus! if @actor_class_flyout.open?
		}
	end

	def new_actor_with_defaults(klass)
		actor = klass.new
		if false
			fade = ActorEffectFade.new
			fade.amount_setting.animation_min = 1.0
			actor.effects << fade
		end
		if false
			scale = ActorEffectScale.new
			scale.amount_setting.animation_min = 0.1
			actor.effects << scale
		end
		actor
	end

	def on_list_selection_change
		return unless (selection = @actors_list.selection.first)
		$gui.build_editor_for(selection.object, :grab_keyboard_focus => true)		# NOTE: undoing above wrapping
	end
	def on_list_contents_changed
		$gui.chosen_director.actors = @actors_list.map(&:object) if $gui.chosen_director
		$engine.project_changed!
	end

	def create_renderer_for_actor(actor)
		GuiActorRenderer.new(actor).set(:draggable => true, :background_image => $engine.load_image('images/overlay.png'))
	end

	def actors=(actors)
		@actors_list.contents = actors.map { |actor| create_renderer_for_actor(actor) }
	end

	def remove(actor)
		renderer = @actors_list.find { |renderer| renderer.object == actor }
		@actors_list.remove(renderer)
	end
end
