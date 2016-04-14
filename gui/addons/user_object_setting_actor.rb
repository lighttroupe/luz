class UserObjectSettingActor
	def set_to_new_actor_of_class(klass)
		@actor = klass.new
		$engine.project.actors << @actor
	end

	def gui_build_editor
		box = GuiBox.new
		box << create_user_object_setting_name_label
		box << GuiActor.new(self, :actor).set(:float => :left, :scale_x => 0.3, :scale_y => 0.9, :offset_y => -0.3, :item_aspect_ratio => 2.0)

		box << new_button=GuiButton.new.set(:float => :left, :scale_x => 0.10, :scale_y => 0.70, :offset_y => -0.3, :background_image => $engine.load_image('images/buttons/new-actor.png'), :background_image_hover => $engine.load_image('images/buttons/new-actor-hover.png'), :background_image_click => $engine.load_image('images/buttons/new-actor-click.png'))
		new_button.on_clicked { |pointer|
			select_actor_klass(pointer) { |klass|
				set_to_new_actor_of_class(klass)
			}
		}

		box << edit_button=GuiButton.new.set(:float => :left, :scale_x => 0.07, :scale_y => 0.70, :offset_x => 0.01, :offset_y => -0.3, :background_image => $engine.load_image('images/buttons/edit-actor.png'), :background_image_hover => $engine.load_image('images/buttons/edit-actor-hover.png'), :background_image_click => $engine.load_image('images/buttons/edit-actor-click.png'))
		edit_button.on_clicked { |pointer|
			$gui.build_editor_for(@actor, :pointer => pointer)
		}

		box << clear_button=GuiButton.new.set(:float => :left, :scale_x => 0.07, :scale_y => 0.7, :offset_x => 0.02, :offset_y => -0.3, :background_image => $engine.load_image('images/buttons/clear.png'), :background_image_hover => $engine.load_image('images/buttons/clear-hover.png'), :background_image_click => $engine.load_image('images/buttons/clear-click.png'))
		clear_button.on_clicked {
			@actor = nil
		}
		box
	end

	def select_actor_klass(pointer)
		yield ActorRectangle		# TODO
	end
end
