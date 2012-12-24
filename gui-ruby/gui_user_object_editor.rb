class GuiUserObjectEditor < GuiBox
	easy_accessor :pointer

	def initialize(user_object, options)
		@user_object, @options = user_object, options
		super([])
		create!
		set(options)
	end

	def create!
		# background
		self << (@background=GuiObject.new.set(:color => [0,0,0,0.9]))

		# content
		self << @user_object.gui_build_editor		# find gui_build_editor implementations for everything in gui_addons.rb

		# label
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
	end
end
