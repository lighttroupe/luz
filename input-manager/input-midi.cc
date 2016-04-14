#ifdef SUPPORT_MIDI
#include <stdio.h>
#include <unistd.h>		// for usleep()

#include "input.h"
#include "input-midi.h"
#include "input-manager.h"

#define MIDI_SLEEP_TIME (5 * 1000)							// 5 ms

#define ZERO_ACTIVITY_RESET_ENABLED
#define ZERO_ACTIVITY_COUNT_TRIGGER_LEVEL (600)		// about 3 seconds

InputMIDI::InputMIDI()
	: m_streams()
{
	Pm_Initialize();
	open_all();
}

const char* InputMIDI::device_type()
{
	return "MIDI";
}

const char* InputMIDI::device_name()
{
	return "MIDI";
}

#define INPUT_BUFFER_SIZE (100)
#define TIME_PROC ((PmTimestamp (*)(void *))Pt_Time)

void InputMIDI::open_all()
{
	int nDevices = Pm_CountDevices();
	for(int i=0 ; i<nDevices ; i++) {
		const PmDeviceInfo *info = Pm_GetDeviceInfo(i);

		if(info && info->input == TRUE && info->opened == FALSE) {
			PortMidiStream* input = NULL;
			Pm_OpenInput(&input, i, NULL, INPUT_BUFFER_SIZE, TIME_PROC, NULL);

			m_streams.push_back(input);
			//printf("midi: opened %s\n", info->name);
		}
	}
}

void InputMIDI::reset_all()
{
	Pm_Terminate();
	Pm_Initialize();
	m_streams.clear();
	open_all();
}

bool InputMIDI::update()
{
#ifdef ZERO_ACTIVITY_RESET_ENABLED
	static int zero_activity_count = 0;
	zero_activity_count += 1;			// assume no updates
#endif

	// Check each stream for updates
	PmEvent event;
	for(int i=0; i<m_streams.size() ; i++) {
		PortMidiStream* input = m_streams.at(i);

		while(Pm_Poll(input) && (Pm_Read(input, &event, 1) == 1)) {
			if(process_midi_event(event)) {
#ifdef ZERO_ACTIVITY_RESET_ENABLED
				zero_activity_count = 0;		// reset counter
#endif
			}
		}
	}

#ifdef ZERO_ACTIVITY_RESET_ENABLED
	if(zero_activity_count == ZERO_ACTIVITY_COUNT_TRIGGER_LEVEL) {
		reset_all();
		zero_activity_count = 0;
	}
#endif

	return true;
}

#define ADDRESS_BUFFER_SIZE 1000
bool InputMIDI::process_midi_event(PmEvent& event)
{
	char address_buffer[ADDRESS_BUFFER_SIZE + 1];

	int channel = (Pm_MessageStatus(event.message) & 0x0F) + 1;		// +1 so we send out channel messages in the range 1-16
	int type = (Pm_MessageStatus(event.message) & 0xF0) >> 4;
	int data_1 = Pm_MessageData1(event.message);
	int data_2 = Pm_MessageData2(event.message);

	// Debug output
	//printf("channel=%d, type=%d, one=%d, two=%d\n", channel, type, data_1, data_2);

	// Type 11 is a Slider, Knob, and sometimes Button change
	if(type == 11) {
		snprintf(address_buffer, ADDRESS_BUFFER_SIZE, "MIDI / Channel %02d / Slider %03d", channel, data_1);
		send_float_packet(address_buffer, (float)data_2 / 127.0);

		if(data_2 == 127) {
			// Axiom25 buttons send this for presses
			snprintf(address_buffer, ADDRESS_BUFFER_SIZE, "MIDI / Channel %02d / Button %03d", channel, data_1);
			send_int_packet(address_buffer, 1);
		}
		else {		// usually 0 but accept anything
			snprintf(address_buffer, ADDRESS_BUFFER_SIZE, "MIDI / Channel %02d / Button %03d", channel, data_1);
			send_int_packet(address_buffer, 0);
		}
	}
	//
	// Type 14 is a spring-loaded Pitch Bend control
	//
	else if(type == 14) {
		snprintf(address_buffer, ADDRESS_BUFFER_SIZE, "MIDI / Channel %02d / Pitch Bend", channel);
		send_float_packet(address_buffer, (data_2 == 64) ? 0.5 : (float)data_2 / 127.0);	// HACK: 64 is the at-rest value on the M-Audio Axiom 25 (remove this if found to be uncommon)
	}
	//
	// Channel Aftertouch
	//
	else if(type == 13) {
		snprintf(address_buffer, ADDRESS_BUFFER_SIZE, "MIDI / Channel %02d / Aftertouch", channel);
		send_float_packet(address_buffer, (float)data_1 / 127.0);
	}
	//
	// Note (and button) on (and sometimes off when value is 0)
	//
	else if(type == 9) {
		snprintf(address_buffer, ADDRESS_BUFFER_SIZE, "MIDI / Channel %02d / Key %03d", channel, data_1);
		send_float_packet(address_buffer, (float)data_2 / 127.0);

		// NOTE: many MIDI controllers eg. M-Audio X-Session send buttons via Note messages
		if(data_2 == 0) {
			// Note/Button off
			snprintf(address_buffer, ADDRESS_BUFFER_SIZE, "MIDI / Channel %02d / Button %03d", channel, data_1);
			send_int_packet(address_buffer, 0);
		}
		else {		// anything non-0 is an 'on'
			// Note on
			snprintf(address_buffer, ADDRESS_BUFFER_SIZE, "MIDI / Channel %02d / Button %03d", channel, data_1);
			send_int_packet(address_buffer, 1);
		}
	}
	// Note off
	else if(type == 8) {
		snprintf(address_buffer, ADDRESS_BUFFER_SIZE, "MIDI / Channel %02d / Key %03d", channel, data_1);
		send_float_packet(address_buffer, 0.0);

		// Send 'button off' since we send 'button on' above
		snprintf(address_buffer, ADDRESS_BUFFER_SIZE, "MIDI / Channel %02d / Button %03d", channel, data_1);
		send_int_packet(address_buffer, 0);
	}
	else {
		return false;		// unknown type?
	}
	// a noteworthy message
	return true;
}

void InputMIDI::sleep()
{
	usleep(MIDI_SLEEP_TIME);
}

InputMIDI::~InputMIDI()
{
	Pm_Terminate();
}
#endif
