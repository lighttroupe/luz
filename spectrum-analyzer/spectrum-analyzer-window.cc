#define WINDOW_TITLE ("Luz Spectrum Analyzer %02d")

#include <gtkglmm.h>
#include <gtkmm/gl/widget.h>

#include "spectrum-analyzer.h"
#include "spectrum-analyzer-window.h"

#define MIN_DEVICE_NUMBER (1)
#define MAX_DEVICE_NUMBER (100)

#define WINDOW_MINIMUM_WIDTH (420)
#define MSG_ENABLE_BROADCAST ("Send to Network")
#define MSG_CONFIRM_QUIT ("Confirm Quit?")

static void render_grid(int horizontal, int vertical)
{
	int i;

	glColor4f(0.2, 0.2, 0.2, 1.0);
	glPushMatrix();
		glTranslatef(-0.5f, -0.5f, 0.0f);		// Put 0.0 in bottom left corner
		glEnable(GL_LINE_STIPPLE);
		glLineStipple(2, 0x0F0F);

		glBegin(GL_LINES);
		for(i=0 ; i<horizontal ; i++) {
			glVertex3f(0.0, (float)i / (float)horizontal, 0.0);
			glVertex3f(1.0, (float)i / (float)horizontal, 0.0);
		}
		for(i=0 ; i<vertical ; i++) {
			glVertex3f((float)i / (float)vertical, 0.0, 0.0);
			glVertex3f((float)i / (float)vertical, 1.0, 0.0);
		}
		glEnd();
		glDisable(GL_LINE_STIPPLE);
	glPopMatrix();
}

static void render_samples(float* bar_heights, int count)
{
	int i;

	glPushMatrix();
		glTranslatef(-0.5f, -0.5f, 0.0f);		// Put 0.0 in bottom left corner

		glBegin(GL_QUADS);
		for(i=0 ; i<count ; i++) {
			float x1 = (GLfloat)i/(GLfloat)count;
			float y1 = bar_heights[i];

			float x2 = (GLfloat)(i+1)/(GLfloat)count;
			float y2 = 0.0;

			glColor4f(0.5, 0.5, 0.5, 0.4);
			glVertex3f(x2, y1, 0.0);
			glVertex3f(x2, y2, 0.0);

			glColor4f(0.5, 0.5, 0.5, 0.8);
			glVertex3f(x1, y2, 0.0);
			glVertex3f(x1, y1, 0.0);
		}
		glEnd();
	glPopMatrix();
}

