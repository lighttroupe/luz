#ifndef __INPUT_TOUCHPAD_H__
#define __INPUT_TOUCHPAD_H__

extern "C" {
	#include <stdio.h>
	#include <stdlib.h>
	#include <sys/types.h>
	#include <sys/ipc.h>
	#include <sys/shm.h>
	#include <sys/time.h>
	#include <unistd.h>
	#include <string.h>
	#include <stddef.h>
	#include <math.h>

	//
	// Touchpad Support
	//
	#include <X11/Xdefs.h>
	#include <synaptics.h>
}

#include "input.h"

#include <vector>
#include <string>
using namespace std;

class InputTouchpad : public Input
{
public:
	InputTouchpad();
	virtual ~InputTouchpad();

	bool connect();
	bool update();

	const char* device_type();
	const char* device_name();

	void sleep();

private:
	SynapticsSHM *m_p_synshm;
	int m_shmid;
	SynapticsSHM m_synshm_old;
	TLimits x_limits, y_limits, z_limits;
};

#endif
