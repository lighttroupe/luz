#include <stdio.h>
#include "input.h"
#include "input-manager.h"

const char* button_names[] = {
	"Button 00","Button 01","Button 02","Button 03","Button 04","Button 05","Button 06","Button 07","Button 08","Button 09","Button 10","Button 11","Button 12","Button 13","Button 14","Button 15","Button 16","Button 17","Button 18","Button 19","Button 20","Button 21","Button 22","Button 23","Button 24","Button 25","Button 26","Button 27","Button 28","Button 29","Button 30","Button 31","Button 32"
};
const char* axis_names[] = {
	"Axis 00","Axis 01","Axis 02","Axis 03","Axis 04","Axis 05","Axis 06","Axis 07","Axis 08","Axis 09","Axis 10","Axis 11","Axis 12","Axis 13","Axis 14","Axis 15","Axis 16","Axis 17","Axis 18","Axis 19","Axis 20","Axis 21","Axis 22","Axis 23","Axis 24","Axis 25","Axis 26","Axis 27","Axis 28","Axis 29","Axis 30","Axis 31","Axis 32"
};
const char* hat_names[] = {
	"Hat 00","Hat 01","Hat 02","Hat 03","Hat 04","Hat 05","Hat 06","Hat 07","Hat 08"
};

pthread_mutex_t Input::m_send_mutex;

void input_init()
{
	pthread_mutex_init(&Input::m_send_mutex, NULL);
}

float scale_and_expand_limits(int value, TLimits* limits)
{
	if(value < limits->min)
		limits->min = value;

	if(value > limits->max)
		limits->max = value;

	int range = (limits->max - limits->min);

	if(range == 0)
		return 0.0;

	return (float)(value - limits->min) / (float)range;
}

void* input_update_in_thread_main(void* void_input)
{
	Input* input = (Input*)void_input;
	while(!(input->time_to_die())) {
		input->update();
		input->sleep();
	}
	delete input;
}

void input_update_in_thread(Input* input)
{
	pthread_t thread_handle;
	pthread_create(&thread_handle, NULL, input_update_in_thread_main, (void*)input);
}

Input::Input()
 : m_nDeviceNumber(1),
   m_time_to_die(false)
{
}

void Input::sleep()
{
	// default does nothing
}

bool Input::time_to_die()
{
	return m_time_to_die;
}

void Input::set_time_to_die()
{
	m_time_to_die = true;
}

int Input::device_number()
{
	return m_nDeviceNumber;
}

void Input::set_device_number(int device_number)
{
	m_nDeviceNumber = device_number;
}

#define ADDRESS_BUFFER_SIZE 1000
char g_address_buffer[ADDRESS_BUFFER_SIZE + 1];

void Input::send_float(const char* name, float value)
{
	pthread_mutex_lock(&Input::m_send_mutex);
	snprintf(g_address_buffer, ADDRESS_BUFFER_SIZE, "%s %02d / %s", device_type(), device_number(), name);
	send_float_packet(g_address_buffer, value);
	pthread_mutex_unlock(&Input::m_send_mutex);
}

void Input::send_integer(const char* name, int value)
{
	pthread_mutex_lock(&Input::m_send_mutex);
	snprintf(g_address_buffer, ADDRESS_BUFFER_SIZE, "%s %02d / %s", device_type(), device_number(), name);
	send_int_packet(g_address_buffer, value);
	pthread_mutex_unlock(&Input::m_send_mutex);
}

void Input::set_user_data(void* user_data)
{
	m_user_data = user_data;
}

void* Input::get_user_data()
{
	return m_user_data;
}

Input::~Input()
{
}
