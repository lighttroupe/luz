#include "input-touchpad.h"
#include "utils.h"

// Synaptics touchpad driver makes a shared memory area available to us, filled with juicy live data.
// We poll it, notice changes, and send Luz inputs.

InputTouchpad::InputTouchpad()
{
	// TODO: better way to init these
	x_limits.min = 10000; x_limits.max = 0;
	y_limits.min = 10000; y_limits.max = 0;
	z_limits.min = 10000; z_limits.max = 0;
}

bool InputTouchpad::connect()
{
	if ((m_shmid = shmget(SHM_SYNAPTICS, sizeof(SynapticsSHM), 0)) == -1) {
		if ((m_shmid = shmget(SHM_SYNAPTICS, 0, 0)) == -1) {
			fprintf(stderr, "input-touchpad: can't access shared memory area. (SHMConfig disabled?)\n");
			return false;
		} else {
			fprintf(stderr, "input-touchpad: incorrect size of shared memory area. (Incompatible driver version?)\n");
			return false;
		}
	}

	// Map shared memory to our address space
	if ((m_p_synshm = (SynapticsSHM*)shmat(m_shmid, NULL, SHM_RDONLY)) == NULL) {
		perror("input-touchpad: shmat");
		return false;
	}
	return true;
}

const char* InputTouchpad::device_type()
{
	return "Touchpad";
}

const char* InputTouchpad::device_name()
{
	return "Touchpad";
}

bool InputTouchpad::update()
{
	SynapticsSHM cur = *m_p_synshm;

	// For some reason, when lifting a finger off a Synaptics Touchpad, the x sometimes jumps to 1 for the last few updates
	if (cur.x != 1 && cur.z >= 5) {
		if (cur.x != m_synshm_old.x) send_float("X", scale_and_expand_limits(cur.x, &x_limits));

		// NOTE: y is inverted because ALPS and Synaptic both place y==0 at the top and we prefer a cartesian coordinate system
		if (cur.y != m_synshm_old.y) send_float("Y", 1.0 - scale_and_expand_limits(cur.y, &y_limits));
	}

	// Z is a bit different
	if (cur.z != m_synshm_old.z) {
		// ALPS send either 0 or ~40->120+ for z.
		// We special-case 0 so scale_and_expand_limits never sees it, which prevents a leap to ~40/MAX when lightly touched.
		if (cur.z == 0) {
			//lo_send(t, "TouchPad / Pressure", "f", 0.0);
			send_float("Pressure", 0.0);
			//lo_send(t, "TouchPad / Touch", "i", 0);
			send_integer("Touch", 0);
		}
		else {
			float pressure = scale_and_expand_limits(cur.z, &z_limits);

			// Because of the special case for z==0 above, the minimum non-0 z value will be returned as 0.0.
			if(pressure == 0.0) { pressure = 0.008; }	// NOTE: this value is arbitrary (but approx 1/128 which is probably the max)

			//lo_send(t, "TouchPad / Pressure", "f", pressure);
			send_float("Pressure", pressure);
			//lo_send(t, "TouchPad / Touch", "i", 1);
			send_integer("Touch", 1);
		}
	}

	// Copy current touchpad settings to old ones
	m_synshm_old = cur;

	return true;
}

void InputTouchpad::sleep()
{
	usleep(5 * 1000);
}

InputTouchpad::~InputTouchpad()
{
}
