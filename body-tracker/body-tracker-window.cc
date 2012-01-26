#include <gtkglmm.h>
#include <gtkmm/gl/widget.h>

#include "application.h"
#include "body-tracker-window.h"

#include "utils.h"

#define WINDOW_TITLE_FORMAT ("Luz Body Tracker - Human %02d")
#define WINDOW_TITLE_FORMAT_RANGE ("Luz Body Tracker - Human %02d to %02d")
#define WINDOW_TITLE_FORMAT_UNINITIALIZED ("Luz Body Tracker - Kinect Not Found")

#define MSG_ENABLE_BROADCAST ("Send to Network")
#define MSG_CONFIRM_QUIT ("Confirm Quit?")

#define MIN_HUMAN_NUMBER (1)
#define MAX_HUMAN_NUMBER (8)

#define WINDOW_MINIMUM_WIDTH (500)

BodyTrackerWindow::BodyTrackerWindow()
	: m_window_vbox(),
		m_first_human_number_spinbutton(),
		m_last_human_number_spinbutton(),
		m_fullscreen_button(),
		m_toolbar(),
		m_first_human_number(1),
		m_last_human_number(1),
		m_broadcast_button(MSG_ENABLE_BROADCAST),
		m_is_fullscreen(false)
{
	m_quit_dialog = new Gtk::Dialog(MSG_CONFIRM_QUIT, *this);
	m_quit_dialog->add_button(Gtk::StockID("gtk-cancel"), FALSE);
	m_quit_dialog->add_button(Gtk::StockID("gtk-quit"), TRUE);
	m_quit_dialog->set_default_response(FALSE);
	m_quit_dialog->signal_response().connect(sigc::mem_fun(*this, &BodyTrackerWindow::on_quit_dialog_response));

	set_border_width(0);
	set_resizable(true);

	set_size_request(WINDOW_MINIMUM_WIDTH, (WINDOW_MINIMUM_WIDTH * 3) / 4);		// this sets the startup size

	// One vbox to rule them all
	m_window_vbox.set_spacing(0);		// aesthetics
	add(m_window_vbox);

	// Window dragging (in usused space)
	add_events(Gdk::BUTTON_PRESS_MASK);
	signal_button_press_event().connect(sigc::mem_fun(*this, &BodyTrackerWindow::on_window_button_press_event));

	//
	// Toolbar is the first item in vbox
	//
	m_toolbar.set_spacing(STANDARD_WIDGET_SPACING);
	m_toolbar.set_border_width(0);		// http://en.wikipedia.org/wiki/Fitts's_law

		// Toolbar: First Human Number Spinbutton
		m_first_human_number_spinbutton.set_tooltip_text("First Human Number");
		m_first_human_number_spinbutton.set_numeric(true);
		m_first_human_number_spinbutton.set_range((float)MIN_HUMAN_NUMBER, (float)MAX_HUMAN_NUMBER);
		m_first_human_number_spinbutton.set_increments(1.0, 1.0);
		m_first_human_number_spinbutton.set_value(m_first_human_number);
		m_toolbar.pack_start(m_first_human_number_spinbutton, false, true);		// booleans for expand / fill extra space
		m_first_human_number_spinbutton.signal_value_changed().connect(sigc::mem_fun(*this, &BodyTrackerWindow::on_first_human_number_spinbutton_changed));

		// Toolbar: spacer to push furth items to the far right
		Gtk::Label* to_label = new Gtk::Label("to");
		m_toolbar.pack_start(*to_label, false, false);		// booleans mean: expand and fill extra space

		// Toolbar: Last Human Number Spinbutton
		m_last_human_number_spinbutton.set_tooltip_text("Last Human Number");
		m_last_human_number_spinbutton.set_numeric(true);
		m_last_human_number_spinbutton.set_range((float)MIN_HUMAN_NUMBER, (float)MAX_HUMAN_NUMBER);
		m_last_human_number_spinbutton.set_increments(1.0, 1.0);
		m_last_human_number_spinbutton.set_value(m_last_human_number);
		m_toolbar.pack_start(m_last_human_number_spinbutton, false, true);		// booleans for expand / fill extra space
		m_last_human_number_spinbutton.signal_value_changed().connect(sigc::mem_fun(*this, &BodyTrackerWindow::on_last_human_number_spinbutton_changed));

		// Toolbar: spacer to push furth items to the far right
		Gtk::Label* spacer = new Gtk::Label();
		m_toolbar.pack_start(*spacer, true, true);		// booleans mean: expand and fill extra space

		// Toolbar: Broadcast Togglebutton
		m_broadcast_button.set_mode(true);		// draw_indicator=true makes it draw as a checkbox (brilliant API here...)
		m_broadcast_button.signal_clicked().connect(sigc::mem_fun(*this, &BodyTrackerWindow::on_broadcast_changed));
		m_toolbar.pack_start(m_broadcast_button, false, false);

		// Toolbar: Fullscreen Button
		m_fullscreen_button.set_tooltip_text("Toggle Fullscreen");
		m_fullscreen_button.set_image(*(new Gtk::Image(Gtk::Stock::FULLSCREEN, *(new Gtk::IconSize(Gtk::ICON_SIZE_SMALL_TOOLBAR)))));
		m_fullscreen_button.set_relief(Gtk::RELIEF_NONE);
		m_toolbar.pack_start(m_fullscreen_button, false, true);		// booleans mean: expand and fill extra space
		m_fullscreen_button.signal_clicked().connect(sigc::mem_fun(*this, &BodyTrackerWindow::on_fullscreen_button_clicked));

	m_window_vbox.pack_start(m_toolbar, false, false);

	//
	// DrawingArea
	//
	m_drawing_area.set_size_request(256, 256);
	m_window_vbox.pack_start(m_drawing_area, true, true);
	m_drawing_area.signal_expose_event().connect(sigc::mem_fun(*this, &BodyTrackerWindow::on_drawing_area_expose_event), false);
	m_drawing_area.add_events(Gdk::BUTTON_PRESS_MASK);
	m_drawing_area.signal_button_press_event().connect(sigc::mem_fun(*this, &BodyTrackerWindow::on_drawing_area_button_press_event), false);
	m_drawing_area.add_events(Gdk::BUTTON_RELEASE_MASK);
	m_drawing_area.signal_button_release_event().connect(sigc::mem_fun(*this, &BodyTrackerWindow::on_drawing_area_button_press_event), false);
	m_drawing_area.add_events(Gdk::POINTER_MOTION_MASK);
	m_drawing_area.signal_motion_notify_event().connect(sigc::mem_fun(*this, &BodyTrackerWindow::on_motion_notify_event), false);

	// Window dragging (in usused space)
	add_events(Gdk::BUTTON_PRESS_MASK);
	signal_button_press_event().connect(sigc::mem_fun(*this, &BodyTrackerWindow::on_window_button_press_event));

	// Key presses
	signal_key_press_event().connect(sigc::mem_fun(*this, &BodyTrackerWindow::on_key_press_event));

	//
	// OpenNI Tracker
	//
	m_body_tracker = new BodyTracker();

	update_window_title();
}

