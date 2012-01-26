 ###############################################################################
 #  Copyright 2006 Ian McIntosh <ian@openanswers.org>
 #
 #  This program is free software; you can redistribute it and/or modify
 #  it under the terms of the GNU General Public License as published by
 #  the Free Software Foundation; either version 2 of the License, or
 #  (at your option) any later version.
 #
 #  This program is distributed in the hope that it will be useful,
 #  but WITHOUT ANY WARRANTY; without even the implied warranty of
 #  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 #  GNU Library General Public License for more details.
 #
 #  You should have received a copy of the GNU General Public License
 #  along with this program; if not, write to the Free Software
 #  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 ###############################################################################

require 'glade_window', 'actor_editor_window', 'director_editor_window', 'project_effect_editor_window', 'theme_editor_window', 'curve_editor_window', 'variable_editor_window', 'event_editor_window', 'beat_monitor', 'gtk_gl_drawing_area', 'stage_2d', 'stage_3d', 'easy_dialog', 'tempfile', 'unique_timeout_callback', 'output_window'
require 'preferences_window', 'about_window'

class EditorWindow < GladeWindow
	PREVIEW_PERSPECTIVE = [-0.5, 0.5, -0.5, 0.5]

	EDITOR_PAGE, PAUSE_PAGE = 0, 1

	ACTOR_EDITOR_PAGE, DIRECTOR_EDITOR_PAGE, PROJECT_EFFECT_EDITOR_PAGE, THEME_EDITOR_PAGE, CURVE_EDITOR_PAGE, VARIABLE_EDITOR_PAGE, EVENT_EDITOR_PAGE = (0..6).to_a
	PARENT_USER_OBJECT_TYPES_TO_PAGES_HASH = {:actor => ACTOR_EDITOR_PAGE, :director => DIRECTOR_EDITOR_PAGE, :theme => THEME_EDITOR_PAGE, :curve => CURVE_EDITOR_PAGE, :variable => VARIABLE_EDITOR_PAGE, :event => EVENT_EDITOR_PAGE}

	MAX_SIMULATION_SPEED_MULTIPLIER = 10.0		# TODO: move to engine

	PERFORMER_TEMPFILE_PREFIX = 'luz-performer'
	PERFORMER_EXECUTABLE_NAME = 'luz_performer.rb'
	RECORDER_EXECUTABLE_NAME  = 'luz_video_renderer.rb'
	INPUT_MANAGER_EXECUTABLE_NAME  = 'input-manager/input-manager'
	SPECTRUM_ANALYZER_EXECUTABLE_NAME  = 'spectrum-analyzer/spectrum-analyzer'
	SOURCE_EDITOR_EXECUTABLE_NAME  = 'gnome-open'

	GREEN_HEX = '#7ADF17'
	RED_HEX = '#E92A09'

	def initialize
		super

		@message_clear_timeout = UniqueTimeoutCallback.new(2000) { retire_message }

		###################################################################
		# Actor Stage
		###################################################################
		@actor_stage = Stage2D.new.show
		@actor_stage_container.add(@actor_stage)
		@actor_stage.realize	# must 'realize' before next GLDrawingArea is made so they can share GL contexts
		@actor_stage.perspective = PREVIEW_PERSPECTIVE
		@actor_stage_visible = true
		@actor_stage.on_scroll_wheel_up { on_zoom_in_activate }
		@actor_stage.on_scroll_wheel_down { on_zoom_out_activate }

		###################################################################
		# Director Stage
		###################################################################
		@director_stage = Stage3D.new.show
		@director_stage_container.add(@director_stage)
		@director_stage.perspective = PREVIEW_PERSPECTIVE
		@director_stage_visible = true

		###################################################################
		# Output Preview
		###################################################################
		@output_preview = GtkGLDrawingArea.new.show
		@output_preview_container.add(@output_preview)
		@output_preview_visible = true

		###################################################################
		# Beat Monitor
		###################################################################
		@beat_monitor = BeatMonitor.new.show
		@beat_monitor_container.add(@beat_monitor)
		@beat_monitor.on_click { $engine.beat! }

		###################################################################
		# Bottom Notebook
		###################################################################
		@bottom_notebook_windows = {}

		section('Creating Actor Editor Window') {
			@actor_editor_window = ActorEditorWindow.new
			@actor_editor_window.window_contents.reparent(@actor_editor_container)
			@bottom_notebook_windows[ACTOR_EDITOR_PAGE] = @actor_editor_window
			@actor_tab_image.grab_focus		# silences Gtk console spam on keypress: Gtk-CRITICAL **:gtk_widget_event: assertion `WIDGET_REALIZED_FOR_EVENT (widget, event)' failed
		}
		section('Creating Director Editor Window') {
			@director_editor_window = DirectorEditorWindow.new
			@director_editor_window.window_contents.reparent(@director_editor_container)
			@bottom_notebook_windows[DIRECTOR_EDITOR_PAGE] = @director_editor_window
			@director_editor_window.on_parent_selected { |director| $engine.director = director }
		}
		section('Creating Project Effect Editor Window') {
			@project_effect_editor_window = ProjectEffectEditorWindow.new
			@project_effect_editor_window.window_contents.reparent(@project_effect_editor_container)
			@bottom_notebook_windows[PROJECT_EFFECT_EDITOR_PAGE] = @project_effect_editor_window
		}
		section('Creating Theme Editor Window') {
			@theme_editor_window = ThemeEditorWindow.new
			@theme_editor_window.window_contents.reparent(@theme_editor_container)
			@bottom_notebook_windows[THEME_EDITOR_PAGE] = @theme_editor_window
			@theme_editor_window.on_parent_selected { |theme| $engine.theme = theme }
		}
		section('Creating Curve Editor Window') {
			@curve_editor_window = CurveEditorWindow.new
			@curve_editor_window.window_contents.reparent(@curve_editor_container)
			@bottom_notebook_windows[CURVE_EDITOR_PAGE] = @curve_editor_window
		}
		section('Creating Variable Editor Window') {
			@variable_editor_window = VariableEditorWindow.new
			@variable_editor_window.window_contents.reparent(@variable_editor_container)
			@bottom_notebook_windows[VARIABLE_EDITOR_PAGE] = @variable_editor_window
		}
		section('Creating Event Editor Window') {
			@event_editor_window = EventEditorWindow.new
			@event_editor_window.window_contents.reparent(@event_editor_container)
			@bottom_notebook_windows[EVENT_EDITOR_PAGE] = @event_editor_window
		}
		@editor_windows = [@actor_editor_window, @director_editor_window, @curve_editor_window, @variable_editor_window, @event_editor_window]

		section('Creating Preferences Window') {
			@preferences_window = PreferencesWindow.new
		}
		section('Creating About Window') {
			@about_window = AboutWindow.new
		}

		@widgets_to_hide_on_crash = [@drawing_area_container, @beat_monitor_container]
		@widgets_to_hide_on_crash.each { |w| throw "unable to find a control :/" if w.nil? }

		# Track active notebook page
		@bottom_notebook.on_change_with_init { |index| @active_editor_window = @bottom_notebook_windows[index] }

		@window_vpaned_preferred_positions_for_view_counts = [nil, nil, nil]

		update_window_title
		init_callbacks

		# Pipe mouse input to engine
		signal_connect('motion-notify-event') { |widget, event|
			$engine.on_slider_change(sprintf("Mouse %02d / X", 1), (event.x_root / (@window.screen.width - 1).to_f))
			$engine.on_slider_change(sprintf("Mouse %02d / Y", 1), (1.0 - (event.y_root / (@window.screen.height - 1).to_f)))
			false
		}
		signal_connect('button-press-event') { |widget, event|
			# NOTE: right now we just hardcode it for 1 mouse... some day maybe we'll support multiple ?
			$engine.on_button_down(sprintf("Mouse %02d / Button %02d", 1, event.button), frame_offset=1)

			# NOTE: Grabbing the pointer ensures that we'll see the button-release event
			#Gdk.pointer_grab(self.window, true, Gdk::Event::POINTER_MOTION_MASK | Gdk::Event::BUTTON_RELEASE_MASK, nil, nil, Gdk::Event::CURRENT_TIME)
		}
		signal_connect('button-release-event') { |widget, event|
			# NOTE: right now we just hardcode it for 1 mouse... some day maybe we'll support multiple ?
			$engine.on_button_up(sprintf("Mouse %02d / Button %02d", 1, event.button), frame_offset=1)
			#Gdk.pointer_ungrab(Gdk::Event::CURRENT_TIME)
		}
		@window_vpaned.signal_connect('notify') { on_window_vpaned_position_changed }

		toggle_fullscreen

		#
		# Recent Project feature
		#
		@recent_manager = Gtk::RecentManager.new
		@recent_manager.limit = 30
		@recent_menu = Gtk::RecentChooserMenu.new(@recent_manager)
		@recent_menu.sort_type = Gtk::RecentChooser::SORT_MRU
		# this is known to cause a segfault when using keyboard to select most-recent project eg. Menu/File/Recent/0
		#@recent_menu.show_numbers = true if @recent_menu.respond_to? :show_numbers=
		@recent_menu.add_filter(Gtk::RecentFilter.new.add_pattern('*.luz'))
		@open_recent_menu_item.set_submenu(@recent_menu)
		@recent_menu.signal_connect('item-activated') { save_changes_before { load_from_path(@recent_menu.current_uri.without_prefix('file://').gsub('%20',' ')) } }

		# save button goes insensitive when there's nothing to save
		$engine.project.on_changed { |count| @save_button.sensitive = (count > 0) }

		@output_window = OutputWindow.new
	end

	def init_callbacks
		$engine.on_new_project { load_from_project($engine.project) }
		$engine.on_update_user_objects { update_all_user_objects }
		$engine.on_user_object_changed { |user_object| update_object(user_object) }
		$engine.on_render_settings_changed {
			@actor_stage.using_context { $engine.render_settings }
			@director_stage.using_context { $engine.render_settings }
		}
		$engine.on_render {
			@actor_stage.render(@actor_editor_window.selected_actors) if @actor_stage_visible
			@director_stage.render(@director_editor_window.selected_directors) if @director_stage_visible

			if @output_window.visible?
				@output_window.using_context { $engine.render(enable_frame_saving=true) }
				@output_preview.using_context { $engine.render(enable_frame_saving=false) } if @output_preview_visible
			else
				@output_preview.using_context { $engine.render(enable_frame_saving=true) } if @output_preview_visible
			end
		}
		$engine.on_frame_end { update }
		$engine.on_new_user_object_class { |klass| add_user_object_class(klass) }
		$engine.on_crash { on_crash }
	end

	# Used after loading projects, etc.
	pipe :set_director, :director_editor_window, :method => :select_parent
	pipe :set_theme, :theme_editor_window, :method => :select_parent

	def add_user_object_class(klass)
		# When new classes are discovered, send them off to be added to the proper lists.
		# TODO: let editors listen to engine directly
		@actor_editor_window.add_actor_class(klass) if klass.inherited_from? Actor
		@actor_editor_window.add_actor_effect_class(klass) if klass.inherited_from? ActorEffect
		@director_editor_window.add_director_class(klass) if klass.inherited_from? Director
		@director_editor_window.add_director_effect_class(klass) if klass.inherited_from? DirectorEffect
		@project_effect_editor_window.add_project_effect_class(klass) if klass.inherited_from? ProjectEffect
		@variable_editor_window.add_input_class(klass) if klass.inherited_from? VariableInput
		@event_editor_window.add_input_class(klass) if klass.inherited_from? EventInput
	end

	def on_crash
		@widgets_to_hide_on_crash.each { |widget| widget.visible = false }
	end

	def load_from_project(project)
		# TODO: let editors listen to engine directly
		@actor_editor_window.set_parent_objects(project.actors)
		@director_editor_window.set_parent_objects(project.directors)
		@project_effect_editor_window.set_parent_objects(project.effects)
		@theme_editor_window.set_parent_objects(project.themes)
		@curve_editor_window.set_parent_objects(project.curves)
		@variable_editor_window.set_parent_objects(project.variables)
		@event_editor_window.set_parent_objects(project.events)

		# Default to first (enabled) director/theme
		set_director(project.directors.find { |director| director.enabled? })
		set_theme(project.themes.first)

		list = project.missing_plugin_names.collect { |s| '- ' + s }.join("\n")
		unless list.empty?
			EasyDialog.new(self, :icon => :error, :header => "#{project.missing_plugin_names.size.plural('Plugin', 'Plugins')} Removed", :body => "This project requires the following plugins which we do not have:\n\n#{list}\n\nAll objects based on the above plugins have been removed.", :buttons => [[:ok, 'OK', :ok]]).show
		end

		project.not_changed!
	end

	###################################################################
	# Utilities
	###################################################################
	def update
		return unless self.visible?

		@beat_monitor.draw($env[:beat_scale])
		#@simulation_age_label.text = $env[:time].time_format #if @simulation_speed_container.visible?

		@active_editor_window.update

		# Clear the GTK message queue to keep GUI stays responsive under heavy load.
		Gtk.main_clear_queue		# TODO: remove after moving to better animation loop model (not GLib timeouts)
	end

	def update_object(object)
		@editor_windows.each { |win| win.update_object(object) }
	end

	def update_all_user_objects
		@editor_windows.each { |win| win.update_all }
	end

	def on_simulation_speed_value_changed
		value = @simulation_speed_hscale.value	# incoming value is 0.0 to 1.0
		if value < 0.5
			# (0.0 - 0.5) => 0.0x to 1.0x
			value = (value / 0.5).scale(-MAX_SIMULATION_SPEED_MULTIPLIER, 1.0)
		else
			# (0.5 - 1.0) => 1.0x to MAX_SIMULATION_SPEED_MULTIPLIERx
			value = ((value - 0.5) / 0.5).scale(1.0, MAX_SIMULATION_SPEED_MULTIPLIER)
		end
		# Damper on 0.0x, which users will naturally try to find (we don't want to show 0.0x if it's not really
		value = 0.0 if value > -0.1 and value < 0.1
		@simulation_speed_label.text = sprintf("%1.1fx", value)
		$engine.simulation_speed = value
	end

	def on_simulation_speed_hscale_release_event
		Gtk.idle_add_once { @simulation_speed_hscale.value = 0.5 }
		false
	end

	def on_enter_exit_hscale_value_changed
		value = @enter_exit_hscale.value
		$env[:enter] = (value >= 0.5) ? 1.0 : value / 0.5
		$env[:exit] = (value > 0.5) ? (value - 0.5) / 0.5 : 0.0
	end

	def on_enter_exit_hscale_release_event
		Gtk.idle_add_once { @enter_exit_hscale.value = 0.5 }
		false
	end

	#
	# message bar
	#
	def positive_message(msg)
		@message_label.markup = sprintf("<span color='#{GREEN_HEX}'>%s</span>", msg)
		@message_clear_timeout.set
	end

	def negative_message(msg)
		@message_label.markup = sprintf("<span color='#{RED_HEX}'>%s</span>", msg)
		@message_clear_timeout.set
	end

	def retire_message
		@message_label.text = ''
	end

	#
	#
	#
	def set_editor_page_from_type(type)
		@bottom_notebook.set_page(PARENT_USER_OBJECT_TYPES_TO_PAGES_HASH[type])
	end

	def yield_new_parent_object(&proc)
		@active_editor_window.yield_new_parent_object(&proc)
	end

