#define WINDOW_TITLE ("Luz Input Manager")

#include "input-manager.h"
#include "input-manager-window.h"

#define MIN_DEVICE_NUMBER (1)
#define MAX_DEVICE_NUMBER (100)

#define MSG_DISCOVER_WIIMOTE ("Add Wiimote")
#define MSG_WIIMOTE_INSTRUCTIONS ("Press Wiimote Buttons 1+2 ...")
#define MSG_WIIMOTE_NOT_FOUND ("Wiimote Not Found!")
#define MSG_REFRESH ("Rescan")
#define WINDOW_MINIMUM_WIDTH (420)
#define MSG_ENABLE_BROADCAST ("Send to Network")
#define MSG_CONFIRM_QUIT ("Confirm Quit?")

InputManagerWindow::InputManagerWindow()
	: m_input_list(),
		m_window_vbox(),
		m_inputs_vbox(),
		m_toolbar(),
#ifdef SUPPORT_WIIMOTE
		m_wiimote_discover_button(MSG_DISCOVER_WIIMOTE),
#endif
		m_broadcast_button(MSG_ENABLE_BROADCAST)
{
	set_title(WINDOW_TITLE);
	set_border_width(STANDARD_WIDGET_SPACING);
	set_resizable(false);

	m_toolbar.set_size_request(WINDOW_MINIMUM_WIDTH,-1);		// this creates a reasonable minimum window width

	// One vbox to rule them all
	m_window_vbox.set_spacing(STANDARD_WIDGET_SPACING);
	add(m_window_vbox);

	add_events(Gdk::BUTTON_PRESS_MASK);
	//signal_button_press_event().connect(sigc::mem_fun(*this, &InputManagerWindow::on_button_press_event));

	add_events(Gdk::KEY_PRESS_MASK);
	//signal_key_press_event().connect(sigc::mem_fun(*this, &InputManagerWindow::on_key_press_event));

	//
	// Toolbar is the first item in vbox
	//
	m_toolbar.set_spacing(STANDARD_WIDGET_SPACING);

		// Toolbar: Wiimote Discovery button
#ifdef SUPPORT_WIIMOTE
		m_wiimote_discover_button.signal_clicked().connect(sigc::mem_fun(*this, &InputManagerWindow::on_wiimote_discover_button_clicked));
		m_toolbar.pack_start(m_wiimote_discover_button, false, false);
#endif

		// Toolbar: spacer to push furth items to the far right
		Gtk::Label* spacer = new Gtk::Label();
		m_toolbar.pack_start(*spacer, true, true);		// booleans mean: expand and fill extra space

//#ifdef LO_BROADCAST_SUPPORT
		// Toolbar: Broadcast Togglebutton
		m_broadcast_button.set_mode(true);		// draw_indicator=true, makes it a checkbutton, brilliant API here
		m_broadcast_button.signal_clicked().connect(sigc::mem_fun(*this, &InputManagerWindow::on_broadcast_changed));
		m_toolbar.pack_start(m_broadcast_button, false, false);
//#endif

	m_window_vbox.pack_start(m_toolbar, false, false);

	Gtk::HSeparator* separator = new Gtk::HSeparator();
	m_window_vbox.pack_start(*separator, false, false);

	// Inputs vbox holds one widget per device
	m_window_vbox.pack_start(m_inputs_vbox, false, false);

	//
	// MIDI
	//
#ifdef SUPPORT_MIDI
	InputMIDI* midi = new InputMIDI();
	add_input(midi);
#endif

	//
	// Touchpad
	//
#ifdef SUPPORT_TOUCHPAD
	InputTouchpad* touchpad = new InputTouchpad();
	if(touchpad->connect()) {
		add_input(touchpad);
	}
	else {
		delete touchpad;
	}
#endif

	//
	// Tablets
	//
#ifdef SUPPORT_TABLET
	vector<string>* list = tablet_list();
	for(int i=0; i<list->size() ; i++) {
		string* s = &(list->at(i));

		if(s->find("Wacom") != s->npos && s->find("cursor") == s->npos && s->find("pad") == s->npos) {
		//if(s->find("Wacom") != s->npos) { // && (s->find("curso") != s->npos && s->find("cursor") == s->npos && s->find("pad") == s->npos) {
			InputTablet* tablet = tablet_open_by_name_and_id((const char*)(s->c_str()));
			add_input(tablet);
		}
	}
#endif

	//
	// Joysticks
	//
#ifdef SUPPORT_JOYSTICK
	int count = joystick_count();
	for(int i=0 ; i<count ; i++) {
		InputJoystick* joystick = joystick_open_by_index(i);
		add_input(joystick);
	}
#endif
}

void gtk_flush()
{
	while(Gtk::Main::events_pending()) Gtk::Main::iteration();
}

bool InputManagerWindow::on_button_press_event(GdkEventButton* event)
{
	if((event->type == GDK_BUTTON_PRESS) && (event->button == 1)) {
		begin_move_drag(event->button, event->x_root, event->y_root, event->time);
		return true;	// handled
	}
	return false;	// not handled
}

/*
bool InputManagerWindow::on_key_press_event(GdkEventKey* event)
{
	if(event->keyval == GDK_Escape) {
		hide();
		return true;	// handled
	}
	return false;	// not handled
}
*/

