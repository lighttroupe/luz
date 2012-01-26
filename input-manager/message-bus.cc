#include "message-bus.h"

#include <stdio.h>
#include <errno.h>

MessageBus::MessageBus()
	: m_broadcast(false)
{
	// HACK: create a liblo server so that we can get its socket and manually enable UDP broadcasting (otherwise broadcasting is only supported in liblo >= 0.25)
	//
	int port = DEFAULT_UDP_RECEIVE_PORT;
	char port_as_string_buffer[101];

	// loop until we find an available port
	while(true) {
		snprintf(port_as_string_buffer, 100, "%d", port);
		m_server = lo_server_new(port_as_string_buffer, NULL);

		// Success?
		if(m_server != NULL) break;
		port += 1;	// otherwise loop
	}

	// Create server and manually set broadcast bit
	int server_socket_fd = lo_server_get_socket_fd(m_server);
	int opt = 1;
	setsockopt(server_socket_fd, SOL_SOCKET, SO_BROADCAST, &opt, sizeof(int));
	// END HACK

	m_address_local = lo_address_new("localhost", DEFAULT_UDP_SEND_PORT);            // sends via loopback device
	m_address_broadcast = lo_address_new("255.255.255.255", DEFAULT_UDP_SEND_PORT);  // broadcast
}

void MessageBus::set_broadcast(bool broadcast)
{
	m_broadcast = broadcast;
}

void MessageBus::send_int(const char* address, int value)
{
	// HACK: use the simpler lo_send once liblo 0.25 is widespread
	if(m_broadcast)
		lo_send_from(m_address_broadcast, m_server, LO_TT_IMMEDIATE, address, "i", value);
	else
		lo_send_from(m_address_local, m_server, LO_TT_IMMEDIATE, address, "i", value);
}

void MessageBus::send_float(const char* address, float value)
{
	// HACK: use the simpler lo_send once liblo 0.25 is widespread
	if(m_broadcast)
		lo_send_from(m_address_broadcast, m_server, LO_TT_IMMEDIATE, address, "f", value);
	else
		lo_send_from(m_address_local, m_server, LO_TT_IMMEDIATE, address, "f", value);
}

MessageBus::~MessageBus()
{
}
