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
	Glib::RefPtr<Gdk::GL::Window> glwindow = get_gl_window();
	glwindow->gl_begin(get_gl_context());

	Gtk::Allocation allocation = get_allocation();
	int width = allocation.get_width();
	int height = allocation.get_height();

	// Default options
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glClearColor(0.05, 0.05, 0.05, 1.0);

	// Default view
	glViewport(0, 0, width, height);

	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	gluPerspective(90.0f, (GLfloat)width/(GLfloat)height, 0.1f, 100.0f);	// Calculate The Aspect Ratio Of The Window
	gluLookAt(
		0.0, 0.0, 0.5,		// position
		0.0, 0.0, 0.0,		// looking at
		0.0, 1.0, 0.0			// up
	);

	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();

	// Rendering should fill screen/window completely, regardless of dimensions
	glScalef((float)width / (float)height, 1.0, 1.0);

	glwindow->gl_end();

	return true;
}
