#ifndef __INPUT_H__
#define __INPUT_H__

#include <pthread.h>

typedef struct
{
	int min;
	int max;
} TLimits;

extern const char* button_names[32 + 1];
extern const char* axis_names[32 + 1];
extern const char* hat_names[8 + 1];

float scale_and_expand_limits(int value, TLimits* limits);

class Input
{
public:
	static pthread_mutex_t m_send_mutex;

	Input();
	virtual ~Input();

	int device_number();
	void set_device_number(int device_number);

	virtual bool update() = 0;
	virtual const char* device_name() = 0;
	virtual const char* device_type() = 0;

	void send_float(const char* name, float value);
	void send_integer(const char* name, int value);

	void set_user_data(void* user_data);
	void* get_user_data();

	bool time_to_die();
	void set_time_to_die();

	virtual void sleep();

private:
	int m_nDeviceNumber;
	void* m_user_data;
	bool m_time_to_die;
};

void input_update_in_thread(Input* input);
void input_init();

#endif
