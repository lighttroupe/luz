def create_default_gui
	screen = GuiBox.new

	screen << (actor_list=GuiList.new($engine.project.actors).set_scale(0.2).set_offset_x(-0.4).set_offset_y(0.4))
	screen << (variables_list=GuiList.new($engine.project.variables).set(:hidden => true, :scale_x => 0.12, :scale_y => 0.03, :offset_x => 0.23, :offset_y => 0.5, :spacing => 0.4))
	screen << (variable_button = GuiButton.new.set(:scale_x => 0.08, :scale_y => 0.08, :offset_x => 0.23, :offset_y => 0.50 - 0.04, :background_image => $engine.load_image('images/buttons/menu.png')))
	screen << (events_list=GuiList.new($engine.project.events).set(:hidden => true, :scale_x => 0.12, :scale_y => 0.03, :offset_x => 0.4, :offset_y => 0.5, :spacing => 0.4))
	screen << (event_button = GuiButton.new.set(:scale_x => 0.08, :scale_y => 0.08, :offset_x => 0.40, :offset_y => 0.50 - 0.04, :background_image => $engine.load_image('images/buttons/menu.png')))
	screen << (text = BitmapFont.new.set(:string => 'Luz 2.0 has text support!!', :offset_x => -0.3, :offset_y => 0.5 - 0.03, :scale_x => 0.02, :scale_y => 0.04))

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

	return screen
end
