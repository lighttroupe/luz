#ifdef SUPPORT_WIIMOTE
#include "input-wiimote.h"
#include <stdio.h>
#include <unistd.h>		// for usleep()
#include <stdlib.h>		// for calloc

#include "utils.h"

void wiimote_error_callback(cwiid_wiimote_t *wiimote, const char *s, va_list ap) {
	printf("%d:", wiimote ? cwiid_get_id(wiimote) : -1);
	vprintf(s, ap);
	printf("\n");
}

int g_device_number_to_leds[10] = {CWIID_LED1_ON, CWIID_LED2_ON, CWIID_LED3_ON, CWIID_LED4_ON, CWIID_LED1_ON|CWIID_LED4_ON, CWIID_LED2_ON|CWIID_LED4_ON, CWIID_LED3_ON|CWIID_LED4_ON, CWIID_LED1_ON|CWIID_LED3_ON|CWIID_LED4_ON, CWIID_LED2_ON|CWIID_LED3_ON|CWIID_LED4_ON, CWIID_LED1_ON|CWIID_LED2_ON|CWIID_LED3_ON|CWIID_LED4_ON};

//
// Buttons
//
static struct { int mask; const char* name; } g_wiimote_buttons[] = {
	{CWIID_BTN_1, "1"},
	{CWIID_BTN_2, "2"},
	{CWIID_BTN_A, "A"},
	{CWIID_BTN_B, "B"},
	{CWIID_BTN_PLUS, "+"},
	{CWIID_BTN_MINUS, "-"},
	{CWIID_BTN_HOME, "Home"},	// ⌂
	{CWIID_BTN_LEFT, "Left"},	// ◀
	{CWIID_BTN_RIGHT, "Right"},	// ▶
	{CWIID_BTN_UP, "Up"},	// ▲
	{CWIID_BTN_DOWN, "Down"}	// ▼
	// others: CWIID_NUNCHUK_BTN_Z, CWIID_NUNCHUK_BTN_C, CWIID_CLASSIC_BTN_UP, CWIID_CLASSIC_BTN_LEFT, CWIID_CLASSIC_BTN_ZR, CWIID_CLASSIC_BTN_X, CWIID_CLASSIC_BTN_A, CWIID_CLASSIC_BTN_Y, CWIID_CLASSIC_BTN_B, CWIID_CLASSIC_BTN_ZL, CWIID_CLASSIC_BTN_R, CWIID_CLASSIC_BTN_PLUS, CWIID_CLASSIC_BTN_HOME, CWIID_CLASSIC_BTN_MINUS, CWIID_CLASSIC_BTN_L, CWIID_CLASSIC_BTN_DOWN, CWIID_CLASSIC_BTN_RIGHT
};

InputWiimote::InputWiimote()
{
	m_old_buttons = 0;
	cwiid_set_err(wiimote_error_callback);
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
	bdaddr_t bdaddr = {0};			// bdaddr = *BDADDR_ANY;  <-- wasn't working
	unsigned char rpt_mode = CWIID_RPT_BTN | CWIID_RPT_ACC;

	if (!(m_p_wiimote = cwiid_open(&bdaddr, 0))) {
		return false;
	} else {
		//cwiid_set_led(m_p_wiimote, 0);
		cwiid_set_rpt_mode(m_p_wiimote, rpt_mode);
		return true;
	}
}

