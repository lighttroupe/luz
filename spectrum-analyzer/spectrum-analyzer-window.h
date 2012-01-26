#include <gtkmm.h>
#include <gtkmm/window.h>

#include <vector>
using namespace std;

#include "my-drawing-area.h"
#include "audio-sampler.h"
#include "filter.h"

class SpectrumAnalyzerWindow : public Gtk::Window
{
public:
	SpectrumAnalyzerWindow();
	virtual ~SpectrumAnalyzerWindow();

	void set_audio_sampler(AudioSampler* pAudioSampler) { m_audio_sampler = pAudioSampler; };
	bool on_drawing_area_expose_event(GdkEventExpose* event);
	void trigger_redraw();
	bool update();

	gint m_spectrum_analyzer_number;

	bool on_motion_notify_event(GdkEventMotion* event);
	void on_spectrum_analyzer_number_spinbox_changed();
	void update_window_title();
	void on_fullscreen_button_clicked();

	bool on_window_button_press_event(GdkEventButton* event);

private:
	Gtk::VBox m_window_vbox;
	Gtk::HBox m_toolbar;
	Gtk::CheckButton m_broadcast_button;
	Gtk::SpinButton m_spectrum_analyzer_number_spinbutton;
	Gtk::Button m_fullscreen_button;
	Gtk::Dialog* m_quit_dialog;

	MyDrawingArea m_drawing_area;
	AudioSampler* m_audio_sampler;

	vector<Filter*> m_filters;

	virtual bool on_drawing_area_button_press_event(GdkEventButton* event);
	bool on_window_state_event(GdkEventWindowState* event);
	void on_quit_dialog_response(int response_id);
	void draw();

	void on_broadcast_changed();

	bool on_delete_event(GdkEventAny *event);
	bool m_is_fullscreen;
};
