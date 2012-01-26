#include <math.h>
#include "utils.h"

float calculate_angle(XnPoint3D& joint, XnPoint3D& joint2, XnPoint3D& joint3)
{
	JointVector om;
	JointVector oa;

	om.x = joint.X - joint2.X;
	om.y = joint.Y - joint2.Y;
	om.z = joint.Z - joint2.Z;

	oa.x = joint3.X - joint2.X;
	oa.y = joint3.Y - joint2.Y;
	oa.z = joint3.Z - joint2.Z;

	double v1_magnitude = sqrt(om.x * om.x + om.y * om.y + om.z * om.z);
	double v2_magnitude = sqrt(oa.x * oa.x + oa.y * oa.y + oa.z * oa.z);

	om.x = om.x / v1_magnitude;
	om.y = om.y / v1_magnitude;
	om.z = om.z / v1_magnitude;
	oa.x = oa.x / v2_magnitude;
	oa.y = oa.y / v2_magnitude;
	oa.z = oa.z / v2_magnitude;

	double theta = acos(om.x*oa.x + om.y*oa.y + om.z * oa.z);
	double angle_in_degrees = theta * 180 / PI;

	return (1.0 - (angle_in_degrees / 180.0));	// angle_zero_to_one
}

float scale_and_expand_limits(float value, TLimits* limits, float starting_width)
{
	if(!limits->init) {
		limits->min = value - (starting_width / 2.0);
		limits->max = value + (starting_width / 2.0);
		limits->init = true;
		return 0.0;		// no reasonable value to return until we know a range
	}

	if(value < limits->min)
		limits->min = value;

	if(value > limits->max)
		limits->max = value;

	float range = (limits->max - limits->min);

	if(range == 0.0)
		return 0.0;

	return (float)(value - limits->min) / (float)range;
}

unsigned int get_closest_power_of_two(unsigned int n)
{
	unsigned int m = 2;
	while(m < n) m <<= 1;
	return m;
}

void draw_string(void *font, char *str)
{
	char c, *p = str;
	while((c = *str++) != '\0') {
		glutBitmapCharacter(font, c);
	}
}

void draw_circle(float x, float y, float radius)
{
	static const int circle_points = 100;
	static const float angle_per_point = (2.0f * 3.1416f / circle_points);

	glBegin(GL_POLYGON);
		for(int i=0 ; i<circle_points+1 ; i++) {
			glVertex2d(x + radius * cos(angle_per_point * i), y + radius * sin(angle_per_point * i));
		}
	glEnd();
}

GLuint init_texture(void** buf, int& width, int& height)
{
	GLuint texID = 0;
	glGenTextures(1, &texID);

	width = get_closest_power_of_two(width);
	height = get_closest_power_of_two(height);
	*buf = new unsigned char[width*height*4];
	glBindTexture(GL_TEXTURE_2D, texID);

	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

	return texID;
}