bool BodyTrackerWindow::on_motion_notify_event(GdkEventMotion* event)
{
	if(event->y < m_toolbar.get_height() * 2) {
		m_toolbar.show();
	}
}

bool BodyTrackerWindow::on_key_press_event(GdkEventKey* event)
{
	if(event->type == GDK_KEY_PRESS && event->keyval == GDK_Escape) {
		if(m_is_fullscreen) {
			if(m_toolbar.get_visible()) {
				m_toolbar.hide();
			}
			else {
				m_toolbar.show();
			}
		}
		else {
			m_quit_dialog->show();
		}
		return true;
	}
	return false;
}

void BodyTrackerWindow::update_window_title()
{
	char buffer[201];
	if(!m_body_tracker->is_openni_initialized())
		snprintf(buffer, 200, WINDOW_TITLE_FORMAT_UNINITIALIZED);
	else if(m_first_human_number == m_last_human_number)
		snprintf(buffer, 200, WINDOW_TITLE_FORMAT, m_first_human_number);
	else
		snprintf(buffer, 200, WINDOW_TITLE_FORMAT_RANGE, m_first_human_number, m_last_human_number);

	set_title(buffer);
}

// Track fullscreen state
bool BodyTrackerWindow::on_window_state_event(GdkEventWindowState* event)
{
	m_is_fullscreen = (event->new_window_state & GDK_WINDOW_STATE_FULLSCREEN) == GDK_WINDOW_STATE_FULLSCREEN;
	return true;
}

