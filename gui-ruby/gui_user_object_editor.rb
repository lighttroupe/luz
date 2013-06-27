class GuiUserObjectEditor < GuiBox
	attr_accessor :pointer

	BACKGROUND_COLOR = [0,0,0,0.95]

	def initialize(user_object, options)
		@user_object, @options = user_object, options
		super([])
		create!
		set(options)
	end

	def create!
		# Background
		self << (@background=GuiObject.new.set(:background_image => $engine.load_image('images/user-object-editor-background.png')))

		#
		# Let object build its own content (eg. lists of effects and settings: gui-ruby/addons/user_object.rb)
		#
		self << @user_object.gui_build_editor		# find gui_build_editor implementations in gui-ruby/addons

		#
		# Title
		#
		if @user_object.has_settings_list?
			self << (@title_button=GuiButton.new.set(:scale_x => 0.5, :offset_x => -0.25, :scale_y => 0.10, :offset_y => 0.5 - 0.06, :color => [0,0,0,0.1]))		#.set(:background_image => $engine.load_image('images/buttons/menu.png'))

			@title_button.on_clicked {
				@user_object.gui_fill_settings_list(@user_object)
			}
		end
		self << (@title_text=BitmapFont.new.set_string(@user_object.title).set(:offset_x => -0.18, :offset_y => 0.5 - 0.06, :scale_x => 0.5, :scale_y => 0.10))		#.set(:background_image => $engine.load_image('images/buttons/menu.png'))

		self << (@delete_button = GuiButton.new.set(:scale_x => 0.05, :scale_y => 0.05, :offset_x => 0.475, :offset_y => -0.475, :background_image => $engine.load_image('images/buttons/menu.png')))
		@delete_button.on_clicked { |pointer|
			$gui.trash!(@user_object)
		}

		self << (@close_button=GuiButton.new.set(:scale_x => 0.04, :scale_y => 0.08, :offset_x => 0.46, :offset_y => 0.43, :background_image => $engine.load_image('images/buttons/close.png')))
		@close_button.on_clicked { $gui.clear_editors! }
	end

	def close!
		animate({:opacity => 0.0, :offset_y => offset_y - 0.2, :scale_x => scale_x * 1.1}, duration=0.2) { set_hidden(true) }
	end
end
