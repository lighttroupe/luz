#ifndef __MESSAGE_BUS_H__
#define __MESSAGE_BUS_H__

//
// liblo OpenSoundControl (http://liblo.sourceforge.net/)
//
#include <lo/lo.h>

#define DEFAULT_UDP_SEND_PORT ("10007")				// LOOOZ :D
#define DEFAULT_UDP_RECEIVE_PORT (10008)		// currently nothing is received at this address, it just has to be different than the send port (or liblo init fails)

class MessageBus
{
public:
	MessageBus();
	virtual ~MessageBus();

	void set_broadcast(bool broadcast);

	void send_int(const char* address, int value);
	void send_float(const char* address, float value);

private:
	lo_server m_server;

	lo_address m_address_local;
	lo_address m_address_broadcast;

	bool m_broadcast;
};

#endif

