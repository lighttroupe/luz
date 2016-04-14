#include <gtkmm.h>
#include <gtkmm/window.h>

#include <vector>
using namespace std;

#include "input.h"
#ifdef SUPPORT_WIIMOTE
#include "input-wiimote.h"
#endif
#ifdef SUPPORT_TABLET
#include "input-tablet.h"
#endif
#ifdef SUPPORT_MIDI
#include "input-midi.h"
#endif
#ifdef SUPPORT_JOYSTICK
#include "input-joystick.h"
#endif
#ifdef SUPPORT_TOUCHPAD
#include "input-touchpad.h"
#endif

class InputManagerWindow : public Gtk::Window
{
public:
	InputManagerWindow();
	virtual ~InputManagerWindow();
	void update();

private:
	Gtk::VBox m_window_vbox;
	Gtk::VBox m_inputs_vbox;
	Gtk::HBox m_toolbar;
	Gtk::Button m_wiimote_discover_button;
	Gtk::CheckButton m_broadcast_button;

	int m_next_wiimote_number;

	void add_input(Input* input);
	vector<Input*> m_input_list;

	virtual bool on_button_press_event(GdkEventButton* event);
	//virtual bool on_key_press_event(GdkEventKey* event);

	void on_wiimote_discover_button_clicked();
	void on_broadcast_changed();

	int choose_device_number_for_new_input(Input* input);

	void on_input_device_number_spinbox_changed(Gtk::SpinButton* spin_button, Input* input);

	void on_input_remove_button_clicked(Input* input);

	bool on_delete_event(GdkEventAny *event);
};
