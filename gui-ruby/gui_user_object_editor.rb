class GuiUserObjectEditor < GuiBox
	attr_accessor :pointer

	def initialize(user_object, options)
		@user_object, @options = user_object, options
		super([])
		create!
		set(options)
	end

	def create!
		#
		# Background
		#
		self << (@background=GuiObject.new.set(:color => [0,0,0,1.0]))

		#
		# Let object build its own content (eg. lists)
		#
		self << @user_object.gui_build_editor		# find gui_build_editor implementations in gui-ruby/addons

		#
		# Title
		#
		if @user_object.has_settings_list?
			self << (@title_button=GuiButton.new.set(:scale_x => 0.5, :offset_x => -0.25, :scale_y => 0.10, :offset_y => 0.5 - 0.06, :color => [0,0,0,1]))		#.set(:background_image => $engine.load_image('images/buttons/menu.png'))

			@title_button.on_clicked {
				@user_object.gui_fill_settings_list(@user_object)
			}
		end
		self << (@title_text=BitmapFont.new.set_string(@user_object.title).set(:scale_x => 0.5, :float => :left, :scale_y => 0.10, :offset_x => 0.0, :offset_y => 0.5 - 0.06))		#.set(:background_image => $engine.load_image('images/buttons/menu.png'))

		self << (@close_button=GuiButton.new.set(:scale_x => 0.08, :scale_y => 0.15, :offset_x => 0.5, :offset_y => 0.5, :background_image => $engine.load_image('images/buttons/close.png')))
		@close_button.on_clicked {
			animate({:opacity => 0.0, :offset_y => offset_y - 0.1, :scale_x => scale_x * 1.1}, duration=0.2) { set_hidden(true) }
		}

		#
		# Add button
		#
		self << (@add_child_button=GuiButton.new.set(:scale_x => 0.08, :scale_y => 0.15, :offset_x => -0.54, :offset_y => -0.5 + 0.15 + 0.18, :background_image => $engine.load_image('images/buttons/add.png')))
		@add_child_button.on_clicked { |pointer|
			window = build_add_child_window_for(@user_object, pointer)
			window.on_add { |new_object|
				@user_object.gui_effects_list.add_after_selection(new_object)
				@user_object.gui_effects_list.set_selection(new_object)
				@user_object.gui_effects_list.scroll_to_selection!

				@user_object.gui_fill_settings_list(new_object)
			}
			self << window
		}

		#
		# Remove button
		#
		self << (@remove_child_button=GuiButton.new.set(:scale_x => 0.08, :scale_y => 0.15, :offset_x => -0.54, :offset_y => -0.5 + 0.15, :background_image => $engine.load_image('images/buttons/remove.png')))
		@remove_child_button.on_clicked { |pointer|
			remove_selected
		}
	end

	def build_add_child_window_for(user_object, pointer)
		window = GuiAddWindow.new(user_object)
		window.set({:offset_x => 0.0, :offset_y => 0.5, :opacity => 0.0, :scale_x => 0.8, :scale_y => 0.0, :hidden => false})
		window.animate({:offset_x => 0.0, :offset_y => 0.2, :scale_x => 0.8, :scale_y => 1.0, :opacity => 1.0}, duration=0.2)
		window
	end

	def remove_selected
		# TODO ugly implementation reaching into user_object :(
		@user_object.gui_effects_list.selection.each { |object|
			@user_object.effects.delete(object)
		}
	end
end
