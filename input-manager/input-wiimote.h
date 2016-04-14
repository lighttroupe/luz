extern "C" {
	#include <bluetooth/bluetooth.h>
	#include <cwiid.h>
}

#include "input.h"

class InputWiimote : public Input
{
public:
	InputWiimote();
	virtual ~InputWiimote();
	bool scan();
	bool update();
	void sleep();

	const char* device_type();
	const char* device_name();

	int m_old_buttons;

private:
	cwiid_wiimote_t* m_p_wiimote;
	cwiid_wiimote_t* m_p_wiimote_old;
};
