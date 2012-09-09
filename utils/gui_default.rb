require 'gui_hover_behavior', 'gui_object', 'gui_button', 'gui_box', 'gui_list', 'gui_message_bar'
require 'editor/fonts/bitmap-font'

class GuiDefault < GuiBox
	pipe :positive_message, :message_bar

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

		@variable_button.on_clicked {
			if @variables_list.hidden?
				@variables_list.set(:hidden => false, :opacity => 0.0).animate(:offset_y, 0.38, duration=0.2) { positive_message(sprintf("here's your list!")) }.animate(:opacity, 1.0, duration=0.2)
			else
				@variables_list.animate(:offset_y, 0.5, duration=0.25) { @variables_list.set_hidden(true) ; positive_message(sprintf("byebye list!")) }.animate(:opacity, 0.0, duration=0.2)
			end
		}

		@event_button.on_clicked {
			if @events_list.hidden?
				@events_list.set(:hidden => false, :opacity => 0.0).animate(:offset_y, 0.38, duration=0.2) { positive_message(sprintf("there are events!")) }.animate(:opacity, 1.0, duration=0.2)
			else
				@events_list.animate(:offset_y, 0.5, duration=0.25) { @events_list.set_hidden(true) ; positive_message(sprintf("no more events!")) }.animate(:opacity, 0.0, duration=0.2)
			end
		}

		positive_message('Welcome to Luz 2.0')
	end

	def build_editor_for(user_object, options)
		positive_message("Clicked on '#{user_object.title}'")
	end
end
