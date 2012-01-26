extern "C" {
	#define _ENABLE_TILT
	#define _ENABLE_FORCE

	#include <wiimote.h>
	#include <wiimote_api.h>
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
	wiimote_t* m_p_wiimote;
	wiimote_t* m_p_wiimote_old;
};
