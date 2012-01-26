#define STANDARD_WIDGET_SPACING (6)	// per the GNOME Human Interface Guidelines

void send_float_packet(const char* address, float value);
void send_int_packet(const char* address, int value);

#include "message-bus.h"
extern MessageBus* g_message_bus;