//
// Window interaction
//
void BodyTrackerWindow::on_fullscreen_button_clicked()
{
	if(m_is_fullscreen)
		this->unfullscreen();
	else
		this->fullscreen();
}

bool BodyTrackerWindow::on_window_button_press_event(GdkEventButton* event)
{
	if((event->type == GDK_BUTTON_PRESS) && (event->button == 1)) {
		// Clicking anywhere on the window initiates a window drag
		begin_move_drag(event->button, event->x_root, event->y_root, event->time);
		return true;	// handled
	}
	else if((event->type == GDK_2BUTTON_PRESS) && (event->button == 1)) {
		if(!m_is_fullscreen) {
			this->fullscreen();
		}
	}
	return false;		// not handled
}

void BodyTrackerWindow::on_first_human_number_spinbutton_changed()
{
	m_first_human_number = m_first_human_number_spinbutton.get_value_as_int();
	if(m_first_human_number > m_last_human_number)
		m_last_human_number_spinbutton.set_value(m_first_human_number);

	m_body_tracker->set_max_humans((m_last_human_number - m_first_human_number) + 1);
	m_body_tracker->set_human_number_offset(m_first_human_number - 1);

	update_window_title();
}

void BodyTrackerWindow::on_last_human_number_spinbutton_changed()
{
	m_last_human_number = m_last_human_number_spinbutton.get_value_as_int();
	if(m_last_human_number < m_first_human_number)
		m_first_human_number_spinbutton.set_value(m_last_human_number);

	m_body_tracker->set_max_humans((m_last_human_number - m_first_human_number) + 1);

	update_window_title();
}

bool BodyTrackerWindow::on_drawing_area_button_press_event(GdkEventButton* event)
{
	if((event->type == GDK_BUTTON_PRESS) && (event->button == 1)) {
		begin_move_drag(event->button, event->x_root, event->y_root, event->time);
		return true;	// handled
	}
	return false;	// not handled
}

void BodyTrackerWindow::on_broadcast_changed()
{
	g_message_bus->set_broadcast(m_broadcast_button.get_active());
}

//
// Drawing
//
void BodyTrackerWindow::trigger_redraw()
{
	m_drawing_area.trigger_redraw();
}

bool BodyTrackerWindow::on_drawing_area_expose_event(GdkEventExpose* event)
{
	draw();
	return true;	// handled
}

//
// Update Tracking
//
void BodyTrackerWindow::update()
{
	m_body_tracker->update();
}

//
// Rendering
//
void BodyTrackerWindow::draw()
{
	m_drawing_area.gl_begin();
	m_body_tracker->draw();
	m_drawing_area.gl_end();
}

//
// Send OSC
//
void BodyTrackerWindow::send()
{
	m_body_tracker->send();
}

//
// Closing Window, Quiting
//
bool BodyTrackerWindow::on_delete_event(GdkEventAny *event)
{
	m_quit_dialog->show();
	return true;
}

void BodyTrackerWindow::on_quit_dialog_response(int response_id)
{
	if(response_id == TRUE) {
		hide();
		g_time_to_quit = true;
	}
	m_quit_dialog->hide();
}

BodyTrackerWindow::~BodyTrackerWindow()
{
}
