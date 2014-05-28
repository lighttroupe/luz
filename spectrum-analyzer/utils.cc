#include <gtkmm.h>
#include <math.h>
#include <GL/gl.h>

float average_of_floats(const float* floats, int count)
{
	int i;
	float total = 0.0;
	for(i=0 ; i<count ; i++) {
		total += fabs(floats[i]);
	}
	return total / count;
}

float clamp(float value, float min, float max)
{
	if(value < min) {
		return min;
	}
	else if(value > max) {
		return max;
	}
	return value;
}

// Checks if a->b overlaps c->d
float overlap_2D(float a, float b, float c, float d)
{
	if(a >= d || b <= c)
		return 0.0;

	if(a < c) {
		if(b < d) {
			return b - c;
		}
		else {
			return d - c;
		}
	}
	else {
		if(b < d) {
			return b - a;
		}
		else {
			return d - a;
		}
	}
}

void render_unit_square()
{
	glVertex2f(-0.5, 0.5);
	glVertex2f( 0.5, 0.5);
	glVertex2f( 0.5, -0.5);
	glVertex2f(-0.5, -0.5);
}
