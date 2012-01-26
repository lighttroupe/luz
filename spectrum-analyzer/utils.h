#ifndef __UTILS__H__
#define __UTILS_H__

void render_unit_square();
float clamp(float value, float min, float max);
float overlap_2D(float a, float b, float c, float d);
float average_of_floats(const float* floats, int count);

#endif
