#ifndef __INPUT_TABLET_H__
#define __INPUT_TABLET_H__

extern "C" {
	//
	// Xinput Support for Tablets
	//
	#include <X11/Xlib.h>
	#include <X11/extensions/XInput.h>
	#include <X11/Xutil.h>
}

#include "input.h"

#include <vector>
#include <string>
using namespace std;

class InputTablet;

void tablet_init();
vector<string>* tablet_list();
InputTablet* tablet_open_by_name_and_id(const char* name_and_id);

class InputTablet : public Input
{
public:
	InputTablet(Display* display, XDevice* device, const char* name);
	virtual ~InputTablet();
	bool scan();

	bool update();
	const char* device_type();
	const char* device_name();

	Display* m_display;
	XDevice* m_device;

private:
	int register_events();

	int *m_axis_values;
	TLimits *m_axis_limits;

	int m_motion_type;
	int m_button_press_type;
	int m_button_release_type;
	int m_proximity_in_type;
	int m_proximity_out_type;
	string m_device_name;
};

#endif
