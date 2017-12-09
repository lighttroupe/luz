#ifdef SUPPORT_JOYSTICK
#include "input-joystick.h"
#include <stdio.h>
#include <stdlib.h>
#include <cstring>

#include "utils.h"

void joystick_init()
{
	SDL_Quit();
	SDL_Init(SDL_INIT_JOYSTICK);
}

int joystick_count()
{
	return SDL_NumJoysticks();
}

class InputJoystick;

InputJoystick* joystick_open_by_index(int index)
{
	return new InputJoystick(index);
}

InputJoystick::InputJoystick(int index)
{
	m_joystick = SDL_JoystickOpen(index);
	m_device_name = SDL_JoystickName(m_joystick);

	// axis
	m_axis_count = SDL_JoystickNumAxes(m_joystick);
	m_axis_values = (int*)calloc(m_axis_count, sizeof(int));
	m_axis_limits = (TLimits*)calloc(m_axis_count, sizeof(TLimits));		// 0 for min and max is fine for joystick axes

	// buttons
	m_button_count = SDL_JoystickNumButtons(m_joystick);
	m_button_values = (bool*)calloc(m_button_count, sizeof(bool));

	// hats
	m_hat_count = SDL_JoystickNumHats(m_joystick);
	m_hat_values = (Uint8*)calloc(m_hat_count, sizeof(Uint8));

	//printf("input-joystick: '%s' with %d axis, %d buttons, %d hats\n", m_device_name.c_str(), m_axis_count, m_button_count, m_hat_count);
}

const char* InputJoystick::device_type()
{
	return "Joystick";
}

const char* InputJoystick::device_name()
{
	return (const char*)(m_device_name.c_str());
}

bool InputJoystick::update()
{
	SDL_JoystickUpdate();		// NOTE: this shouldn't go here, won't work for 2+ joysticks..?

	//
	// Update buttons
	//
	for(int button_index=0; button_index<m_button_count ; button_index++) {
		if(SDL_JoystickGetButton(m_joystick, button_index) == SDL_PRESSED) {
			// Newly pressed?
			if(m_button_values[button_index] == false) {
				m_button_values[button_index] = true;

				send_integer(button_names[button_index + 1], 1);
			}
		}
		else {
			// Newly released?
			if(m_button_values[button_index] == true) {
				m_button_values[button_index] = false;

				send_integer(button_names[button_index + 1], 0);
			}
		}
	}

	//
	// Update axes
	//
	for(int axis_index=0; axis_index<m_axis_count ; axis_index++) {
		int axis_value = SDL_JoystickGetAxis(m_joystick, axis_index);

		// Moved?
		if(axis_value != m_axis_values[axis_index]) {
			float value = scale_and_expand_limits(axis_value, &(m_axis_limits[axis_index]));

			send_float(axis_names[axis_index + 1], value);

			m_axis_values[axis_index] = axis_value;		// NOTE: this saves the raw integer axis_value
		}
	}

	char address_buffer[50 + 1];

	//
	// Update hats
	//
	for(int hat_index=0; hat_index<m_hat_count ; hat_index++) {
		int hat_value = SDL_JoystickGetHat(m_joystick, hat_index);

		// Left
		if((hat_value & SDL_HAT_LEFT) != (m_hat_values[hat_index] & SDL_HAT_LEFT)) {
			snprintf(address_buffer, 50, "%s / Left", hat_names[hat_index + 1]);
			send_integer(address_buffer, (hat_value & SDL_HAT_LEFT) > 0);
		}

		// Right
		if((hat_value & SDL_HAT_RIGHT) != (m_hat_values[hat_index] & SDL_HAT_RIGHT)) {
			snprintf(address_buffer, 50, "%s / Right", hat_names[hat_index + 1]);
			send_integer(address_buffer, (hat_value & SDL_HAT_RIGHT) > 0);
		}

		// Up
		if((hat_value & SDL_HAT_UP) != (m_hat_values[hat_index] & SDL_HAT_UP)) {
			snprintf(address_buffer, 50, "%s / Up", hat_names[hat_index + 1]);
			send_integer(address_buffer, (hat_value & SDL_HAT_UP) > 0);
		}

		// Down
		if((hat_value & SDL_HAT_DOWN) != (m_hat_values[hat_index] & SDL_HAT_DOWN)) {
			snprintf(address_buffer, 50, "%s / Down", hat_names[hat_index + 1]);
			send_integer(address_buffer, (hat_value & SDL_HAT_DOWN) > 0);
		}

		// save
		m_hat_values[hat_index] = hat_value;
	}
	return true;
}

void InputJoystick::sleep()
{
	usleep(5 * 1000);
}

InputJoystick::~InputJoystick()
{
}
#endif
