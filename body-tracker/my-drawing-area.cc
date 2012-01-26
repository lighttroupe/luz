#include "my-drawing-area.h"
#include <GL/glu.h>

MyDrawingArea::MyDrawingArea()
{
	Glib::RefPtr<Gdk::GL::Config> glconfig;
	glconfig = Gdk::GL::Config::create(Gdk::GL::MODE_RGB | Gdk::GL::MODE_DEPTH | Gdk::GL::MODE_DOUBLE);
	set_gl_capability(glconfig);
}

MyDrawingArea::~MyDrawingArea()
{
}

void MyDrawingArea::gl_begin()
{
	Glib::RefPtr<Gdk::GL::Window> glwindow = get_gl_window();
	glwindow->gl_begin(get_gl_context());
}

void MyDrawingArea::gl_end()
{
	Glib::RefPtr<Gdk::GL::Window> glwindow = get_gl_window();
	glwindow->gl_end();
	glwindow->swap_buffers();
}

void MyDrawingArea::trigger_redraw()
{
	get_window()->invalidate(true);
}

bool MyDrawingArea::on_configure_event(GdkEventConfigure* event)
{
	gl_begin();

	// Default view
	glViewport(0, 0, event->width, event->height);

	gl_end();

	return true;
}

