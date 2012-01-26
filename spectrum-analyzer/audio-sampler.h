#ifndef __AUDIO_SAMPLER_H__
#define __AUDIO_SAMPLER_H__

#define ALSA_PCM_NEW_HW_PARAMS_API		// use new API
#include <alsa/asoundlib.h>
#include <fftw3.h>

class AudioSampler 
{
public:
	AudioSampler();
	virtual ~AudioSampler();

	bool Update();
	bool Open(const char* alsa_device_name);

	void Analyze();

	float* GetMagnitudeArray();
	int GetMagnitudeCount();

private:
	unsigned int m_rate;
	snd_pcm_uframes_t m_frame_size;
	snd_pcm_t* m_alsa;
	float* m_frame_buffer;

	fftw_plan m_fftw_plan;

	double* m_sample_buffer_double_in;
	double* m_sample_buffer_double_out;
	float* m_bar_magnitudes;

	int m_overrun_count;
	int m_underrun_count;
};

#endif
