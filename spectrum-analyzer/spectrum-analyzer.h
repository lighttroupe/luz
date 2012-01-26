#define NUM_VERTICAL_LINES (4)
#define NUM_HORIZONTAL_LINES (8)

#define NUM_BARS (NUM_VERTICAL_LINES * 2)

#define STANDARD_WIDGET_SPACING (6)

void send_float_packet(const char* address, float value);
void send_int_packet(const char* address, int value);

#include "message-bus.h"
extern MessageBus* g_message_bus;
extern bool g_time_to_quit;
