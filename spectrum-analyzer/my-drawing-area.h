#include <gtkmm.h>
#include <gtkmm/gl/drawingarea.h>

class MyDrawingArea : public Gtk::GL::DrawingArea
{
	public:
		MyDrawingArea();
		virtual ~MyDrawingArea();
		bool on_timer();

		void gl_begin();
		void gl_end();
		void trigger_redraw();

	protected:
		virtual bool on_configure_event(GdkEventConfigure* event);
};
