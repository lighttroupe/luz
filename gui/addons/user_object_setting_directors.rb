class UserObjectSettingDirectors
	def to_yaml_properties
		super + ['@directors']
	end

	#
	# GUI
	#
	def gui_build_editor
		@on_image = $engine.load_image('images/buttons/enabled-overlay-on.png')
		@off_image = $engine.load_image('images/buttons/enabled-overlay-off.png')

		box = GuiBox.new
		box << (@list = GuiGrid.new.set(:scale_x => 0.98, :scale_y => 0.98, :offset_y => -0.40, :item_scale_y => 5.0, :min_columns => 8))	#, :item_aspect_ratio => 4.0))
		box << create_user_object_setting_name_label

		all_directors.each { |director|
			@list << renderer=GuiObjectRenderer.new(director)
			if get_directors.include?(director)
				renderer.foreground_image = @on_image
			else
				renderer.foreground_image = @off_image
			end
			renderer.on_clicked {
				toggle_selection(director)
			}
		}
		box
	end

	def toggle_selection(director)
		renderer = renderer_for_director(director)
		if @directors.include?(director)
			@directors.delete(director)
			renderer.foreground_image = @off_image
		else
			@directors = all_directors & (@directors + [director])		# preserves order of all_directors
			renderer.foreground_image = @on_image
		end
	end

	def renderer_for_director(director)
		@list.each { |renderer|
			return renderer if renderer.object == director
		}
	end
end