private

	def pause
		$engine.paused = true
		@window_notebook.set_page(PAUSE_PAGE)
	end

	def unpause
		$engine.paused = false
		@window_notebook.set_page(EDITOR_PAGE)
	end

	def on_unpause_button_clicked
		unpause
	end

	def on_toggle_fullscreen_editor_button_clicked
		toggle_fullscreen
	end

	###################################################################
	# Design: File Menu
	###################################################################
	def on_new_set_activate
		save_changes_before {
			@current_file_path = nil
			update_window_title
			$engine.clear_objects
			$engine.add_default_objects
			positive_message('New project created.')
		}
	end

public
	def with_saved_set
		return yield if @current_file_path

		dialog = EasyDialog.new(self, :icon => :info, :header => 'Choose Project Folder', :body => "The project must be saved to disk before adding resources.", :buttons => [[:cancel, '_Cancel', :cancel], [:save, '_Save As...', :save]], :default => :save)
		case dialog.show_modal
		when :save
			yield if on_save_set_as_activate		# save, then continue
		when :cancel
			# nothing
		end
	end

private
	def save_changes_before
		if $engine.project_changed?
			dialog = EasyDialog.new(self, :icon => :question, :header => 'Save changes before continuing?', :body => "If you don't save, <b>#{$engine.project.change_count}</b> changes from the past <b>#{$engine.project.time_since_save.time_format_natural}</b> will be lost.", :buttons => [[:discard, '_Discard Changes', :clear], [:cancel, '_Cancel', :cancel], [:save, '_Save As...', :save]])
			case dialog.show_modal
			when :discard
				yield		# do nothing and let user-initiated project-destroying activity occur
			when :save
				yield if on_save_set_as_activate		# save, then continue
			when :cancel
				# nothing
			end
		else
			yield
		end
	end

	def on_load_set_activate
		save_changes_before {
			choose_file_open_path('Open Project', (@current_file_path ? File.dirname(@current_file_path) : $settings['project-directory']), Project::FILE_PATTERN) { |path|
				load_from_path(path)
			}
		}
	end

	def load_from_path(path)
		begin
			$engine.load_from_path(path)
			@recent_manager.add_item("file://#{path}")
			if $engine.project.missing_plugin_names.empty?
				@current_file_path = path
				positive_message('Project opened.')
			else
				@current_file_path = nil		# prevent easy overwriting (a better option would be to get the new plugins)
				negative_message('Project opened with errors.')
			end
			update_window_title
		rescue Exception => e
			e.report('loading project')
			EasyDialog.new(self, :icon => :error, :header => 'Open Project Failed', :body => e, :buttons => [[:ok, 'OK', :ok]]).show
		end
	end

	def on_save_set_activate
		if @current_file_path.nil?
			on_save_set_as_activate
		else
			save_to_path(@current_file_path)
		end
	end

	def on_save_set_as_activate
		choose_file_save_path('Save Project', @current_file_path || $settings['project-directory'], Project::FILE_PATTERN) { |path|
			path += Project::FILE_EXTENSION_WITH_DOT unless path.has_suffix? Project::FILE_EXTENSION_WITH_DOT
			# TODO: overwrite check happens before appending file extension, so we have a potential unintended overwrite

			if save_to_path(path)
				@current_file_path = path
				update_window_title
			end
			return true
		}
 		return false
	end

	def save_to_path(path)
		begin
			$engine.save_to_path(path)
			positive_message('Project saved.')
			@recent_manager.add_item("file://#{path}")
			return true
		rescue Exception => e
			e.report('saving project')
			EasyDialog.new(self, :icon => :error, :header => 'Save Project Failed', :body => e.to_s, :buttons => [[:ok, 'OK', :ok]]).show
		end
		return false
	end

	def update_window_title
		project_name = @current_file_path ? File.basename(@current_file_path) : 'New Project'
		self.title = "#{project_name} - #{APP_NAME}"
	end

	###################################################################
	# File Menu
	###################################################################
	pipe :on_add_parent_menuitem_activate, :active_editor_window, :method => :add_parent, :no_args => true
	pipe :on_add_child_menuitem_activate, :active_editor_window, :method => :add_child, :no_args => true

	###################################################################
	# Edit Menu
	###################################################################
	pipe :on_edit_activate, :active_editor_window, :method => :edit_selected, :no_args => true
	pipe :on_tag_activate, :active_editor_window, :method => :tag_selected, :no_args => true
	pipe :on_clone_activate, :active_editor_window, :method => :clone_selected, :no_args => true
	pipe :on_delete_activate, :active_editor_window, :method => :delete_selected, :no_args => true

	###################################################################
	# View Menu
	###################################################################
	pipe :on_view_actor_editor_activate, :bottom_notebook, :method => :set_page, :args => ACTOR_EDITOR_PAGE
	pipe :on_view_director_editor_activate, :bottom_notebook, :method => :set_page, :args => DIRECTOR_EDITOR_PAGE
	pipe :on_view_project_effect_editor_activate, :bottom_notebook, :method => :set_page, :args => PROJECT_EFFECT_EDITOR_PAGE
	pipe :on_view_theme_editor_activate, :bottom_notebook, :method => :set_page, :args => THEME_EDITOR_PAGE
	pipe :on_view_curve_editor_activate, :bottom_notebook, :method => :set_page, :args => CURVE_EDITOR_PAGE
	pipe :on_view_variable_editor_activate, :bottom_notebook, :method => :set_page, :args => VARIABLE_EDITOR_PAGE
	pipe :on_view_event_editor_activate, :bottom_notebook, :method => :set_page, :args => EVENT_EDITOR_PAGE

	#pipe :on_time_scrub_bar_activate, :simulation_age_label, :method => :toggle_visibility, :no_args => true
	pipe :on_beat_monitor_activate, :beat_monitor_container, :method => :toggle_visibility, :no_args => true

	attr_reader :current_file_path

	def on_show_in_performance_mode_activate
		begin
			run_performer!
		rescue Exception => e
			EasyDialog.new(self, :icon => :error, :header => "Run Fullscreen Failed", :body => e.to_s, :buttons => [[:ok, 'OK', :ok]]).show
		end
	end

	def run_performer!
		if @current_file_path
			if $engine.project_changed?
				# save to temporary file in current location (ensures that resources can be loaded)
				project_file_path = File.join(File.dirname(@current_file_path), 'temporary-save.luz')
				return negative_message('Saving project failed.') unless $engine.project.save_copy_to_path(project_file_path)
			else
				# use existing saved and up-to-date project file
				project_file_path = @current_file_path
			end
		else
			# save to temporary location (since we know there are no resources yet)
			project_file_path = File.join(Dir.tmpdir, 'project.luz')
			return negative_message('Saving project failed.') unless $engine.project.save_copy_to_path(project_file_path)
		end

		# determine resolution to use
		fullscreen_resolution = $settings['performer-resolution']

		if fullscreen_resolution =~ /(\d*)x(\d*)/
			width, height = (fullscreen_resolution.scan(/(\d*)x(\d*)/).first)
		else
			width, height = Gdk::Screen.default.width, Gdk::Screen.default.height
		end

		fps = $settings['performer-fps']

		# Launch Performer, then pause the editor.  Read from Performer so that its buffer doesn't fill.  NOTE: save output?
		printf("Executing: %s\n", cmd = "./#{PERFORMER_EXECUTABLE_NAME} --fullscreen --width #{width} --height #{height} --frames-per-second #{fps} \"#{project_file_path}\"")

		open("|#{cmd}") { |f| sleep 1 ; pause ; begin ; while s=f.readpartial(1024) ; puts s ; end ; rescue Exception => e ; unpause ; end ; }	# NOTE: the 'sleep 1' lets the Performer take over the screen before we make changes in the GUI when we pause (fewer changes = better)
	end

	def on_show_preferences_menuitem_activate
		@preferences_window.present
	end

	def on_input_manager_activate
		open("|#{INPUT_MANAGER_EXECUTABLE_NAME}")
	end

	def on_spectrum_analyzer_activate
		open("|#{SPECTRUM_ANALYZER_EXECUTABLE_NAME}")
	end

	def on_browse_project_folder_activate
		return negative_message('Save project first.') unless @current_file_path

		open("|gnome-open \"#{File.dirname(@current_file_path)}\"")
	end

	def on_record_activate
		return negative_message('Save project before rendering.') unless @current_file_path

		temp_path = @current_file_path + '.tmp'
		if $engine.save_to_path(temp_path)
			command = sprintf("./%s --project \"%s\" &", RECORDER_EXECUTABLE_NAME, temp_path)
			system(command)

			pause
		else
			negative_message('Launching recorder failed.')
		end
	end

	def toggle_fullscreen
		super
		adjust_drawing_area
	end

	def on_fullscreen_activate
		toggle_fullscreen
	end

	###################################################################
	# Action Menu
	###################################################################
	def on_beat_activate
		$engine.beat!
	end

	def on_pause_activate
		pause
	end

	###################################################################
	# Help Menu
	###################################################################
	def on_about_activate
		@about_window.present
	end

	###################################################################
	# Debug Menu
	###################################################################
	def on_reload_activate
		change_count = $engine.reload
		if change_count > 0
			positive_message "Reloaded #{change_count.plural('file', 'files')}."
			$gui.reload_notify
		else
			negative_message "No modified source files found."
		end
	end

	def on_print_object_count
		positive_message "#{ObjectSpace.object_count} objects, #{ObjectSpace.object_count(Gtk::Widget)} Gtk+ widgets"
	end

	def on_garbage_collect
		positive_message "(Cleanup took #{start = Time.now ; $application.do_gc ; Time.now - start} seconds.)"
	end

	def on_edit_plugin_source_activate
		user_objects = @active_editor_window.selected_user_objects
		return negative_message('Select an object first.') unless user_objects and !user_objects.empty?

		user_objects.collect { |uo| uo.class.source_file_path }.uniq.each { |path|
			open("|#{SOURCE_EDITOR_EXECUTABLE_NAME} \"#{path}\"")
		}
	end

	###################################################################
	# Control Window Widget Signal Handlers
	###################################################################

	def toggle_actor_stage_visibility
		@actor_stage_container.visible = (@actor_stage_visible = !@actor_stage_visible)
		@enable_actor_stage_image.sensitive = @actor_stage_visible
	end

	def toggle_director_stage_visibility
		@director_stage_container.visible = (@director_stage_visible = !@director_stage_visible)
		@enable_director_stage_image.sensitive = @director_stage_visible
	end

	def toggle_output_preview_visibility
		@output_preview_container.visible = (@output_preview_visible = !@output_preview_visible)
		@enable_output_preview_image.sensitive = @output_preview_visible
	end

	def toggle_actor_and_director_stages
		toggle_actor_stage_visibility
		toggle_director_stage_visibility
	end

	def on_toggle_actor_stage_clicked
		toggle_actor_stage_visibility
		adjust_drawing_area
	end

	def on_toggle_director_stage_clicked
		toggle_director_stage_visibility
		adjust_drawing_area
	end

	def on_toggle_output_preview_clicked
		toggle_output_preview_visibility
		adjust_drawing_area
	end

	def num_visible_previews
		((@actor_stage_visible ? 1 : 0) + (@director_stage_visible ? 1 : 0) + (@output_preview_visible ? 1 : 0))
	end

	def on_window_vpaned_position_changed
		@window_vpaned_preferred_positions_for_view_counts[num_visible_previews] = @window_vpaned.position
	end

	def adjust_drawing_area
		@drawing_area_container.visible = (num_visible_previews > 0)

		if num_visible_previews > 0
			if @window_vpaned_preferred_positions_for_view_counts[num_visible_previews]
				@window_vpaned.position = @window_vpaned_preferred_positions_for_view_counts[num_visible_previews]
			else
				first_visible_view_container = [@actor_stage_container, @director_stage_container,  @output_preview_container].find { |c| c.visible? }
				@window_vpaned.position = first_visible_view_container.child.height + 4
			end
		end
	end

	def on_enable_actor_stage_view_togglebutton_toggled
		@actor_stage_container.visible = @enable_actor_stage_view_togglebutton.active?
		#@actor_stage_controls_container.visible = @enable_actor_stage_view_togglebutton.active?
		adjust_drawing_area
	end

	def on_enable_director_stage_view_togglebutton_toggled
		@director_stage_container.visible = @enable_director_stage_view_togglebutton.active?
		#@director_stage_controls_container.visible = @enable_director_stage_view_togglebutton.active?
		adjust_drawing_area
	end

	def on_enable_output_preview_view_togglebutton_toggled
		@output_preview_container.visible = @enable_output_preview_view_togglebutton.active?
		#@director_stage_controls_container.visible = @enable_director_stage_view_togglebutton.active?
		adjust_drawing_area
	end

	def on_show_output_window_clicked
		@output_window.show
		@output_window.present
	end

	def on_zoom_in_activate
		@actor_stage.zoom *= 1.5
	end

	def on_zoom_out_activate
		@actor_stage.zoom /= 1.5
	end

	def on_zoom_reset_activate
		@actor_stage.zoom = 1.0
	end

public

	###################################################################
	# Shutdown
	###################################################################
	def on_quit_activate
		save_changes_before { hide ; $application.quit }
	end

	def on_delete_event
		save_changes_before { hide ; $application.quit }
		true					# handled (NOTE: required to avoid "destroyed GLib Object" error on shutdown)
	end
end
