#
# GUI addons for the base class for all objects the user makes (eg Actors, Actor Effects, Themes, Event Inputs)
#
class UserObject
	include MethodsForGuiObject

	LABEL_COLOR_CRASHY = [1,0,0,0.5]
	LABEL_COLOR_ENABLED = [1,1,1,1]
	LABEL_COLOR_DISABLED = [1.0, 1.0, 1.0, 0.25]
	USER_OBJECT_TITLE_HEIGHT = 0.65

	#
	# API
	#
	def gui_build_editor
		if respond_to? :effects
			box = GuiBox.new

			# Two-lists side by side
			@gui_effects_list = GuiListWithControls.new(effects).set({:spacing_y => -0.8, :scale_x => 0.29, :offset_x => -0.35, :scale_y => 0.87, :offset_y => -0.06, :item_aspect_ratio => 3.0})
			box << @gui_effects_list

			@gui_settings_list = GuiList.new.set({:spacing_y => -1.0, :scale_x => 0.69, :offset_x => 0.15, :scale_y => 0.87, :offset_y => -0.06, :item_aspect_ratio => 4.0})
			box << @gui_settings_list

			gui_fill_settings_list(self)		# show this object's settings

			box
		else
			GuiObject.new		# nothing
		end
	end

	def gui_fill_settings_list(user_object)
		return unless @gui_settings_list

		@gui_effects_list.clear_selection! if user_object == self

		@gui_settings_list.clear!
		user_object.settings.each { |setting|
			@gui_settings_list << setting.gui_build_editor
		}
	end

	def has_settings_list?
		!@gui_settings_list.nil?
	end

	#
	# Rendering
	#
	def gui_render!
		gui_render_background
		gui_render_label
	end

	def gui_render_label
		with_color(label_color) {
			@title_label ||= BitmapFont.new.set(:string => title, :scale_x => 0.95, :scale_y => USER_OBJECT_TITLE_HEIGHT)
			if pointer_hovering?
				@title_label.gui_render!
			else
				with_vertical_clip_plane_right_of(0.5) {
					@title_label.gui_render!
				}
			end
		}
	end

	def hit_test_render!
		with_unique_hit_test_color_for_object(self, 0) { unit_square }
	end

	#
	# Pointer
	#
	def click(pointer)
		$gui.build_editor_for(self, :pointer => pointer)
		@parent.child_click(pointer)
	end

	def on_child_user_object_selected(user_object)
		gui_fill_settings_list(user_object)
		@gui_effects_list.set_selection(user_object) if @gui_effects_list
	end

	#
	# Helpers
	#

private

	def label_color
		if crashy?
			LABEL_COLOR_CRASHY
		elsif enabled?
			LABEL_COLOR_ENABLED
		else
			LABEL_COLOR_DISABLED
		end
	end
end
