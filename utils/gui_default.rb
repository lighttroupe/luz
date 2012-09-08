def create_default_gui
	screen = GuiBox.new

	screen << (actor_list=GuiList.new($engine.project.actors).set_scale(0.2).set_offset_x(-0.4).set_offset_y(0.4))
	screen << (variables_list=GuiList.new($engine.project.variables).set_hidden(true).set_scale_x(0.12).set_scale_y(0.03).set_offset_x(0.23).set_offset_y(0.5).set_spacing(0.4))
	screen << (variable_button = GuiButton.new.set(:scale_x => 0.08, :scale_y => 0.08, :offset_x => 0.23, :offset_y => 0.50 - 0.04, :background_image => $engine.load_image('images/buttons/menu.png')))
	screen << (events_list=GuiList.new($engine.project.events).set_hidden(true).set_scale_x(0.12).set_scale_y(0.03).set_offset_x(0.4).set_offset_y(0.5).set_spacing(0.4))
	screen << (event_button = GuiButton.new.set(:scale_x => 0.08, :scale_y => 0.08, :offset_x => 0.40, :offset_y => 0.50 - 0.04, :background_image => $engine.load_image('images/buttons/menu.png')))
	screen << (text = BitmapFont.new.set(:string => 'Luz 2.0 has text support!!', :scale_x => 0.02, :scale_y => 0.04))

	# Main menu
	screen << (save_button = GuiButton.new.set(:scale_x => 0.1, :scale_y => 0.1, :offset_y => 0.2, :background_image => $engine.load_image('images/buttons/menu.png')))

	@cnt ||= 0
	variable_button.on_clicked {
		if variables_list.hidden?
			variables_list.set(:hidden => false, :opacity => 0.0).animate(:offset_y, 0.38, duration=0.2) { text.set_string(sprintf("here's your list!")) }.animate(:opacity, 1.0, duration=0.2)
		else
			variables_list.animate(:offset_y, 0.5, duration=0.25) { variables_list.set_hidden(true) ; text.set_string(sprintf("byebye list!")) }.animate(:opacity, 0.0, duration=0.2)
		end
	}

	event_button.on_clicked {
		if events_list.hidden?
			events_list.set(:hidden => false, :opacity => 0.0).animate(:offset_y, 0.38, duration=0.2) { text.set_string(sprintf("there are events!")) }.animate(:opacity, 1.0, duration=0.2)
		else
			events_list.animate(:offset_y, 0.5, duration=0.25) { events_list.set_hidden(true) ; text.set_string(sprintf("no more events!")) }.animate(:opacity, 0.0, duration=0.2)
		end
	}

	save_button.on_clicked {
		#$engine.project.variables << $engine.project.variables.random.deep_clone
		text.set_string(sprintf("clicked the button %d times", @cnt += 1))
	}

	return screen
end
