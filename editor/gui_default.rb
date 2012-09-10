require 'gui_hover_behavior', 'gui_object', 'gui_button', 'gui_box', 'gui_list', 'gui_message_bar', 'gui_beat_monitor'
require 'editor/fonts/bitmap-font'

class GuiDefault < GuiBox
	pipe :positive_message, :message_bar
	pipe :negative_message, :message_bar

	def initialize
		super
		create_default_gui
	end

	def create_default_gui
		#self << (actor_list=GuiList.new($engine.project.actors).set_scale(0.2).set_offset_x(-0.4).set_offset_y(0.4))
		self << (@variables_list=GuiList.new($engine.project.variables).set(:hidden => true, :scale_x => 0.12, :scale_y => 0.03, :offset_x => 0.23, :offset_y => 0.5, :spacing => 0.4))
		self << (@variable_button = GuiButton.new.set(:scale_x => 0.08, :scale_y => 0.08, :offset_x => 0.23, :offset_y => 0.50 - 0.04, :background_image => $engine.load_image('images/buttons/menu.png')))
		self << (@events_list=GuiList.new($engine.project.events).set(:hidden => true, :scale_x => 0.12, :scale_y => 0.03, :offset_x => 0.4, :offset_y => 0.5, :spacing => 0.4))
		self << (@event_button = GuiButton.new.set(:scale_x => 0.08, :scale_y => 0.08, :offset_x => 0.40, :offset_y => 0.50 - 0.04, :background_image => $engine.load_image('images/buttons/menu.png')))
		self << (@message_bar = GuiMessageBar.new.set(:offset_x => -0.3, :offset_y => 0.5 - 0.03, :scale_x => 0.02, :scale_y => 0.04))
		self << (@beat_monitor = GuiBeatMonitor.new.set(:offset_x => -0.45, :offset_y => 0.5 - 0.03, :scale_x => 0.02, :scale_y => 0.04))

		@variable_button.on_clicked {
			if @variables_list.hidden?
				@variables_list.set(:hidden => false, :opacity => 0.0).animate({:offset_y => 0.38, :opacity => 1.0}, duration=0.2)
			else
				@variables_list.animate(:offset_y, 0.5, duration=0.25) { @variables_list.set_hidden(true) }.animate(:opacity, 0.0, duration=0.2)
			end
		}

		@event_button.on_clicked {
			if @events_list.hidden?
				@events_list.set(:hidden => false, :opacity => 0.0).animate({:offset_y => 0.38, :opacity => 1.0}, duration=0.2)
			else
				@events_list.animate({:offset_y => 0.5, :opacity => 0.0}, duration=0.25) { @events_list.set_hidden(true) }
			end
		}

		positive_message('Welcome to Luz 2.0')

		@user_object_editors = {}
	end

	def build_editor_for(user_object, options)
		positive_message("Clicked on '#{user_object.title}'")
		pointer = options[:pointer]
		editor = @user_object_editors[user_object]

		if editor
			bring_to_top(editor)
		else
			editor = GuiUserObjectEditor.new(user_object, options)
			self << editor
			@user_object_editors[user_object] = editor
		end

		editor.set({:offset_x => pointer.x, :offset_y => pointer.y, :scale_x => 0.0, :scale_y => 0.0})
		editor.animate({:offset_x => 0.0, :offset_y => 0.0, :scale_x => 0.2, :scale_y => 0.2}, duration=0.2)

		return editor if editor
	end
end

class GuiUserObjectEditor < GuiBox
	def initialize(user_object, options)
		@user_object, @options = user_object, options
		super([])
		create!
	end

	def create!
		self << GuiObject.new		#.set(:background_image => $engine.load_image('images/buttons/menu.png'))
		self << BitmapFont.new.set_string(@user_object.title).set(:scale_x => 0.05, :scale_y => 0.1, :offset_x => -0.5 + 0.05, :offset_y => 0.5 - 0.05)		#.set(:background_image => $engine.load_image('images/buttons/menu.png'))
	end
end
