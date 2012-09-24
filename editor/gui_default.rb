require 'gui_pointer_behavior', 'gui_object', 'gui_box', 'gui_list', 'gui_grid', 'gui_message_bar', 'gui_beat_monitor', 'gui_button', 'gui_float', 'gui_toggle', 'gui_curve', 'gui_curve_increasing', 'gui_theme', 'gui_integer', 'gui_select', 'gui_actor', 'gui_event', 'gui_variable', 'gui_engine_button', 'gui_engine_slider'
require 'editor/fonts/bitmap-font'
require 'gui_addons'

#load_directory(Dir.pwd + '/editor/widgets/', '**.rb')

class GuiDefault < GuiBox
	pipe :positive_message, :message_bar
	pipe :negative_message, :message_bar

	def initialize
		super
		create_default_gui
	end

	ACTORS_BUTTON    = 'Keyboard / F1'
	THEMES_BUTTON    = 'Keyboard / F5'
	CURVES_BUTTON    = 'Keyboard / F6'
	VARIABLES_BUTTON = 'Keyboard / F7'
	EVENTS_BUTTON    = 'Keyboard / F8'

	def reload_notify
#		clear!
#		create_default_gui
	end

	def gui_tick!
		super
		toggle_actors_list! if $engine.button_pressed_this_frame?(ACTORS_BUTTON)
		toggle_curves_list! if $engine.button_pressed_this_frame?(CURVES_BUTTON)
		toggle_themes_list! if $engine.button_pressed_this_frame?(THEMES_BUTTON)
		toggle_variables_list! if $engine.button_pressed_this_frame?(VARIABLES_BUTTON)
		toggle_events_list! if $engine.button_pressed_this_frame?(EVENTS_BUTTON)
	end

	def create_default_gui
		self << (@actors_list = GuiList.new($engine.project.actors).set(:scroll_wrap => true, :scale_x => 0.2, :scale_y => 0.5, :offset_x => -0.4, :offset_y => 0.0, :hidden => true, :spacing_y => -1.0))
		self << (@actors_button = GuiButton.new.set(:scale_x => 0.08, :scale_y => 0.08, :offset_x => -0.46, :offset_y => 0.5 - 0.14, :background_image => $engine.load_image('images/buttons/menu.png')))
		@actors_button.on_clicked { toggle_actors_list! }

		self << (@themes_list = GuiList.new($engine.project.themes).set(:scale_x => 0.08, :scale_y => 0.5, :offset_x => -0.11, :offset_y => 0.5, :item_aspect_ratio => 1.6, :hidden => true, :spacing_y => -1.0))
		self << (@theme_button = GuiButton.new.set(:scale_x => 0.08, :scale_y => 0.08, :offset_x => -0.11, :offset_y => 0.5 - 0.04, :background_image => $engine.load_image('images/buttons/menu.png')))
		@theme_button.on_clicked { toggle_themes_list! }

		self << (@curves_list = GuiList.new($engine.project.curves).set(:scale_x => 0.08, :scale_y => 0.5, :offset_x => 0.06, :offset_y => 0.5, :item_aspect_ratio => 1.6, :hidden => true, :spacing_y => -1.0))
		self << (@curve_button = GuiButton.new.set(:scale_x => 0.08, :scale_y => 0.08, :offset_x => 0.06, :offset_y => 0.50 - 0.04, :background_image => $engine.load_image('images/buttons/menu.png')))
		@curve_button.on_clicked { toggle_curves_list! }

		self << (@variables_list = GuiList.new($engine.project.variables).set(:scale_x => 0.12, :scale_y => 0.5, :offset_x => 0.23, :offset_y => 0.5, :item_aspect_ratio => 2.5, :hidden => true, :spacing_y => -1.0))
		self << (@variable_button = GuiButton.new.set(:scale_x => 0.08, :scale_y => 0.08, :offset_x => 0.23, :offset_y => 0.50 - 0.04, :background_image => $engine.load_image('images/buttons/menu.png')))
		@variable_button.on_clicked { toggle_variables_list! }

		self << (@events_list = GuiList.new($engine.project.events).set(:scale_x => 0.12, :scale_y => 0.5, :offset_x => 0.40, :offset_y => 0.5, :item_aspect_ratio => 2.5, :hidden => true, :spacing_y => -1.0))
		self << (@event_button = GuiButton.new.set(:scale_x => 0.08, :scale_y => 0.08, :offset_x => 0.40, :offset_y => 0.50 - 0.04, :background_image => $engine.load_image('images/buttons/menu.png')))
		@event_button.on_clicked { toggle_events_list! }

		self << (@message_bar = GuiMessageBar.new.set(:offset_x => -0.33, :offset_y => 0.5 - 0.04, :scale_x => 0.32, :scale_y => 0.05))
		self << (@beat_monitor = GuiBeatMonitor.new(beats_per_measure=4).set(:offset_y => -0.45 - 0.03, :scale_x => 0.08, :scale_y => 0.02, :spacing_x => 1.0))

		positive_message('Welcome to Luz 2.0')

		@user_object_editors = {}
	end

	def toggle_actors_list!
		if @actors_list.hidden?
			@actors_list.set(:hidden => false, :opacity => 0.0).animate({:opacity => 1.0}, duration=0.2)
		else
			@actors_list.animate(:opacity, 0.0, duration=0.25) { @actors_list.set_hidden(true) }
		end
	end

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
				clear_editors!		# only support one for now

				editor = GuiUserObjectEditor.new(user_object, {:scale_x => 0.3, :scale_y => 0.05}.merge(options))
				self << editor
				@user_object_editors[user_object] = editor

				editor.set({:offset_x => pointer.x, :offset_y => pointer.y, :opacity => 0.0, :scale_x => 0.0, :scale_y => 0.0, :hidden => false})
				final_options = {:offset_x => 0.0, :offset_y => -0.15, :scale_x => 0.3, :scale_y => 0.375, :opacity => 1.0}
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

		# content
		self << @user_object.gui_build_editor

		# label
		self << (@title_text=BitmapFont.new.set_string(@user_object.title).set(:scale_x => 1.0, :scale_y => 0.08, :offset_x => 0.0, :offset_y => 0.5 - 0.04))		#.set(:background_image => $engine.load_image('images/buttons/menu.png'))

		self << (@close_button=GuiButton.new.set(:scale_x => 0.12, :scale_y => 0.15, :offset_x => 0.5, :offset_y => 0.5, :background_image => $engine.load_image('images/buttons/close.png')))
		@close_button.on_clicked {
			animate({:opacity => 0.0, :offset_y => offset_y - 0.1, :scale_x => scale_x * 1.1}, duration=0.2) { set_hidden(true) }
		}
	end
end
