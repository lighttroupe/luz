#include <math.h>

#include "application.h"
#include "body-tracker-window.h"

//---------------------------------------------------------------------------
// Globals
//---------------------------------------------------------------------------
bool g_time_to_quit = false;

MessageBus* g_message_bus = NULL;
BodyTrackerWindow* g_body_tracker_window = NULL;

bool on_tooltip_button_press_event(GdkEventButton* event)
{
	if(g_body_tracker_window->is_visible()) {
		g_body_tracker_window->hide();
	}
	else {
		g_body_tracker_window->present();
	}
}

int main(int argc, char *argv[])
{
	chdir("body-tracker");

	Gtk::RC::add_default_file(RC_FILE_PATH);
	Gtk::Main app(argc, argv);
	Gtk::GL::init(argc, argv);
	Gtk::Window::set_default_icon_from_file(SVG_ICON_FILE_PATH);

	//
	// Message Bus
	//
	g_message_bus = new MessageBus();

	//
	// Status Icon
	//
	Glib::RefPtr<Gtk::StatusIcon> icon = Gtk::StatusIcon::create_from_file(PNG_ICON_FILE_PATH);
	icon->set_tooltip_text(APPLICATION_NAME);
	icon->set_visible();
	icon->signal_button_press_event().connect(sigc::ptr_fun(&on_tooltip_button_press_event));

	//
	// Main Window
	//
	g_body_tracker_window = new BodyTrackerWindow();
	g_body_tracker_window->show_all();

	glutInit(&argc, argv);

	glDisable(GL_DEPTH_TEST);		// we use Painter's Algorithm
	glEnable(GL_TEXTURE_2D);

	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

	glEnableClientState(GL_VERTEX_ARRAY);		// OpenNI drawing code uses vertex arrays

	Glib::Timer* timer = new Glib::Timer();
	timer->start();

	double frame_time = 1.0 / 30.0;
	double last_frame_time = 0.0;

	GMainLoop* p_main_loop = g_main_loop_new(NULL, false);
	
	
	while(g_time_to_quit == false) {
	
		double time = timer->elapsed();

		// has enough time elapsed?
		if((time - last_frame_time) > frame_time) {
			g_body_tracker_window->update();
			g_body_tracker_window->trigger_redraw();
			last_frame_time = time;

			// actual redraw happens in the Gtk callback
			while(Gtk::Main::events_pending()) {
				Gtk::Main::iteration(false);
			}

			g_body_tracker_window->send();
		}
		else {
			// sleep for a while to avoid spiking the CPU
			usleep(1000000.0 * (frame_time - (time - last_frame_time)));
		}
	}

	delete g_body_tracker_window;
	return 0;
}
