extern "C" {
	#include <portmidi.h>
	#include <porttime.h>
}

#include "input.h"

#include <vector>
#include <string>
using namespace std;

class InputMIDI : public Input
{
public:
	InputMIDI();
	virtual ~InputMIDI();

	bool scan();

	bool update();
	const char* device_type();
	const char* device_name();

	vector<PortMidiStream*> m_streams;

	void sleep();

private:
	void open_all();
	void reset_all();
	bool process_midi_event(PmEvent& event);
};
