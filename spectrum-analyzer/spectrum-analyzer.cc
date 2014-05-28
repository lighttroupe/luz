#include "spectrum-analyzer.h"
#include "utils.h"
#include "filter.h"
#include "audio-sampler.h"

#include <glibmm/timer.h>

#include <math.h>
#include <vector>

using namespace std;    // saves us typing std:: before vector

#include <GL/gl.h>
#include <GL/glu.h>

#define APPLICATION_NAME ("Luz Spectrum Analyzer")
#define APPLICATION_VERSION ("0.31")

// liblo OpenSoundControl (http://liblo.sourceforge.net/)
#include <lo/lo.h>

#define UDP_PORT ("10007")		// LOOOZ :D
#define UDP_ADDRESS (NULL)		// ("255.255.255.255")

bool g_time_to_quit = false;

#include <gtkmm.h>

#include <gtkmm/gl/init.h>
#include <gtkmm/gl/widget.h>

#include "message-bus.h"
#include "spectrum-analyzer-window.h"

#define RC_FILE_PATH ("spectrum-analyzer.rc")
#define PNG_ICON_FILE_PATH ("spectrum-analyzer-status-icon.png")
#define SVG_ICON_FILE_PATH ("spectrum-analyzer-icon.svg")

//
// Globals
//
MessageBus* g_message_bus = NULL;

SpectrumAnalyzerWindow* g_spectrum_analyzer_window = NULL;

//
// Global helper functions
//
void send_float_packet(const char* address, float value)
{
	g_message_bus->send_float(address, value);
}

void send_int_packet(const char* address, int value)
{
	g_message_bus->send_int(address, value);
}

//
// Callbacks
//
bool on_tooltip_button_press_event(GdkEventButton* event)
{
	if(g_spectrum_analyzer_window->is_visible()) {
		g_spectrum_analyzer_window->hide();
	}
	else {
		g_spectrum_analyzer_window->present();
	}
}

int main(int argc, char *argv[])
{
	chdir("spectrum-analyzer");		// HACK: this lets us be run from the base luz directory (fails if already in the spectrum-analyzer directory)

	Gtk::RC::add_default_file(RC_FILE_PATH);
	Gtk::Main app(argc, argv);
	Gtk::GL::init(argc, argv);
	Gtk::Window::set_default_icon_from_file(SVG_ICON_FILE_PATH);

	//
	// Message Bus
	//
	g_message_bus = new MessageBus();

	//
	// Audio Sampler
	//
	AudioSampler* pAudioSampler = new AudioSampler();
	pAudioSampler->Open(NULL);		// NULL = default device (runtime-changeable in pavucontrol app)

	//
	// Main Window
	//
	g_spectrum_analyzer_window = new SpectrumAnalyzerWindow();
	g_spectrum_analyzer_window->show_all();
	g_spectrum_analyzer_window->set_audio_sampler(pAudioSampler);

	//
	// Status Icon
	//
	Glib::RefPtr<Gtk::StatusIcon> icon = Gtk::StatusIcon::create_from_file(PNG_ICON_FILE_PATH);
	icon->set_tooltip_text(APPLICATION_NAME);
	icon->set_visible();
	icon->signal_button_press_event().connect(sigc::ptr_fun(&on_tooltip_button_press_event));

	//
	// Main Loop
	//
	Glib::Timer* timer = new Glib::Timer();
	timer->start();

	double last_redraw_time = 0.0;
	double frame_time = 1.0 / 60.0;

	GMainLoop* p_main_loop = g_main_loop_new(NULL, false);
	while(g_time_to_quit == false) {
		pAudioSampler->Update();
		pAudioSampler->Analyze();

		double time = timer->elapsed();
		if((time - last_redraw_time) > frame_time) {
			g_spectrum_analyzer_window->update();
			g_spectrum_analyzer_window->trigger_redraw();
			last_redraw_time = time;
		}

		// Process entire Gtk+ event queue
		while(Gtk::Main::events_pending()) {
			Gtk::Main::iteration(false);		// false = don't block
		}
	}

	delete g_spectrum_analyzer_window;
	return 0;
}