SpectrumAnalyzerWindow::SpectrumAnalyzerWindow()
	: m_window_vbox(),
		m_spectrum_analyzer_number_spinbutton(),
		m_fullscreen_button(),
		m_toolbar(),
		m_filters(),
		m_spectrum_analyzer_number(1),
		m_broadcast_button(MSG_ENABLE_BROADCAST),
		m_is_fullscreen(false)
{
	m_quit_dialog = new Gtk::Dialog(MSG_CONFIRM_QUIT, *this);
	m_quit_dialog->add_button(Gtk::StockID("gtk-cancel"), FALSE);
	m_quit_dialog->add_button(Gtk::StockID("gtk-quit"), TRUE);
	m_quit_dialog->set_default_response(FALSE);
	m_quit_dialog->signal_response().connect(sigc::mem_fun(*this, &SpectrumAnalyzerWindow::on_quit_dialog_response));

	m_filters.push_back(new Filter(-0.375, 0.41, (char*)"Red", 1.0, 0.0, 0.0));
	m_filters.push_back(new Filter(-0.125, 0.41, (char*)"Green", 0.0, 1.0, 0.0));
	m_filters.push_back(new Filter( 0.125, 0.41, (char*)"Blue", 0.0, 0.0, 1.0));
	m_filters.push_back(new Filter( 0.375, 0.41, (char*)"Yellow", 1.0, 1.0, 0.0));

	update_window_title();
	set_border_width(0);
	set_resizable(true);

	m_toolbar.set_size_request(WINDOW_MINIMUM_WIDTH,-1);		// this creates a reasonable minimum window width

	// One vbox to rule them all
	m_window_vbox.set_spacing(0);		// aesthetics
	add(m_window_vbox);

	// Window dragging (in usused space)
	add_events(Gdk::BUTTON_PRESS_MASK);
	signal_button_press_event().connect(sigc::mem_fun(*this, &SpectrumAnalyzerWindow::on_window_button_press_event));

	//
	// Toolbar is the first item in vbox
	//
	m_toolbar.set_spacing(STANDARD_WIDGET_SPACING);
	m_toolbar.set_border_width(0);		// http://en.wikipedia.org/wiki/Fitts's_law

		// Toolbar: Spectrum Analyzer Number Spinbutton
		m_spectrum_analyzer_number_spinbutton.set_tooltip_text("Spectrum Analyzer Number");
		m_spectrum_analyzer_number_spinbutton.set_range((float)MIN_DEVICE_NUMBER, (float)MAX_DEVICE_NUMBER);
		m_spectrum_analyzer_number_spinbutton.set_increments(1.0, 1.0);
		m_spectrum_analyzer_number_spinbutton.set_value(m_spectrum_analyzer_number);
		m_toolbar.pack_start(m_spectrum_analyzer_number_spinbutton, false, true);		// booleans mean: expand and fill extra space
		m_spectrum_analyzer_number_spinbutton.signal_value_changed().connect(
			sigc::mem_fun(*this, &SpectrumAnalyzerWindow::on_spectrum_analyzer_number_spinbox_changed)
		);

		// Toolbar: spacer to push furth items to the far right
		Gtk::Label* spacer = new Gtk::Label();
		m_toolbar.pack_start(*spacer, true, true);		// booleans mean: expand and fill extra space

		// Toolbar: Broadcast Togglebutton
		m_broadcast_button.set_mode(true);		// draw_indicator=true, makes it a checkbutton (brilliant API here...)
		m_broadcast_button.signal_clicked().connect(sigc::mem_fun(*this, &SpectrumAnalyzerWindow::on_broadcast_changed));
		m_toolbar.pack_start(m_broadcast_button, false, false);

		// Toolbar: Fullscreen Button
		m_fullscreen_button.set_tooltip_text("Toggle Fullscreen");
		m_fullscreen_button.set_image(*(new Gtk::Image(Gtk::Stock::FULLSCREEN, *(new Gtk::IconSize(Gtk::ICON_SIZE_SMALL_TOOLBAR)))));
		m_fullscreen_button.set_relief(Gtk::RELIEF_NONE);
		m_toolbar.pack_start(m_fullscreen_button, false, true);		// booleans mean: expand and fill extra space
		m_fullscreen_button.signal_clicked().connect(sigc::mem_fun(*this, &SpectrumAnalyzerWindow::on_fullscreen_button_clicked));

	m_window_vbox.pack_start(m_toolbar, false, false);

	//
	// DrawingArea
	//
	m_drawing_area.set_size_request(256, 256);
	m_window_vbox.pack_start(m_drawing_area, true, true);

	m_drawing_area.signal_expose_event().connect(sigc::mem_fun(*this, &SpectrumAnalyzerWindow::on_drawing_area_expose_event), false);

	m_drawing_area.add_events(Gdk::POINTER_MOTION_MASK);
	m_drawing_area.signal_motion_notify_event().connect(sigc::mem_fun(*this, &SpectrumAnalyzerWindow::on_motion_notify_event), false);

	m_drawing_area.add_events(Gdk::BUTTON_PRESS_MASK);
	m_drawing_area.signal_button_press_event().connect(sigc::mem_fun(*this, &SpectrumAnalyzerWindow::on_drawing_area_button_press_event), false);

	m_drawing_area.add_events(Gdk::BUTTON_RELEASE_MASK);
	m_drawing_area.signal_button_release_event().connect(sigc::mem_fun(*this, &SpectrumAnalyzerWindow::on_drawing_area_button_press_event), false);
}

bool SpectrumAnalyzerWindow::on_window_state_event(GdkEventWindowState* event)
{
	m_is_fullscreen = (event->new_window_state & GDK_WINDOW_STATE_FULLSCREEN) == GDK_WINDOW_STATE_FULLSCREEN;
	return true;
}

void SpectrumAnalyzerWindow::on_fullscreen_button_clicked()
{
	if(m_is_fullscreen)
		this->unfullscreen();
	else
		this->fullscreen();
}

void SpectrumAnalyzerWindow::on_spectrum_analyzer_number_spinbox_changed()
{
	m_spectrum_analyzer_number = m_spectrum_analyzer_number_spinbutton.get_value_as_int();
	update_window_title();
}

void SpectrumAnalyzerWindow::update_window_title()
{
	char buffer[201];
	snprintf(buffer, 200, WINDOW_TITLE, m_spectrum_analyzer_number);
	set_title(buffer);
}

