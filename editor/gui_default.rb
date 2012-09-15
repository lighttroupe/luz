require 'gui_hover_behavior', 'gui_object', 'gui_button', 'gui_box', 'gui_list', 'gui_grid', 'gui_message_bar', 'gui_beat_monitor'
require 'editor/fonts/bitmap-font'

require 'gui_addons'

class GuiDefault < GuiBox
	pipe :positive_message, :message_bar
	pipe :negative_message, :message_bar

	def initialize
		super
		create_default_gui
	end

	def create_default_gui
		self << (actor_list=GuiList.new($engine.project.actors).set_scale(0.2).set_offset_x(-0.4).set_offset_y(0.4).set_spacing_y(-1.1))
		self << (@curves_list = GuiList.new($engine.project.curves).set(:scale_x => 0.07, :scale_y => 0.04, :offset_x => -0.11, :offset_y => 0.5, :hidden => true, :spacing_y => -1.2))
		self << (@curve_button = GuiButton.new.set(:scale_x => 0.08, :scale_y => 0.08, :offset_x => -0.11, :offset_y => 0.50 - 0.04, :background_image => $engine.load_image('images/buttons/menu.png')))
		self << (@themes_list = GuiList.new($engine.project.themes).set(:scale_x => 0.09, :scale_y => 0.045, :offset_x => 0.06, :offset_y => 0.5, :hidden => true, :spacing_y => -1.2))
		self << (@theme_button = GuiButton.new.set(:scale_x => 0.08, :scale_y => 0.08, :offset_x => 0.06, :offset_y => 0.50 - 0.04, :background_image => $engine.load_image('images/buttons/menu.png')))
		self << (@variables_list = GuiList.new($engine.project.variables).set(:scale_x => 0.12, :scale_y => 0.045, :offset_x => 0.23, :offset_y => 0.5, :hidden => true, :spacing_y => -1.2))
		self << (@variable_button = GuiButton.new.set(:scale_x => 0.08, :scale_y => 0.08, :offset_x => 0.23, :offset_y => 0.50 - 0.04, :background_image => $engine.load_image('images/buttons/menu.png')))
		self << (@events_list = GuiList.new($engine.project.events).set(:scale_x => 0.12, :scale_y => 0.045, :offset_x => 0.40, :offset_y => 0.5, :hidden => true, :spacing_y => -1.2))
		self << (@event_button = GuiButton.new.set(:scale_x => 0.08, :scale_y => 0.08, :offset_x => 0.40, :offset_y => 0.50 - 0.04, :background_image => $engine.load_image('images/buttons/menu.png')))

		self << (@message_bar = GuiMessageBar.new.set(:offset_x => -0.38, :offset_y => 0.5 - 0.03, :scale_x => 0.02, :scale_y => 0.04))
		self << (@beat_monitor = GuiBeatMonitor.new(beats_per_measure=4).set(:offset_x => -0.485, :offset_y => 0.5 - 0.03, :scale_x => 0.02, :scale_y => 0.02, :spacing_x => 1.1, :spacing_y => 0.0))

		@curve_button.on_clicked {
			if @curves_list.hidden?
				@curves_list.set(:hidden => false, :opacity => 0.0).animate({:offset_y => 0.38, :opacity => 1.0}, duration=0.2)
			else
				@curves_list.animate(:offset_y, 0.5, duration=0.25) { @curves_list.set_hidden(true) }.animate(:opacity, 0.0, duration=0.2)
			end
		}

		@theme_button.on_clicked {
			if @themes_list.hidden?
				@themes_list.set(:hidden => false, :opacity => 0.0).animate({:offset_y => 0.38, :opacity => 1.0}, duration=0.2)
			else
				@themes_list.animate(:offset_y, 0.5, duration=0.25) { @themes_list.set_hidden(true) }.animate(:opacity, 0.0, duration=0.2)
			end
		}

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
		pointer = options[:pointer]
		editor = @user_object_editors[user_object]

		if editor
			if editor.hidden?
				bring_to_top(editor)
			else
				# was visible...
				editor.animate({:offset_x => pointer.x, :offset_y => pointer.y, :scale_x => 0.0, :scale_y => 0.0, :opacity => 0.5}, duration=0.2) {
					editor.hidden!
				}
				return
			end
		else
			editor = GuiUserObjectEditor.new(user_object, options)
			self << editor

			@user_object_editors[user_object] = editor
		end

		# Hide everything...
		@user_object_editors.values.each { |e|
			e.set({:opacity => 0.0, :hidden => true})	#, duration=0.4)
		}

		# ...reveal just this one.
		editor.set({:offset_x => pointer.x, :offset_y => pointer.y, :scale_x => 0.0, :scale_y => 0.0, :opacity => 0.0, :hidden => false})
		final_options = {:offset_x => -0.15, :offset_y => 0.0, :scale_x => 0.5, :scale_y => 0.8, :opacity => 1.0}
		editor.animate(final_options, duration=0.2)

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
		# background
		self << (@background=GuiObject.new.set(:color => [0,0,0,0.5]))

		@user_object.gui_build_editor(self)

		# label
		self << (@title_text=BitmapFont.new.set_string(@user_object.title).set(:scale_x => 0.025, :scale_y => 0.05, :offset_x => -0.5 + 0.025, :offset_y => 0.5 - 0.025))		#.set(:background_image => $engine.load_image('images/buttons/menu.png'))

		self << (@close_button=GuiButton.new.set(:scale_x => 0.08, :scale_y => 0.08, :offset_x => 0.5, :offset_y => 0.5, :background_image => $engine.load_image('images/buttons/close.png')))
		@close_button.on_clicked {
			animate({:opacity => 0.0, :offset_y => offset_y - 0.1, :scale_x => scale_x * 1.1}, duration=0.2) { set_hidden(true) }
		}
	end
end
