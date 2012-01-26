#include "input-wiimote.h"
#include <stdio.h>
#include <unistd.h>		// for usleep()
#include <stdlib.h>		// for calloc

#include "utils.h"

//
// Buttons
//
static struct { int mask; const char* name; } g_wiimote_buttons[] = {
	{WIIMOTE_KEY_1, "1"},
	{WIIMOTE_KEY_2, "2"},
	{WIIMOTE_KEY_A, "A"},
	{WIIMOTE_KEY_B, "B"},
	{WIIMOTE_KEY_PLUS, "+"},
	{WIIMOTE_KEY_MINUS, "-"},
	{WIIMOTE_KEY_HOME, "Home"},	// ⌂
	{WIIMOTE_KEY_LEFT, "Left"},	// ◀
	{WIIMOTE_KEY_RIGHT, "Right"},	// ▶
	{WIIMOTE_KEY_UP, "Up"},	// ▲
	{WIIMOTE_KEY_DOWN, "Down"}	// ▼
};

InputWiimote::InputWiimote()
{
	// init wiimote structs, set to 0 (see WIIMOTE_INIT)
	m_p_wiimote = (wiimote_t*)calloc(sizeof(wiimote_t), 1);
	m_p_wiimote_old = (wiimote_t*)calloc(sizeof(wiimote_t), 1);
}

const char* InputWiimote::device_type()
{
	return "Wiimote";
}

const char* InputWiimote::device_name()
{
	return "Wiimote";
}

bool InputWiimote::scan()
{
	int tries = 2;
	while(tries-- > 0) {
		if(wiimote_discover(m_p_wiimote, (uint8_t)1) > 0) {
			if(wiimote_connect(m_p_wiimote, m_p_wiimote->link.r_addr) >= 0) {

				// Enable features
				m_p_wiimote->mode.acc = 1;
				m_p_wiimote->mode.ir = 1;		// HACK: enabling ir, even when we don't use it, seems to force certain shady wiimotes to send updates when otherwise it took firm shakes to see any data from them (confirmed in wmgui Jan 9 2010)

				return true;
			}
			else {
				// Connection error
				printf("Wiimote connection error!\n");
				return false;
			}
		}
	}
	return false;
}

bool InputWiimote::update()
{
	// Default LED state reflects the device number ("Wiimote 01" in Luz will have 1st bit set, "Wiimote 02" the second, etc.)
	m_p_wiimote->led.bits = 1 << (device_number()-1);
	m_p_wiimote->rumble = 0;

	if((!wiimote_is_open(m_p_wiimote)) || (wiimote_update(m_p_wiimote) == WIIMOTE_ERROR)) {
		wiimote_close(m_p_wiimote);
		return false;
	}

	//
	// Update Buttons
	//
	int i;
	for(i=0 ; i < (sizeof(g_wiimote_buttons) / sizeof(g_wiimote_buttons[0])) ; i++) {
		if((m_p_wiimote->keys.bits & g_wiimote_buttons[i].mask) != (m_p_wiimote_old->keys.bits & g_wiimote_buttons[i].mask)) {
			send_integer(g_wiimote_buttons[i].name, (m_p_wiimote->keys.bits & g_wiimote_buttons[i].mask) > 0 ? 1 : 0);
		}
	}

	//
	// Update Force
	//
	static TLimits force_x_limits = {10000,-10000};
	float force_x = scale_and_expand_limits(m_p_wiimote->axis.x, &force_x_limits);
	send_float("Force / X", force_x);

	static TLimits force_y_limits = {10000,-10000};
	float force_y = scale_and_expand_limits(m_p_wiimote->axis.y, &force_y_limits);
	send_float("Force / Z", force_y);		// NOTE: flipped y/z for Luz coordinate system

	static TLimits force_z_limits = {10000,-10000};
	float force_z = scale_and_expand_limits(m_p_wiimote->axis.z, &force_z_limits);
	send_float("Force / Y", force_z);		// NOTE: flipped y/z for Luz coordinate system

	//
	// Update Pitch
	//
	// Clamp to -1.0..1.0 g-force, because any more isn't a function of tilt but rather moving the Wiimote.
	float pitch = clamp_float(((float)(m_p_wiimote->axis.y - m_p_wiimote->cal.y_zero) / (float)(m_p_wiimote->cal.y_scale - m_p_wiimote->cal.y_zero)), -1.0, 1.0) ;
	pitch *= -1.0;		// We want positive values when Wiimote is vertical
	pitch += 1.0;			// -1.0..1.0 to 0.0..2.0
	pitch /= 2.0;			//  0.0..2.0 to 0.0..1.0
	send_float("Pitch", pitch);

	//
	// Update Roll
	//
	// Clamp to -1.0..1.0 g-force, because any more isn't a function of tilt but rather moving the Wiimote.
	float roll = clamp_float(((float)(m_p_wiimote->axis.x - m_p_wiimote->cal.x_zero) / (float)(m_p_wiimote->cal.x_scale - m_p_wiimote->cal.x_zero)), -1.0, 1.0) ;
	roll += 1.0;		// -1.0..1.0 to 0.0..2.0
	roll /= 2.0;		//  0.0..2.0 to 0.0..1.0
	send_float("Roll", roll);

	wiimote_copy(m_p_wiimote, m_p_wiimote_old);
	return true;
}

void InputWiimote::sleep()
{
	usleep(5 * 1000);
}

InputWiimote::~InputWiimote()
{
	if(wiimote_is_open(m_p_wiimote)) {
		wiimote_close(m_p_wiimote);
	}
}