bool SpectrumAnalyzerWindow::on_motion_notify_event(GdkEventMotion* event)
{
	static float last_x=0.0, last_y=0.0;

	Gtk::Allocation allocation = m_drawing_area.get_allocation();
	float x = ((float)event->x / (float)allocation.get_width()) - 0.5;
	float y = -(((float)event->y / (float)allocation.get_height()) - 0.5);

	vector<Filter*>::iterator itFilter = m_filters.begin();
	for(; itFilter < m_filters.end(); itFilter++) {
		Filter* filter = *itFilter;
		filter->PointerMovement(x, y, (x - last_x), (y - last_y));
	}

	last_x = x; last_y = y;
	return true;
}

bool SpectrumAnalyzerWindow::on_window_button_press_event(GdkEventButton* event)
{
	if((event->type == GDK_BUTTON_PRESS) && (event->button == 1)) {
		begin_move_drag(event->button, event->x_root, event->y_root, event->time);
		return true;	// handled
	}
	return false;	// not handled
}

bool SpectrumAnalyzerWindow::on_drawing_area_button_press_event(GdkEventButton* event)
{
	Gtk::Allocation allocation = m_drawing_area.get_allocation();

	vector<Filter*>::iterator itFilter = m_filters.begin();
	if(event->type == GDK_BUTTON_PRESS) {
		for(; itFilter < m_filters.end(); itFilter++) {
			Filter* filter = *itFilter;
			if(filter->PointerPress(event->button, ((float)event->x / (float)allocation.get_width()) - 0.5, -(((float)event->y / (float)allocation.get_height()) - 0.5)))
				break;
		}
		return true;
	}
	else if(event->type == GDK_BUTTON_RELEASE) {
		for(; itFilter < m_filters.end(); itFilter++) {
			Filter* filter = *itFilter;
			filter->PointerRelease(event->button, ((float)event->x / (float)allocation.get_width()) - 0.5, -(((float)event->y / (float)allocation.get_height()) - 0.5));
		}
		return true;
	}
	else {
		return false;
	}
}

bool SpectrumAnalyzerWindow::on_drawing_area_expose_event(GdkEventExpose* event)
{
	draw();
	return true;
}

void SpectrumAnalyzerWindow::draw()
{
	m_drawing_area.gl_begin();

	glClear(GL_COLOR_BUFFER_BIT);

	render_samples(m_audio_sampler->GetMagnitudeArray(), m_audio_sampler->GetMagnitudeCount());
	render_grid(NUM_HORIZONTAL_LINES, NUM_VERTICAL_LINES);

	// Render boxes
	vector<Filter*>::iterator itFilter = m_filters.begin();
	for(; itFilter < m_filters.end(); itFilter++) {
		Filter* filter = *itFilter;
		filter->Render();
	}

	m_drawing_area.gl_end();
}

#define ADDRESS_BUFFER_SIZE (200)

bool SpectrumAnalyzerWindow::update()
{
	char address_buffer[ADDRESS_BUFFER_SIZE+1];

	vector<Filter*>::iterator itFilter = m_filters.begin();
	for(; itFilter < m_filters.end(); itFilter++) {
		Filter* filter = *itFilter;

		// Update returns 'true' if activation value changed
		if(filter->Update(m_audio_sampler->GetMagnitudeArray(), m_audio_sampler->GetMagnitudeCount())) {
			snprintf(address_buffer, ADDRESS_BUFFER_SIZE, "Spectrum Analyzer %02d / %s", m_spectrum_analyzer_number, filter->GetName());
			send_float_packet(address_buffer, filter->GetActivation());
		}
	}
	return true;
}

void SpectrumAnalyzerWindow::trigger_redraw()
{
	m_drawing_area.trigger_redraw();
}

void SpectrumAnalyzerWindow::on_broadcast_changed()
{
	g_message_bus->set_broadcast(m_broadcast_button.get_active());
}

bool SpectrumAnalyzerWindow::on_delete_event(GdkEventAny *event)
{
	m_quit_dialog->show();
	return true;
}

void SpectrumAnalyzerWindow::on_quit_dialog_response(int response_id)
{
	if(response_id == TRUE) {
		g_time_to_quit = true;
	}
	m_quit_dialog->hide();
}

SpectrumAnalyzerWindow::~SpectrumAnalyzerWindow()
{
}
