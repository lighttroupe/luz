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
	const char* device_type();
	const char* device_name();

	void sleep();

private:
	cwiid_wiimote_t* m_p_wiimote;
	cwiid_wiimote_t* m_p_wiimote_old;
};