bool InputWiimote::update()
{
	struct cwiid_state state; /* wiimote state */

	// TODO set LED based on device_number()
	//printf("setting %d to %d", device_number(), g_device_number_to_leds[device_number()-1]);
	//cwiid_set_led(m_p_wiimote, g_device_number_to_leds[device_number()-1]);

	if (cwiid_get_state(m_p_wiimote, &state)) {
		// TODO: close
		return false;
	} else {
		//print_state(&state);
		//int rumble = 1; cwiid_set_rumble(m_p_wiimote, rumble);

		//
		// Update Buttons
		//
		int i;
		for(i=0 ; i < (sizeof(g_wiimote_buttons) / sizeof(g_wiimote_buttons[0])) ; i++) {
			if((state.buttons & g_wiimote_buttons[i].mask) != (m_old_buttons & g_wiimote_buttons[i].mask)) {
				send_integer(g_wiimote_buttons[i].name, (state.buttons & g_wiimote_buttons[i].mask) > 0 ? 1 : 0);
			}
		}
		m_old_buttons = state.buttons;

		//
		// Update Force
		//
		//static TLimits force_x_limits = {10000,-10000};
		//float force_x = scale_and_expand_limits(state.acc[CWIID_X], &force_x_limits);
		//send_float("Force / X", force_x);

		//static TLimits force_y_limits = {10000,-10000};
		//float force_y = scale_and_expand_limits(state.acc[CWIID_Y], &force_y_limits);
		//send_float("Force / Z", force_y);		// NOTE: flipped y/z for Luz coordinate system

		//static TLimits force_z_limits = {10000,-10000};
		//float force_z = scale_and_expand_limits(state.acc[CWIID_Z], &force_z_limits);
		//send_float("Force / Y", force_z);		// NOTE: flipped y/z for Luz coordinate system

		//
		// Update Pitch
		//
		// Clamp to -1.0..1.0 g-force, because any more isn't a function of tilt but rather moving the Wiimote.
		//float pitch = clamp_float(((float)(m_p_wiimote->axis.y - m_p_wiimote->cal.y_zero) / (float)(m_p_wiimote->cal.y_scale - m_p_wiimote->cal.y_zero)), -1.0, 1.0) ;
		//pitch *= -1.0;		// We want positive values when Wiimote is vertical
		//pitch += 1.0;			// -1.0..1.0 to 0.0..2.0
		//pitch /= 2.0;			//  0.0..2.0 to 0.0..1.0
		//send_float("Pitch", pitch);

		//printf("pitch: %f, tilt says: %f\n", pitch, m_p_wiimote->tilt.x);

		//
		// Update Roll
		//
		// Clamp to -1.0..1.0 g-force, because any more isn't a function of tilt but rather moving the Wiimote.
		//float roll = clamp_float(((float)(m_p_wiimote->axis.x - m_p_wiimote->cal.x_zero) / (float)(m_p_wiimote->cal.x_scale - m_p_wiimote->cal.x_zero)), -1.0, 1.0) ;
		//roll += 1.0;		// -1.0..1.0 to 0.0..2.0
		//roll /= 2.0;		//  0.0..2.0 to 0.0..1.0
		//send_float("Roll", roll);

		//printf("roll: %f, tilt says: %f", roll, tilt);

		//
		// Nunchuk
		//
		//static TLimits nunchuk_joystick_x_limits = {10000,-10000};
		//float joyx = scale_and_expand_limits(m_p_wiimote->ext.nunchuk.joyx, &nunchuk_joystick_x_limits);
		//send_float("Nunchuk / Joystick X", joyx);

		//static TLimits nunchuk_joystick_y_limits = {10000,-10000};
		//float joyy = scale_and_expand_limits(m_p_wiimote->ext.nunchuk.joyy, &nunchuk_joystick_y_limits);
		//send_float("Nunchuk / Joystick Y", joyy);

		//static int nunchuck_c_button = 0;
		//if(m_p_wiimote->ext.nunchuk.keys.c != nunchuck_c_button) {
			//nunchuck_c_button = m_p_wiimote->ext.nunchuk.keys.c;
			//send_integer("Nunchuk / C", nunchuck_c_button);
		//}
		//static int nunchuck_z_button = 0;
		//if(m_p_wiimote->ext.nunchuk.keys.z != nunchuck_z_button) {
			//nunchuck_z_button = m_p_wiimote->ext.nunchuk.keys.z;
			//send_integer("Nunchuk / Z", nunchuck_z_button);
		//}

		//static TLimits nunchuk_force_x_limits = {10000,-10000};
		//float nunchuk_force_x = scale_and_expand_limits(m_p_wiimote->ext.nunchuk.axis.x, &nunchuk_force_x_limits);
		//send_float("Nunchuk / Force / X", nunchuk_force_x);
	//
		//static TLimits nunchuk_force_y_limits = {10000,-10000};
		//float nunchuk_force_y = scale_and_expand_limits(m_p_wiimote->ext.nunchuk.axis.y, &nunchuk_force_y_limits);
		//send_float("Nunchuk / Force / Z", nunchuk_force_y);		// NOTE: flipped y/z for Luz coordinate system
	//
		//static TLimits nunchuk_force_z_limits = {10000,-10000};
		//float nunchuk_force_z = scale_and_expand_limits(m_p_wiimote->ext.nunchuk.axis.z, &nunchuk_force_z_limits);
		//send_float("Nunchuk / Force / Y", nunchuk_force_z);		// NOTE: flipped y/z for Luz coordinate system

		//printf("joy %d,%d\n", m_p_wiimote->ext.nunchuk.joyx, m_p_wiimote->ext.nunchuk.joyy);
		//printf("cal %d,%d\n", m_p_wiimote->ext.nunchuk.cal.joyx_min, m_p_wiimote->ext.nunchuk.cal.joyx_max);

		//
		// Update Pitch
		//
		// Clamp to -1.0..1.0 g-force, because any more isn't a function of tilt but rather moving the Wiimote.
		//float nunchuk_pitch = clamp_float(((float)(m_p_wiimote->ext.nunchuk.axis.y - m_p_wiimote->ext.nunchuk.cal.y_zero) / (float)(m_p_wiimote->ext.nunchuk.cal.y_scale - m_p_wiimote->ext.nunchuk.cal.y_zero)), -1.0, 1.0) ;
		//nunchuk_pitch *= -1.0;		// We want positive values when Wiimote is vertical
		//nunchuk_pitch += 1.0;			// -1.0..1.0 to 0.0..2.0
		//nunchuk_pitch /= 2.0;			//  0.0..2.0 to 0.0..1.0
		//send_float("Nunchuk / Pitch", nunchuk_pitch);

		//
		// Update Roll
		//
		// Clamp to -1.0..1.0 g-force, because any more isn't a function of tilt but rather moving the Wiimote.
		//float nunchuk_roll = clamp_float(((float)(m_p_wiimote->ext.nunchuk.axis.x - m_p_wiimote->ext.nunchuk.cal.x_zero) / (float)(m_p_wiimote->ext.nunchuk.cal.x_scale - m_p_wiimote->ext.nunchuk.cal.x_zero)), -1.0, 1.0) ;
		//nunchuk_roll += 1.0;		// -1.0..1.0 to 0.0..2.0
		//nunchuk_roll /= 2.0;		//  0.0..2.0 to 0.0..1.0
		//send_float("Nunchuk / Roll", nunchuk_roll);

		return true;
	}
	return true;
}

