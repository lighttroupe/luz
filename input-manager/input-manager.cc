#include <gtkmm.h>
#include <unique/unique.h>

#include "input-manager.h"
#include "input-manager-window.h"
#include "message-bus.h"

#define APPLICATION_NAME ("Luz Input Manager")
#define UNIQUE_APP_GUID ("org.openanswers.luz-input-manager")

#define RC_FILE_PATH ("input-manager.rc")

#define PNG_ICON_FILE_PATH ("input-manager-status-icon.png")
#define SVG_ICON_FILE_PATH ("input-manager-icon.svg")

MessageBus* g_message_bus = NULL;

// Global helper functions
void send_float_packet(const char* address, float value)
{
	g_message_bus->send_float(address, value);
}

void send_int_packet(const char* address, int value)
{
	g_message_bus->send_int(address, value);
}

// Callback gets called when another instance tries to start and finds us already running
UniqueResponse unique_app_callback(UniqueApp *app, gint command, UniqueMessageData *message_data, guint time_, gpointer user_data)
{
	((InputManagerWindow*)user_data)->present();
}

InputManagerWindow* g_input_manager_window = NULL;		// just a hack for easy access in this callback
bool on_tooltip_button_press_event(GdkEventButton* event)
{
	if(g_input_manager_window->is_visible()) {
		g_input_manager_window->hide();
	}
	else {
		g_input_manager_window->present();
	}
}

int main(int argc, char *argv[])
{
	chdir("input-manager");		// HACK: this lets us be run from the base luz directory (fails if already in the input-manager directory)

	Gtk::RC::add_default_file(RC_FILE_PATH);
	Gtk::Main app(argc, argv);
	Gtk::Window::set_default_icon_from_file(SVG_ICON_FILE_PATH);

	//
	// Unique Application support
	//
	UniqueApp* unique_app = unique_app_new(UNIQUE_APP_GUID, NULL);
	if(unique_app_is_running(unique_app)) {
		printf("%s is already running!\n", APPLICATION_NAME);
		unique_app_send_message(unique_app, UNIQUE_ACTIVATE, NULL);
		return 1;
	}

	//
	g_message_bus = new MessageBus();

	input_init();
#ifdef SUPPORT_JOYSTICK
	joystick_init();
#endif

	//
	// Main Window
	//
	InputManagerWindow* input_manager_window = new InputManagerWindow();
	g_input_manager_window = input_manager_window;
	input_manager_window->show_all();

	//
	// Status Icon
	//
	Glib::RefPtr<Gtk::StatusIcon> icon = Gtk::StatusIcon::create_from_file(PNG_ICON_FILE_PATH);
	icon->set_tooltip_text(APPLICATION_NAME);
	icon->set_visible();
	icon->signal_button_press_event().connect(sigc::ptr_fun(&on_tooltip_button_press_event));

	// listen for messages from any future attempts to start this app
	g_signal_connect(unique_app, "message-received", G_CALLBACK(unique_app_callback), input_manager_window);

	// silence libwiimote noise on stderr (when a wiimote goes missing)
	fclose(stderr);		// TODO: remove this when we can cleanly handle a lost wiimote

	Gtk::Main::run();

	delete input_manager_window;
	return 0;
}
