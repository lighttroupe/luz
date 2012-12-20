require 'gui_pointer_behavior', 'gui_object', 'gui_box', 'gui_list', 'gui_list_with_controls', 'gui_grid', 'gui_message_bar', 'gui_beat_monitor', 'gui_button', 'gui_float', 'gui_toggle', 'gui_curve', 'gui_curve_increasing', 'gui_theme', 'gui_integer', 'gui_select', 'gui_actor', 'gui_event', 'gui_variable', 'gui_engine_button', 'gui_engine_slider', 'gui_radio_buttons', 'gui_object_renderer'
require 'editor/fonts/bitmap-font'

# Addons to existing objects
load_directory(Dir.pwd + '/editor/addons/', '**.rb')

require 'gui_preferences_box'
require 'gui_user_object_editor'

class GuiDefault < GuiBox
	pipe [:positive_message, :negative_message], :message_bar

	ACTOR_MODE, DIRECTOR_MODE, OUTPUT_MODE = 1, 2, 3

	def initialize
		super
		create!
	end

	ACTORS_BUTTON    = 'Keyboard / F1'
	THEMES_BUTTON    = 'Keyboard / F5'
	CURVES_BUTTON    = 'Keyboard / F6'
	VARIABLES_BUTTON = 'Keyboard / F7'
	EVENTS_BUTTON    = 'Keyboard / F8'
	PREFERENCES_BUTTON    = 'Keyboard / F12'

	def reload_notify
		clear!
		create!
	end

	def create!
		self << (@actors_list = GuiListWithControls.new($engine.project.actors).set(:scroll_wrap => true, :scale_x => 0.2, :scale_y => 0.75, :offset_x => -0.395, :offset_y => -0.08, :hidden => true, :spacing_y => -1.0))
		self << (@actors_button = GuiButton.new.set(:hotkey => ACTORS_BUTTON, :scale_x => 0.08, :scale_y => 0.08, :offset_x => -0.46, :offset_y => 0.5 - 0.14, :background_image => $engine.load_image('images/buttons/menu.png')))
		@actors_button.on_clicked { toggle_actors_list! }

		self << (@themes_list = GuiListWithControls.new($engine.project.themes).set(:scale_x => 0.08, :scale_y => 0.5, :offset_x => -0.11, :offset_y => 0.5, :item_aspect_ratio => 1.6, :hidden => true, :spacing_y => -1.0))
		self << (@theme_button = GuiButton.new.set(:hotkey => THEMES_BUTTON, :scale_x => 0.08, :scale_y => 0.08, :offset_x => -0.11, :offset_y => 0.5 - 0.04, :background_image => $engine.load_image('images/buttons/menu.png')))
		@theme_button.on_clicked { toggle_themes_list! }

		self << (@curves_list = GuiListWithControls.new($engine.project.curves).set(:scale_x => 0.08, :scale_y => 0.5, :offset_x => 0.06, :offset_y => 0.5, :item_aspect_ratio => 1.6, :hidden => true, :spacing_y => -1.0))
		self << (@curve_button = GuiButton.new.set(:hotkey => CURVES_BUTTON, :scale_x => 0.08, :scale_y => 0.08, :offset_x => 0.06, :offset_y => 0.50 - 0.04, :background_image => $engine.load_image('images/buttons/menu.png')))
		@curve_button.on_clicked { toggle_curves_list! }

		self << (@variables_list = GuiListWithControls.new($engine.project.variables).set(:scale_x => 0.12, :scale_y => 0.5, :offset_x => 0.23, :offset_y => 0.5, :item_aspect_ratio => 2.5, :hidden => true, :spacing_y => -1.0))
		self << (@variable_button = GuiButton.new.set(:hotkey => VARIABLES_BUTTON, :scale_x => 0.08, :scale_y => 0.08, :offset_x => 0.23, :offset_y => 0.50 - 0.04, :background_image => $engine.load_image('images/buttons/menu.png')))
		@variable_button.on_clicked { toggle_variables_list! }

		self << (@events_list = GuiListWithControls.new($engine.project.events).set(:scale_x => 0.12, :scale_y => 0.5, :offset_x => 0.40, :offset_y => 0.5, :item_aspect_ratio => 2.5, :hidden => true, :spacing_y => -1.0))
		self << (@event_button = GuiButton.new.set(:hotkey => EVENTS_BUTTON, :scale_x => 0.08, :scale_y => 0.08, :offset_x => 0.40, :offset_y => 0.50 - 0.04, :background_image => $engine.load_image('images/buttons/menu.png')))
		@event_button.on_clicked { toggle_events_list! }

		self << (@message_bar = GuiMessageBar.new.set(:offset_x => -0.33, :offset_y => 0.5 - 0.04, :scale_x => 0.32, :scale_y => 0.05))
		self << (@beat_monitor = GuiBeatMonitor.new(beats_per_measure=4).set(:offset_y => -0.45 - 0.03, :scale_x => 0.12, :scale_y => 0.02, :spacing_x => 1.0))

		self << (@preferences_box = GuiPreferencesBox.new.build.set(:scale_x => 0.22, :scale_y => 0.4, :offset_x => 0.4, :offset_y => -0.3, :opacity => 0.0, :hidden => true))
		self << (@preferences_button = GuiButton.new.set(:hotkey => PREFERENCES_BUTTON, :scale_x => 0.08, :scale_y => 0.08, :offset_x => 0.50, :offset_y => -0.50, :color => [0.5,1.0,0.5,1.0], :background_image => $engine.load_image('images/buttons/menu.png')))
		@preferences_button.on_clicked { toggle_preferences_box! }

		self << GuiRadioButtons.new(self, :mode, [ACTOR_MODE, OUTPUT_MODE]).set(:offset_x => -0.35, :offset_y => -0.45 - 0.03, :scale_x => 0.12, :scale_y => 0.02, :spacing_x => 1.0)

		@user_object_editors = {}
		@chosen_actor = nil

		self.mode = OUTPUT_MODE
	end

	def mode=(mode)
		return if mode == @mode
		@mode = mode

		case mode
		when ACTOR_MODE
			
		when DIRECTOR_MODE
			
		when OUTPUT_MODE
			
		end
	end

	def render
		case @mode
		when ACTOR_MODE
			@chosen_actor.render! if @chosen_actor
		when DIRECTOR_MODE
			# none yet ...
		when OUTPUT_MODE
			yield
		end
	end

	def toggle_preferences_box!
		if @preferences_box.hidden?		# TODO: this is not a good way to toggle
			@preferences_box.set(:hidden => false, :opacity => 0.0).animate({:opacity => 1.0, :offset_x => 0.38, :offset_y => -0.3}, duration=0.2)
		else
			@preferences_box.animate({:opacity => 0.0, :offset_x => 0.6, :offset_y => -0.6}, duration=0.25) { @preferences_box.set_hidden(true) }
		end
	end

	def toggle_actors_list!
		if @actors_list.hidden?
			show_actors_list!
		else
			close_actors_list!
		end
	end
	def show_actors_list! ; @actors_list.set(:hidden => false, :opacity => 0.0).animate({:opacity => 1.0}, duration=0.2) ; end
	def close_actors_list! ; @actors_list.animate(:opacity, 0.0, duration=0.25) { @actors_list.set_hidden(true) } ; end

	def toggle_curves_list!
		if @curves_list.hidden?
			@curves_list.set(:hidden => false, :opacity => 0.0).animate({:offset_y => 0.15, :opacity => 1.0}, duration=0.2)
		else
			@curves_list.animate(:offset_y, 0.5, duration=0.25) { @curves_list.set_hidden(true) }.animate(:opacity, 0.0, duration=0.2)
		end
	end

	def toggle_themes_list!
		if @themes_list.hidden?
			@themes_list.set(:hidden => false, :opacity => 0.0).animate({:offset_y => 0.15, :opacity => 1.0}, duration=0.2)
		else
			@themes_list.animate(:offset_y, 0.5, duration=0.25) { @themes_list.set_hidden(true) }.animate(:opacity, 0.0, duration=0.2)
		end
	end

	def toggle_variables_list!
		if @variables_list.hidden?
			@variables_list.set(:hidden => false, :opacity => 0.0).animate({:offset_y => 0.15, :opacity => 1.0}, duration=0.2)
		else
			@variables_list.animate(:offset_y, 0.5, duration=0.25) { @variables_list.set_hidden(true) }.animate(:opacity, 0.0, duration=0.2)
		end
	end

	def toggle_events_list!
		if @events_list.hidden?
			@events_list.set(:hidden => false, :opacity => 0.0).animate({:offset_y => 0.15, :opacity => 1.0}, duration=0.2)
		else
			@events_list.animate({:offset_y => 0.5, :opacity => 0.0}, duration=0.25) { @events_list.set_hidden(true) }
		end
	end

	def build_editor_for(user_object, options)
		pointer = options[:pointer]
		editor = @user_object_editors[user_object]

		if editor && !editor.hidden?
			# was already visible... ...hide self towards click spot
			bring_to_top(editor)
			editor.animate({:offset_x => pointer.x, :offset_y => pointer.y, :scale_x => 0.0, :scale_y => 0.0, :opacity => 0.2}, duration=0.2) {
				editor.remove_from_parent!		# trashed forever! (no cache)
				@user_object_editors.delete(user_object)
			}
			return
		else
			if user_object.is_a? ParentUserObject
				if user_object.is_a? Actor
					# @mode = ACTOR_MODE   TODO: perhaps some way to auto-switch to user view when selecting
					@chosen_actor = user_object		# this way, if user then switches to the actor list, this actor will be showing
					close_actors_list!
				end

				clear_editors!		# only support one for now

				editor = GuiUserObjectEditor.new(user_object, {:scale_x => 0.3, :scale_y => 0.05}.merge(options))
				self << editor
				@user_object_editors[user_object] = editor

				editor.set({:offset_x => pointer.x, :offset_y => pointer.y, :opacity => 0.0, :scale_x => 0.0, :scale_y => 0.0, :hidden => false})
				final_options = {:offset_x => 0.0, :offset_y => -0.30, :scale_x => 0.5, :scale_y => 0.325, :opacity => 1.0}
				editor.animate(final_options, duration=0.2)
				return editor
			else
				# tell editor its child was clicked (this is needed due to non-propagation of click messages: the user object gets notified, it tells us)
				parent = @user_object_editors.keys.find { |uo| uo.effects.include? user_object }		# TODO: hacking around children not knowing their parents for easier puppetry
				parent.on_child_user_object_selected(user_object) if parent		# NOTE: can't click a child if parent is not visible, but the 'if' doesn't hurt
				return
			end
		end
	end

	def clear_editors!
		@user_object_editors.each { |user_object, editor|
			editor.animate({:offset_y => editor.offset_y - 0.25, :scale_x => 0.4, :scale_y => 0.1, :opacity => 0.2}, duration=0.3) {
				editor.remove_from_parent!		# trashed forever! (no cache)
			}
		}
		@user_object_editors.clear
	end

	def pointer_click_on_nothing(pointer)
		if !@preferences_box.hidden?
			toggle_preferences_box!

		#elsif !@user_object_editors.empty?
		#	clear_editors!

		elsif !@actors_list.hidden?
			toggle_actors_list!

		elsif !@themes_list.hidden?
			toggle_themes_list!

		elsif !@curves_list.hidden?
			toggle_curves_list!

		elsif !@variables_list.hidden?
			toggle_variables_list!

		elsif !@events_list.hidden?
			toggle_events_list!

		else
			# TODO: close editor interface?
		end
	end
end
