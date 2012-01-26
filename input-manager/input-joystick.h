#ifndef __INPUT_JOYSTICK_H__
#define __INPUT_JOYSTICK_H__

extern "C" {
	#include <SDL/SDL.h>
}

#include "input.h"

#include <vector>
#include <string>
using namespace std;

class InputJoystick;

void joystick_init();
int joystick_count();
InputJoystick* joystick_open_by_index(int index);

class InputJoystick : public Input
{
public:
	InputJoystick(int index);
	virtual ~InputJoystick();

	bool update();
	const char* device_type();
	const char* device_name();

	void sleep();

private:
	int m_axis_count;
	int *m_axis_values;
	TLimits *m_axis_limits;

	int m_button_count;
	bool *m_button_values;

	int m_hat_count;
	Uint8 *m_hat_values;

	SDL_Joystick* m_joystick;

	string m_device_name;
};

#endif