void InputWiimote::sleep()
{
	usleep(5 * 1000);		// # 1000 microseconds = 1 millisecond
}

InputWiimote::~InputWiimote()
{
	if(m_p_wiimote) cwiid_close(m_p_wiimote);
}
#endif

/*
	void print_state(struct cwiid_state *state)
	{
		int i;
		//int valid_source = 0;

		printf("Battery: %d%%\n", (int)(100.0 * state->battery / CWIID_BATTERY_MAX));
		printf("Buttons: %X\n", state->buttons);
		printf("Acc: x=%d y=%d z=%d\n", state->acc[CWIID_X], state->acc[CWIID_Y], state->acc[CWIID_Z]);

		//printf("IR: ");
		//for (i = 0; i < CWIID_IR_SRC_COUNT; i++) {
			//if (state->ir_src[i].valid) {
				//valid_source = 1;
				//printf("(%d,%d) ", state->ir_src[i].pos[CWIID_X], state->ir_src[i].pos[CWIID_Y]);
			//}
		//}
		//if (!valid_source) {
			//printf("no sources detected");
		//}
		//printf("\n");

		switch (state->ext_type) {
		case CWIID_EXT_NONE:
			printf("No extension\n");
			break;
		case CWIID_EXT_UNKNOWN:
			printf("Unknown extension attached\n");
			break;
		case CWIID_EXT_NUNCHUK:
			printf("Nunchuk: btns=%.2X stick=(%d,%d) acc.x=%d acc.y=%d acc.z=%d\n", state->ext.nunchuk.buttons, state->ext.nunchuk.stick[CWIID_X], state->ext.nunchuk.stick[CWIID_Y], state->ext.nunchuk.acc[CWIID_X], state->ext.nunchuk.acc[CWIID_Y], state->ext.nunchuk.acc[CWIID_Z]);
			break;
		case CWIID_EXT_CLASSIC:
			printf("Classic: btns=%.4X l_stick=(%d,%d) r_stick=(%d,%d) l=%d r=%d\n", state->ext.classic.buttons, state->ext.classic.l_stick[CWIID_X], state->ext.classic.l_stick[CWIID_Y], state->ext.classic.r_stick[CWIID_X], state->ext.classic.r_stick[CWIID_Y], state->ext.classic.l, state->ext.classic.r);
			break;
		case CWIID_EXT_BALANCE:
			printf("Balance: right_top=%d right_bottom=%d left_top=%d left_bottom=%d\n", state->ext.balance.right_top, state->ext.balance.right_bottom, state->ext.balance.left_top, state->ext.balance.left_bottom);
			break;
		//case CWIID_EXT_MOTIONPLUS:
			//printf("MotionPlus: angle_rate=(%d,%d,%d) low_speed=(%d,%d,%d)\n", state->ext.motionplus.angle_rate[0], state->ext.motionplus.angle_rate[1], state->ext.motionplus.angle_rate[2], state->ext.motionplus.low_speed[0], state->ext.motionplus.low_speed[1], state->ext.motionplus.low_speed[2]);
			//break;
		}
	}
*/