#ifdef SUPPORT_WIIMOTE
void InputManagerWindow::on_wiimote_discover_button_clicked()
{
	InputWiimote* pInputWiimote = new InputWiimote();
	m_wiimote_discover_button.set_label(MSG_WIIMOTE_INSTRUCTIONS);
	m_wiimote_discover_button.set_sensitive(false);
	gtk_flush();

	if(pInputWiimote->scan()) {
		m_wiimote_discover_button.set_label(MSG_DISCOVER_WIIMOTE);
		pInputWiimote->set_device_number(choose_device_number_for_new_input(pInputWiimote));
		add_input(pInputWiimote);
	}
	else {
		delete pInputWiimote;

		m_wiimote_discover_button.set_label(MSG_WIIMOTE_NOT_FOUND);
		gtk_flush();
		sleep(1);
		m_wiimote_discover_button.set_label(MSG_DISCOVER_WIIMOTE);
	}
	m_wiimote_discover_button.set_sensitive(true);
}
#endif

void InputManagerWindow::on_broadcast_changed()
{
	g_message_bus->set_broadcast(m_broadcast_button.get_active());
}

int InputManagerWindow::choose_device_number_for_new_input(Input* input)
{
	bool device_number_exists[MAX_DEVICE_NUMBER+1] = {false};

	// Find all existing devices (of this type) and note their numbers
	for(int i=0 ; i<m_input_list.size() ; i++) {
		if(input->device_type() == m_input_list[i]->device_type()) {
			device_number_exists[m_input_list[i]->device_number()] = true;
		}
	}
	// If we have Wiimote 1, Wiimote 3, Wiimote 4, we return 2
	for(int i=1 ; i<=MAX_DEVICE_NUMBER ; i++) {
		if(!device_number_exists[i]) {
			return i;
		}
	}
	return 1;
}

void InputManagerWindow::add_input(Input* input)
{
	m_input_list.push_back(input);

	//
	// Add a new row for this input
	//
	Gtk::HBox* row = new Gtk::HBox();
	row->set_spacing(STANDARD_WIDGET_SPACING);

	Gtk::Label* label = new Gtk::Label(input->device_name());
	label->set_alignment(0.0, 0.5);
	row->pack_start(*label, true, true);

	// spacer to push spinbuttons/buttons to the far right
	Gtk::Label* spacer = new Gtk::Label();
	row->pack_start(*spacer, true, true);		// booleans mean: expand and fill extra space

	Gtk::Label* type_label = new Gtk::Label(input->device_type());
	row->pack_start(*type_label, false, false);		// booleans mean: expand and fill extra space

	// Device number Spinbutton: Wiimote 01, Wiimote 02, etc.
	Gtk::SpinButton* device_number_spinbutton = new Gtk::SpinButton(1.0);
	device_number_spinbutton->set_range((float)MIN_DEVICE_NUMBER, (float)MAX_DEVICE_NUMBER);
	device_number_spinbutton->set_increments(1.0, 1.0);
	device_number_spinbutton->set_value(input->device_number());
	row->pack_start(*device_number_spinbutton, false, false);
	device_number_spinbutton->signal_value_changed().connect(sigc::bind<Gtk::SpinButton*, Input*>(sigc::mem_fun(*this, &InputManagerWindow::on_input_device_number_spinbox_changed), device_number_spinbutton, input));

	// Delete button
	Gtk::Button* remove_button = new Gtk::Button();
	Gtk::Image* remove_image = new Gtk::Image(Gtk::StockID("gtk-delete"), Gtk::ICON_SIZE_MENU);
	remove_button->set_image(*remove_image);
	remove_button->signal_clicked().connect(sigc::bind<Input*>(sigc::mem_fun(*this, &InputManagerWindow::on_input_remove_button_clicked), input));
	row->pack_start(*remove_button, false, false);

	row->show_all();
	m_inputs_vbox.add(*row);

	// We store the GUI widget (row) as user-data
	input->set_user_data((void*)row);

	input_update_in_thread(input);
}

void InputManagerWindow::on_input_remove_button_clicked(Input* input)
{
	for(int i=0; i < m_input_list.size() ; i++) {
		if(input == m_input_list[i]) {
			m_input_list.erase(m_input_list.begin() + i);

			// get user-data (GUI row widget) and destroy it
			Gtk::HBox* row = (Gtk::HBox*)input->get_user_data();
			m_inputs_vbox.remove(*row);

			input->set_time_to_die();
		}
	}
}

void InputManagerWindow::on_input_device_number_spinbox_changed(Gtk::SpinButton* spin_button, Input* input)
{
	input->set_device_number(spin_button->get_value_as_int());
}

bool InputManagerWindow::on_delete_event(GdkEventAny *event)
{
	// Confirmation Dialog
	Gtk::Dialog* dialog = new Gtk::Dialog(MSG_CONFIRM_QUIT, *this);
	dialog->add_button(Gtk::StockID("gtk-cancel"), FALSE);
	dialog->add_button(Gtk::StockID("gtk-quit"), TRUE);
	dialog->set_default_response(FALSE);

	if(dialog->run() == TRUE) {
		Gtk::Main::quit();
	}
	delete dialog;
	return true;
}

InputManagerWindow::~InputManagerWindow()
{
}
