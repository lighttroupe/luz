#
# GuiMainMenu is the main application menu with project options and quit
#
class GuiMainMenu < GuiWindow
	callback :save, :close, :open, :new, :quit

	def initialize
		super
		create!
	end

	def create!
		self << @cancel_button = GuiButton.new.set(:scale_x => 0.05, :scale_y => 0.06, :offset_x => -0.475, :offset_y => 0.47, :background_image => $engine.load_image('images/buttons/main-menu-close.png'), :background_image_hover => $engine.load_image('images/buttons/main-menu-close-hover.png'), :background_image_click => $engine.load_image('images/buttons/main-menu-close-click.png'))
		@cancel_button.on_clicked { close_notify }

		self << @open_button = GuiButton.new.set(:scale_x => 0.05, :scale_y => 0.06, :offset_x => 0.475, :offset_y => 0.47, :background_image => $engine.load_image('images/buttons/main-menu-open.png'), :background_image_hover => $engine.load_image('images/buttons/main-menu-open-hover.png'), :background_image_click => $engine.load_image('images/buttons/main-menu-open-click.png'))
		@open_button.on_clicked { open_notify }

		self << @new_button = GuiButton.new.set(:scale_x => 0.02, :scale_y => 0.05, :offset_x => 0.5 - 0.010, :offset_y => 0.4, :background_image => $engine.load_image('images/buttons/main-menu-new.png'), :background_image_hover => $engine.load_image('images/buttons/main-menu-new-hover.png'), :background_image_click => $engine.load_image('images/buttons/main-menu-new.png'))
		@new_button.on_clicked { new_notify }

		self << (@text1 = GuiLabel.new.set({:string => 'Luz 2.0', :offset_x => 0.0, :offset_y => 0.335, :scale_x => 0.1, :scale_y => 0.07, :width => 4, :text_align => :fill}))
		#self << (@text2 = GuiLabel.new.set({:string => 'Early Access Edition', :offset_x => 0.0, :offset_y => 0.26, :scale_x => 0.15, :scale_y => 0.04, :width => 10, :text_align => :fill}))

		self << @background = GuiButton.new.set(:offset_x => 0.00, :offset_y => 0.00, :scale_x => 0.10, :scale_y => 0.15, :background_image => $engine.load_image('images/luz-icon-border.png'))
		self << @star_button = GuiButton.new.set(:offset_x => 0.00, :offset_y => 0.00, :scale_x => 0.07, :scale_y => 0.09, :background_image => $engine.load_image('images/luz-starflower.png'))
		@star_button.on_clicked { close_notify }

		self << (@text3 = GuiLabel.new.set({:color => [1.0,0.5,0.5], :string => 'ian@openanswers.org', :offset_x => 0.0, :offset_y => -0.3, :scale_x => 0.3, :scale_y => 0.05, :width => 18, :text_align => :fill}))

		self << (@cancel_text = GuiLabel.new.set({:color => [0.6,0.6,1.0], :string => 'play', :offset_x => -0.42, :offset_y => 0.48, :scale_x => 0.05, :scale_y => 0.04, :width => 4, :text_align => :fill}))
		self << (@open_text   = GuiLabel.new.set({:color => [0.6,0.6,1.0], :string => 'open', :offset_x => 0.425, :offset_y => 0.48, :scale_x => 0.05, :scale_y => 0.04, :width => 4, :text_align => :fill}))
		self << (@quit_text   = GuiLabel.new.set({:color => [0.6,0.6,1.0], :string => 'quit', :offset_x => -0.42, :offset_y => -0.47, :scale_x => 0.05, :scale_y => 0.04, :width => 4, :text_align => :fill}))
		self << (@save_text   = GuiLabel.new.set({:color => [0.6,0.6,1.0], :string => 'save', :offset_x => 0.425, :offset_y => -0.47, :scale_x => 0.05, :scale_y => 0.04, :width => 4, :text_align => :fill}))

		project_file_name = $engine.project.path ? $engine.project.path : ''
		self << (@project_name = GuiLabel.new.set({:string => project_file_name, :width => 45, :text_align => :center, :offset_x => 0.0, :offset_y => -0.475, :scale_x => 0.7, :scale_y => 0.025}))

		self << @save_button = GuiButton.new.set(:scale_x => 0.05, :scale_y => 0.06, :offset_x => 0.475, :offset_y => -0.47, :background_image => $engine.load_image('images/buttons/main-menu-save.png'), :background_image_hover => $engine.load_image('images/buttons/main-menu-save-hover.png'), :background_image_click => $engine.load_image('images/buttons/main-menu-save-click.png'))
		@save_button.on_clicked { save_notify ; close_notify }

		# settings
		self << @settings_window = GuiSettingsWindow.new.set(:scale_x => 0.35, :scale_y => 0.7).
			add_state(:open, {:offset_x => -0.325, :hidden => false}).
			set_state(:closed, {:offset_x => -0.56, :hidden => true})

		self << @settings_button = GuiButton.new.set(:scale_x => 0.02, :scale_y => 0.05, :offset_x => -0.49, :offset_y => 0.4, :background_image => $engine.load_image('images/buttons/main-menu-settings.png'), :background_image_hover => $engine.load_image('images/buttons/main-menu-settings-hover.png'))		#, :background_image_click => $engine.load_image('images/buttons/main-menu-settings-click.png'))
		@settings_button.on_clicked { @settings_window.switch_state({:closed => :open, :open => :closed}, duration=0.2) }

		self << @quit_button = GuiButton.new.set(:scale_x => 0.05, :scale_y => 0.06, :offset_x => -0.475, :offset_y => -0.47, :background_image => $engine.load_image('images/buttons/main-menu-quit.png'), :background_image_hover => $engine.load_image('images/buttons/main-menu-quit-hover.png'), :background_image_click => $engine.load_image('images/buttons/main-menu-quit-click.png'))
		@quit_button.on_clicked { quit_notify }
	end
end
