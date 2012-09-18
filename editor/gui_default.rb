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
		#self << (@actor_list = GuiList.new($engine.project.actors).set(:scale_x => 0.2, :scale_y => 0.5, :offset_x => -0.4, :offset_y => 0.0, :hidden => false, :spacing_y => -1.0))

		self << (@curves_list = GuiList.new($engine.project.curves).set(:scale_x => 0.08, :scale_y => 0.5, :offset_x => -0.11, :offset_y => 0.5, :item_aspect_ratio => 1.6, :hidden => true, :spacing_y => -1.0))
		self << (@curve_button = GuiButton.new.set(:scale_x => 0.08, :scale_y => 0.08, :offset_x => -0.11, :offset_y => 0.5 - 0.04, :background_image => $engine.load_image('images/buttons/menu.png')))
		@curve_button.on_clicked {
			if @curves_list.hidden?
				@curves_list.set(:hidden => false, :opacity => 0.0).animate({:offset_y => 0.15, :opacity => 1.0}, duration=0.2)
			else
				@curves_list.animate(:offset_y, 0.5, duration=0.25) { @curves_list.set_hidden(true) }.animate(:opacity, 0.0, duration=0.2)
			end
		}

		self << (@themes_list = GuiList.new($engine.project.themes).set(:scale_x => 0.08, :scale_y => 0.5, :offset_x => 0.06, :offset_y => 0.5, :item_aspect_ratio => 1.6, :hidden => true, :spacing_y => -1.0))
		self << (@theme_button = GuiButton.new.set(:scale_x => 0.08, :scale_y => 0.08, :offset_x => 0.06, :offset_y => 0.50 - 0.04, :background_image => $engine.load_image('images/buttons/menu.png')))
		@theme_button.on_clicked {
			if @themes_list.hidden?
				@themes_list.set(:hidden => false, :opacity => 0.0).animate({:offset_y => 0.15, :opacity => 1.0}, duration=0.2)
			else
				@themes_list.animate(:offset_y, 0.5, duration=0.25) { @themes_list.set_hidden(true) }.animate(:opacity, 0.0, duration=0.2)
			end
		}

		self << (@variables_list = GuiList.new($engine.project.variables).set(:scale_x => 0.12, :scale_y => 0.5, :offset_x => 0.23, :offset_y => 0.5, :item_aspect_ratio => 2.5, :hidden => true, :spacing_y => -1.0))
		self << (@variable_button = GuiButton.new.set(:scale_x => 0.08, :scale_y => 0.08, :offset_x => 0.23, :offset_y => 0.50 - 0.04, :background_image => $engine.load_image('images/buttons/menu.png')))
		@variable_button.on_clicked {
			if @variables_list.hidden?
				@variables_list.set(:hidden => false, :opacity => 0.0).animate({:offset_y => 0.15, :opacity => 1.0}, duration=0.2)
			else
				@variables_list.animate(:offset_y, 0.5, duration=0.25) { @variables_list.set_hidden(true) }.animate(:opacity, 0.0, duration=0.2)
			end
		}

		self << (@events_list = GuiList.new($engine.project.events).set(:scale_x => 0.12, :scale_y => 0.5, :offset_x => 0.40, :offset_y => 0.5, :item_aspect_ratio => 2.5, :hidden => true, :spacing_y => -1.0))
		self << (@event_button = GuiButton.new.set(:scale_x => 0.08, :scale_y => 0.08, :offset_x => 0.40, :offset_y => 0.50 - 0.04, :background_image => $engine.load_image('images/buttons/menu.png')))
		@event_button.on_clicked {
			if @events_list.hidden?
				@events_list.set(:hidden => false, :opacity => 0.0).animate({:offset_y => 0.15, :opacity => 1.0}, duration=0.2)
			else
				@events_list.animate({:offset_y => 0.5, :opacity => 0.0}, duration=0.25) { @events_list.set_hidden(true) }
			end
		}

		self << (@message_bar = GuiMessageBar.new.set(:offset_x => -0.33, :offset_y => 0.5 - 0.04, :scale_x => 0.32, :scale_y => 0.05))
		self << (@beat_monitor = GuiBeatMonitor.new(beats_per_measure=4).set(:offset_y => -0.45 - 0.03, :scale_x => 0.08, :scale_y => 0.02, :spacing_x => 1.0))

		positive_message('Welcome to Luz 2.0')

		@user_object_editors = {}
	end

	def build_editor_for(user_object, options)
		pointer = options[:pointer]
		editor = @user_object_editors[user_object]

		if editor
			if editor.hidden?
				bring_to_top(editor)
				editor.not_hidden!
			else
				# was already visible... ...hide self towards click spot
				editor.animate({:offset_x => pointer.x, :offset_y => pointer.y, :opacity => 0.2}, duration=0.2) {
					editor.hidden!
				}
				return
			end
		else
			editor = GuiUserObjectEditor.new(user_object, {:scale_x => 0.2, :scale_y => 0.2}.merge(options))
			self << editor
			@user_object_editors[user_object] = editor
		end

		# Reveal
#		editor.animate({:offset_x => pointer.x + 0.1 + (editor.scale_x / 2.0), :offset_y => pointer.y + 0.1 - (editor.scale_y / 2.0), :opacity => 1.0}, duration=0.2)

		# Hide everything...
		@user_object_editors.values.each { |e|
			e.set({:opacity => 0.0, :hidden => true})	#, duration=0.4)
		}
		editor.set({:offset_x => pointer.x, :offset_y => pointer.y, :opacity => 0.0, :hidden => false})

		# ...reveal just this one.
		final_options = {:offset_x => -0.15, :offset_y => 0.15, :scale_x => 0.2, :scale_y => 0.25, :opacity => 1.0}
		editor.animate(final_options, duration=0.2)

		return editor
	end
end

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
		self << (@background=GuiObject.new.set(:color => [0,0,0,0.5]))

		@user_object.gui_build_editor(self)

		# label
		self << (@title_text=BitmapFont.new.set_string(@user_object.title).set(:scale_x => 0.95, :scale_y => 0.15, :offset_x => 0.0, :offset_y => 0.5))		#.set(:background_image => $engine.load_image('images/buttons/menu.png'))

		self << (@close_button=GuiButton.new.set(:scale_x => 0.15, :scale_y => 0.15, :offset_x => 0.5, :offset_y => 0.5, :background_image => $engine.load_image('images/buttons/close.png')))
		@close_button.on_clicked {
			animate({:opacity => 0.0, :offset_y => offset_y - 0.1, :scale_x => scale_x * 1.1}, duration=0.2) { set_hidden(true) }
		}
	end
end
