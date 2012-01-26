#include "filter.h"

#include <GL/gl.h>	// Header File For The OpenGL32 Library
#include <math.h>

#define MIN_WIDTH (0.05)
#define MAX_WIDTH (1.0)
#define MIN_HEIGHT (0.05)
#define MAX_HEIGHT (1.0)

#include "utils.h"

Filter::Filter(float x, float y, char* name, float r, float g, float b)
{
	m_x = x;
	m_y = y;

	m_red = r;
	m_green = g;
	m_blue = b;

	m_name = name;

	m_width = 0.15;
	m_height = 0.15;
	m_hover = false;

	m_grabbed_move = false;
	m_grabbed_up = false;
	m_grabbed_down = false;
	m_grabbed_right = false;
	m_grabbed_left = false;


	m_activation = 0.0;
	m_previous_activation = 0.0;
}

Filter::~Filter()
{

}

void Filter::Render(void)
{
	glPushMatrix();

	// Position and scale filter so the drawing code can pretend it's always 1x1
	glTranslatef(m_x, m_y, 0.0);
		glPushMatrix();
			glScalef(m_width, m_height, 1.0);

			// Background
			glBlendFunc(GL_SRC_ALPHA, GL_ONE);		// additive
			glColor4f(m_red, m_green, m_blue, 0.6);
			glBegin(GL_QUADS);
				render_unit_square();
			glEnd();

			// Border
			glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
			glColor4f(1.0, 1.0, 1.0, 0.2);
			glBegin(GL_LINE_LOOP);
				render_unit_square();
			glEnd();

			// Quadrant lines
			if(m_hover) {
				glBegin(GL_LINES);
					glVertex2f(0.0, -0.5); glVertex2f(0, 0.5);
					glVertex2f(-0.5, 0.0); glVertex2f(0.5, 0.0);
				glEnd();
			}
		glPopMatrix();

		// Here we are centered on the filter but not scaled, so we have pixel precision
		//glTranslatef((filter->width / 2.0) + 0.012, 0.0, 0.0);

		// Draw Activation bar
		float half_height = (m_height / 2.0);
		float half_width = (m_width / 2.0);

//		glLineWidth(8.0);
		glBegin(GL_QUADS);
			glColor4f(0.0, 0.0, 0.0, 0.9);
			glVertex3f(half_width * -0.333, (-half_height * 0.333), 0.0);
			glVertex3f(half_width * 0.333,  (-half_height * 0.333), 0.0);
			glVertex3f(half_width * 0.333,  (-half_height + (m_height)) * 0.333, 0.0);
			glVertex3f(half_width * -0.333, (-half_height + (m_height)) * 0.333, 0.0);

			glColor4f(1.0, 1.0, 1.0, 0.8);
			glVertex3f(half_width * -0.333, (-half_height * 0.333), 0.0);
			glVertex3f(half_width * 0.333,  (-half_height * 0.333), 0.0);
			glVertex3f(half_width * 0.333,  (-half_height + (m_height * m_activation)) * 0.333, 0.0);
			glVertex3f(half_width * -0.333, (-half_height + (m_height * m_activation)) * 0.333, 0.0);
		glEnd();
//		glLineWidth(1.0);
	glPopMatrix();
}

bool Filter::Update(float* bar_magnitudes, int num_bars)
{
	float x1 = 0.5+m_x - m_width / 2.0;
	float y1 = 0.5+m_y - m_height / 2.0;
	float x2 = 0.5+m_x + m_width / 2.0;
	float y2 = 0.5+m_y + m_height / 2.0;

	float width_per_bar = 1.0 / (float)num_bars;

	float total_area_covered = 0.0;
	int i;
	for(i=0 ; i<num_bars ; i++) {
		total_area_covered += (overlap_2D(x1, x2, width_per_bar * i, width_per_bar * (i+1)) * overlap_2D(y1, y2, 0.0, bar_magnitudes[i]));
	}
	m_previous_activation = m_activation;
	m_activation = total_area_covered / this->Area();

	return (m_activation != m_previous_activation);
}

float Filter::Area()
{
	return (m_width * m_height);
}

float Filter::GetActivation()
{
	return m_activation;
}

char* Filter::GetName()
{
	return m_name;
}

bool Filter::PointerPress(int button, float x, float y)
{
	if(m_hover == false)
		return false;

	// Center square (or second/third mouse button) is a drag
	if(button != 1 || (fabs((float)m_x - (float)x) < (m_width / 6.0)) && (fabs((float)m_y - (float)y) < (m_height / 6.0))) {
		m_grabbed_move = true;
	}
	else {
		m_grabbed_right = (x > m_x);
		m_grabbed_left = !m_grabbed_right;
		m_grabbed_down = (y < m_y);
		m_grabbed_up = !m_grabbed_down;
	}
	return true;
}

void Filter::PointerMovement(float x, float y, float delta_x, float delta_y)
{
	if(m_grabbed_move) {
		m_x = clamp(m_x + delta_x, -0.5 + (m_width / 2.0), 0.5 - m_width / 2.0);
		m_y = clamp(m_y + delta_y, -0.5 + (m_height / 2.0), 0.5 - m_height / 2.0);
	}

	if(m_grabbed_right) {
		m_width = clamp(m_width + delta_x, MIN_WIDTH, MAX_WIDTH);
		m_x = clamp(m_x + (delta_x / 2.0), -0.5 + (m_width / 2.0), 0.5 - m_width / 2.0);
	}
	else if(m_grabbed_left) {
		m_width = clamp(m_width - delta_x, MIN_WIDTH, MAX_WIDTH);
		m_x = clamp(m_x + (delta_x / 2.0), -0.5 + (m_width / 2.0), 0.5 - m_width / 2.0);
	}

	if(m_grabbed_up) {
		m_height = clamp(m_height + delta_y, MIN_HEIGHT, MAX_HEIGHT);
		m_y = clamp(m_y + (delta_y / 2.0), -0.5 + (m_height / 2.0), 0.5 - m_height / 2.0);
	}
	else if(m_grabbed_down) {
		m_height = clamp(m_height - delta_y, MIN_HEIGHT, MAX_HEIGHT);
		m_y = clamp(m_y + (delta_y / 2.0), -0.5 + (m_height / 2.0), 0.5 - m_height / 2.0);
	}

	m_hover = HitTest(x, y);
}

bool Filter::HitTest(float x, float y)
{
	return ((fabs((float)m_x - (float)x) < (m_width / 2.0)) && (fabs((float)m_y - (float)y) < (m_height / 2.0)));
}

void Filter::PointerRelease(int button, float x, float y)
{
	m_grabbed_move = false;
	m_grabbed_up = false;
	m_grabbed_down = false;
	m_grabbed_right = false;
	m_grabbed_left = false;
}
