#include <gtkmm.h>
#include <gtkmm/window.h>

#include <vector>
using namespace std;

#include "my-drawing-area.h"
#include "body-tracker.h"

class BodyTrackerWindow : public Gtk::Window
{
public:
	BodyTrackerWindow();
	virtual ~BodyTrackerWindow();

	void trigger_redraw();
	void update();
	void send();

private:
	void draw();

	bool on_drawing_area_expose_event(GdkEventExpose* event);
	void on_first_human_number_spinbutton_changed();
	void on_last_human_number_spinbutton_changed();
	void update_window_title();
	void on_fullscreen_button_clicked();
	bool on_window_button_press_event(GdkEventButton* event);
	bool on_key_press_event(GdkEventKey* event);
	bool on_motion_notify_event(GdkEventMotion* event);

	virtual bool on_drawing_area_button_press_event(GdkEventButton* event);
	bool on_window_state_event(GdkEventWindowState* event);
	void on_quit_dialog_response(int response_id);
	void on_broadcast_changed();
	bool on_delete_event(GdkEventAny *event);

	// Window
	Gtk::VBox m_window_vbox;
	Gtk::HBox m_toolbar;
	MyDrawingArea m_drawing_area;

	// Toolbar
	Gtk::SpinButton m_first_human_number_spinbutton;
	Gtk::SpinButton m_last_human_number_spinbutton;
	Gtk::CheckButton m_broadcast_button;
	Gtk::Button m_fullscreen_button;

	// Dialogs
	Gtk::Dialog* m_quit_dialog;

	//
	// Data
	//
	BodyTracker* m_body_tracker;

	bool m_is_fullscreen;

	gint m_first_human_number;
	gint m_last_human_number;
};
