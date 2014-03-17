class GuiUserObjectEditor < GuiWindow
	attr_accessor :pointer

	BACKGROUND_COLOR = [0,0,0,0.95]

	def initialize(user_object, options)
		@user_object, @options = user_object, options
		super([])
		create!
		set(options)
	end

	def create_something!
		@user_object.create_something!
	end

	def on_key_press(key)
		if key == 'n' && key.control?
			@user_object.open_add_child_window!
		elsif key == 'delete' && key.control?
			@user_object.remove_selected
		elsif key == 'left' && !key.control?
			@user_object.effects_list_grab_focus!
		elsif key == 'right' && !key.control?
			@user_object.settings_list_grab_focus!
		elsif key == 'tab'
			if key.shift?
				@user_object.effects_list_grab_focus!
			else
				@user_object.select_next_setting!
			end
		else
			super
		end
	end

	def hide!
		#switch_state({:open => :closed}, duration=0.1)
		remove_from_parent!
		$gui.default_focus!
	end

	def grab_keyboard_focus!
		@user_object.grab_keyboard_focus!
	end

	def gui_render!
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
				@user_object.gui_fill_settings_list(@user_object)
				@title_text.cancel_keyboard_focus!
			}
		end

		self << (@title_text=GuiString.new(@user_object, :title).set(:offset_x => -0.30 + 0.07, :offset_y => 0.5 - 0.07, :scale_x => 0.35, :scale_y => 0.1))		#.set(:background_image => $engine.load_image('images/buttons/menu.png'))

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
		self << (@close_button=GuiButton.new.set(:scale_x => 0.15, :scale_y => 0.07, :offset_x => 0.0, :offset_y => -0.5 + 0.035, :background_image => $engine.load_image('images/buttons/close.png')))
		@close_button.on_clicked { $gui.clear_editors! }

		#
		# Let object build its own content (eg. lists of effects and settings: gui/addons/user_object.rb)
		#
		self << @user_object.gui_build_editor		# find gui_build_editor implementations in gui/addons
	end

	def close!
		animate({:opacity => 0.0, :offset_y => offset_y - 0.2, :scale_x => scale_x * 1.1}, duration=0.2) { set_hidden(true) }
		$gui.show_reopen_button!
	end
end
