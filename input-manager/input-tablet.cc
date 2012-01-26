#include "input-tablet.h"
#include <stdio.h>
#include <stdlib.h>
#include <cstring>

#include "utils.h"

#define MAX_DEVICE_AXES (6)
const char* axes_names[MAX_DEVICE_AXES] = {
	"X",
	"Y",
	"Pressure",
	"Tilt X",
	"Tilt Y",
	"Wheel"
};

bool invert_axis[MAX_DEVICE_AXES] = {false, true, false, false, true, false};

#define INVALID_EVENT_TYPE (-1)

const char* make_name_and_id(const char* name, int id)
{
	static char buffer[1001];		// static allocation-- can only provide 1 at a time, but that's OK for this use
	snprintf(buffer, 1000, "%s (%d)", name, id);
	return buffer;
}

vector<string>* tablet_list()
{
	vector<string>* string_list = new vector<string>;		// TODO: make sure these aren't leaked

	int num_devices = 0;

	Display* display = XOpenDisplay(NULL);
	XDeviceInfo *devices = XListInputDevices(display, &num_devices);
	for(int i=0; i<num_devices; i++) {
		string_list->push_back(*(new string(make_name_and_id(devices[i].name, devices[i].id))));
	}
	XFreeDeviceList(devices);
	XCloseDisplay(display);

	return string_list;
}

InputTablet* tablet_open_by_name_and_id(const char* name_and_id)
{
	int num_devices = 0;
	Display* display = XOpenDisplay(NULL);
	XDeviceInfo *devices = XListInputDevices(display, &num_devices);

	for(int i=0; i<num_devices; i++) {
		if(strcmp(make_name_and_id(devices[i].name, devices[i].id), name_and_id) == 0) {
			XDevice* device = XOpenDevice(display, devices[i].id);
			XFreeDeviceList(devices);
			return new InputTablet(display, device, devices[i].name);
		}
	}
	XFreeDeviceList(devices);
	return NULL;
}

InputTablet::InputTablet(Display* display, XDevice* device, const char* name)
	: m_display(display),
		m_device(device),
		m_device_name(name),
		m_motion_type(INVALID_EVENT_TYPE),
		m_button_press_type(INVALID_EVENT_TYPE),
		m_button_release_type(INVALID_EVENT_TYPE),
		m_proximity_in_type(INVALID_EVENT_TYPE),
		m_proximity_out_type(INVALID_EVENT_TYPE)
{
	m_axis_values = (int*)calloc(sizeof(int), MAX_DEVICE_AXES); // new int[MAX_DEVICE_AXES];
	m_axis_limits = (TLimits*)calloc(sizeof(TLimits), MAX_DEVICE_AXES); //new TLimits[MAX_DEVICE_AXES];		// 0 for min and max is fine for joystick axes

	register_events();

// assume presence of XInput for now
//	XExtensionVersion *version = XGetExtensionVersion(g_display, INAME);
//	if(version == NULL || version == (XExtensionVersion*) NoSuchExtension || version->present == False) {
//		fprintf(stderr, "required extension '%s' missing in X server\n", INAME);
//		//exit(1);
//	}
//	XFree(version);
}

const char* InputTablet::device_type()
{
	return "Tablet";
}

const char* InputTablet::device_name()
{
	return (const char*)(m_device_name.c_str());
}

int InputTablet::register_events()
{
	int number = 0;		// number of events registered
	XEventClass event_list[10];		// TODO: why was this 7?

	for (int i=0; i<m_device->num_classes; i++) {
		XInputClassInfo *ip = &(m_device->classes[i]);

		if(ip->input_class == ButtonClass) {
			DeviceButtonPress(m_device, m_button_press_type, event_list[number]); number++;
			DeviceButtonRelease(m_device, m_button_release_type, event_list[number]); number++;
		}
		else if (ip->input_class == ValuatorClass) {
			DeviceMotionNotify(m_device, m_motion_type, event_list[number]); number++;
			ProximityIn(m_device, m_proximity_in_type, event_list[number]); number++;
			ProximityOut(m_device, m_proximity_out_type, event_list[number]); number++;
		}
	}

	Window root_window = RootWindow(m_display, DefaultScreen(m_display));
	if (XSelectExtensionEvent(m_display, root_window, event_list, number)) {
		fprintf(stderr, "error selecting extended events\n");
		return 0;
	}
	//printf("registered %d\n", number);
	return number;
}

int function_that_returns_true(Display* d, XEvent* e, char* c)
{
	return true;
}

bool InputTablet::update()
{
	XEvent event;

	// Block waiting for one event
	XNextEvent(m_display, &event);
	if (event.type == m_motion_type) {
		XDeviceMotionEvent* motion_event = (XDeviceMotionEvent*)&event;

		// Check each axis for change
		int axis_index;
		for(axis_index=0 ; axis_index < motion_event->axes_count && axis_index < MAX_DEVICE_AXES ; axis_index++) {
			int axis_value = motion_event->axis_data[axis_index];

			// Send if axis changed
			if(axis_value != m_axis_values[axis_index]) {
				float value = scale_and_expand_limits(axis_value, &(m_axis_limits[axis_index]));

				// Invert some axes so it looks like the cartesian plane
				if(invert_axis[axis_index])
					value = 1.0 - value;

				// Send
				send_float(axes_names[axis_index], value);

				m_axis_values[axis_index] = axis_value;		// NOTE: this saves the raw integer axis_value
			}
		}
	} else if(event.type == m_button_press_type) {
		XDeviceButtonEvent *button = (XDeviceButtonEvent *) &event;
		send_integer(button_names[button->button], 1);
	} else if(event.type == m_button_release_type) {
		XDeviceButtonEvent *button = (XDeviceButtonEvent *) &event;
		send_integer(button_names[button->button], 0);
	} else if(event.type == m_proximity_in_type) {
		send_integer("Pen Present", 1);
	} else if(event.type == m_proximity_out_type) {
		send_integer("Pen Present", 0);
	}
}

InputTablet::~InputTablet()
{
	XCloseDevice(m_display, m_device);
	XCloseDisplay(m_display);
}
