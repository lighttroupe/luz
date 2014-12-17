class UserObjectSettingActor
	def gui_build_editor
		box = GuiBox.new
		box << create_user_object_setting_name_label
		box << GuiActor.new(self, :actor).set(:float => :left, :scale_x => 0.2, :scale_y => 0.9, :offset_y => -0.2, :item_aspect_ratio => 2.0)

		box << new_button=GuiButton.new.set(:scale_x => 0.08, :float => :left, :background_image => $engine.load_image('images/buttons/new.png'), :background_image_hover => $engine.load_image('images/buttons/new.png'), :background_image_click => $engine.load_image('images/buttons/new.png'))
		new_button.on_clicked { |pointer|
			select_actor_klass(pointer) { |klass|
				@actor = klass.new
				$engine.project.actors << @actor
			}
		}

		box << edit_button=GuiButton.new.set(:scale_x => 0.08, :float => :left, :background_image => $engine.load_image('images/buttons/new.png'), :background_image_hover => $engine.load_image('images/buttons/new.png'), :background_image_click => $engine.load_image('images/buttons/new.png'))
		edit_button.on_clicked { |pointer|
			$gui.build_editor_for(@actor, :pointer => pointer)
		}

		box << clear_button=GuiButton.new.set(:float => :left, :scale_x => 0.05, :scale_y => 0.8, :offset_y => -0.2, :background_image => $engine.load_image('images/buttons/menu.png'), :background_image_hover => $engine.load_image('images/buttons/menu.png'), :background_image_click => $engine.load_image('images/buttons/menu.png'))
		clear_button.on_clicked {
			@actor = nil
		}
		box
	end

	def select_actor_klass(pointer)
		yield ActorRectangle		# TODO
	end
end
