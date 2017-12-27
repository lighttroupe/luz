#
# GuiDirectorMenu is the fullscreen director grid
#
class GuiDirectorMenu < GuiWindow
	def initialize(directors)
		super()
		create!
		set_directors(directors)
		update_grid_size!
	end

	def create!
		self << @background = GuiObject.new.set(:background_image => $engine.load_image('images/overlay.png'))

		self << @grid = GuiGrid.new.set(:scale => 0.95, :spacing_x => 0.1, :spacing_y => 0.1, :min_columns => 3)

		self << @output_view_button = GuiOutputViewButton.new.set(:scale_x => 0.05, :scale_y => 0.06, :offset_x => -0.475, :offset_y => 0.47, :background_image => $engine.load_image('images/buttons/output-view.png'), :background_image_hover => $engine.load_image('images/buttons/output-view-hover.png'), :background_image_click => $engine.load_image('images/buttons/output-view-click.png'), :background_image_on => $engine.load_image('images/buttons/output-view-on.png'))
		@output_view_button.on_clicked {
			$gui.mode = :output
			close!
		}

		self << @project_effects_button = GuiButton.new.set(:scale_x => 0.05, :scale_y => 0.06, :offset_x => 0.475, :offset_y => -0.47, :background_image => $engine.load_image('images/buttons/project-effects.png'), :background_image_hover => $engine.load_image('images/buttons/project-effects-hover.png'), :background_image_click => $engine.load_image('images/buttons/project-effects-click.png'))
		@project_effects_button.on_clicked {
			$gui.build_editor_for($engine.project)
			close!
		}

		self << @add_button = GuiButton.new.set(:scale_x => 0.05, :scale_y => 0.06, :offset_x => -0.475, :offset_y => -0.47, :background_image => $engine.load_image('images/buttons/new-director.png'), :background_image_hover => $engine.load_image('images/buttons/new-director-hover.png'), :background_image_click => $engine.load_image('images/buttons/new-director-click.png'))
		@add_button.on_clicked {
			add_new_director!
		}

		self << @cancel_button = GuiButton.new.set(:scale_x => 0.05, :scale_y => 0.06, :offset_x => 0.475, :offset_y => 0.47, :background_image => $engine.load_image('images/buttons/director-view-close.png'), :background_image_hover => $engine.load_image('images/buttons/director-view-close-hover.png'), :background_image_click => $engine.load_image('images/buttons/director-view-close-click.png'))
		@cancel_button.on_clicked {
			close!
		}
	end

	def set_directors(directors)
		directors.each { |director| @grid << create_renderer_for_director(director) }
	end

	def add_new_director!
		director = Director.new
		$engine.project.directors << director
		@grid << create_renderer_for_director(director)
		update_grid_size!
		$gui.chosen_director = director
		switch_state({:open => :closed}, duration=0.5)
	end

	def create_renderer_for_director(director)
		renderer = director.new_renderer.set(:background_image => $engine.load_image('images/director-menu-director-background.png'))
		# callbacks
		renderer.on_clicked { |pointer|
			renderer.animate(:gui_enter_exit_progress, 0.5, 0.1)
			@grid.set_selection(renderer)
			$gui.chosen_next_director = director		# for playing live
			renderer.grab_keyboard_focus!
		}
		renderer.on_double_clicked { |pointer|
			close!
			$gui.chosen_director = director
		}
		renderer
	end

	def grab_keyboard_focus!
		@grid.first.grab_keyboard_focus! if @grid.first
	end

	def close!
		super
		$gui.default_focus!
	end

	def on_key_press(key)
		if key.control?
			case key
			when 'n'
				add_new_director!
			when 'up'
				close!
			else
				super
			end
		else
			case key
			when 'escape'
				close!
			when 'return'
				selected = @grid.selection.first
				if selected
					close!
					$gui.chosen_director = selected.object
				end
			else
				super
			end
		end
	end

private

	def update_grid_size!
		@grid.min_columns = (@grid.count > 9) ? (@grid.count > 16 ? 5 : 4) : 3
	end
end
