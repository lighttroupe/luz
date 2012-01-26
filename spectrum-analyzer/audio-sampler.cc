#include "audio-sampler.h"
#include "spectrum-analyzer.h"

#include <complex.h>
#include <fftw3.h>
#include <math.h>
#include "utils.h"

// ALSA audio
#define ALSA_PCM_NEW_HW_PARAMS_API		// Use the newer ALSA API
#include <alsa/asoundlib.h>

#define NUM_CHANNELS (1)
#define DEFAULT_ALSA_DEVICE_NAME ("default")

AudioSampler::AudioSampler()
{
	m_alsa = NULL;

	m_rate = 44100;
	m_frame_size = 256;
	m_frame_buffer = NULL;

	m_bar_magnitudes = NULL;

	m_overrun_count = 0;
	m_underrun_count = 0;
}

bool AudioSampler::Open(const char* alsa_device_name)
{
	int ret;
	int dir = 0;

	if(alsa_device_name == NULL) {
		alsa_device_name = DEFAULT_ALSA_DEVICE_NAME;
		printf("NOTE: Using %s override by running: spectrum-analyzer <alsa capture device>\n", alsa_device_name);
	}

	ret = snd_pcm_open(&m_alsa, alsa_device_name, SND_PCM_STREAM_CAPTURE, 0);
	if(ret < 0) {
		printf("unable to open pcm device '%s': %s\n", alsa_device_name, snd_strerror(ret));
		return false;
	}

	// Get default params
	snd_pcm_hw_params_t *params;
	snd_pcm_hw_params_alloca(&params);
	snd_pcm_hw_params_any(m_alsa, params);

	// Set desired params
	snd_pcm_hw_params_set_access(m_alsa, params, SND_PCM_ACCESS_RW_INTERLEAVED);
	snd_pcm_hw_params_set_format(m_alsa, params, SND_PCM_FORMAT_FLOAT); //SND_PCM_FORMAT_S16_LE);
	snd_pcm_hw_params_set_channels(m_alsa, params, NUM_CHANNELS);
	snd_pcm_hw_params_set_rate_near(m_alsa, params, &m_rate, &dir);
	snd_pcm_hw_params_set_period_size_near(m_alsa, params, &m_frame_size, &dir);

	// Write the parameters to the driver
	ret = snd_pcm_hw_params(m_alsa, params);
	if(ret < 0) {
		fprintf(stderr, "unable to set hw parameters: %s\n", snd_strerror(ret));
		exit(1);
	}
	snd_pcm_hw_params_get_period_size(params, &m_frame_size, &dir);
	snd_pcm_hw_params_get_rate(params, &m_rate, &dir);

	m_frame_buffer = (float*)malloc(m_frame_size * NUM_CHANNELS * sizeof(float));

	printf("ALSA rate: %d, frames: %d\n", m_rate, (int)m_frame_size);

	// Create a sample buffer large enough to hold one period
	m_sample_buffer_double_in = (double*)fftw_malloc(m_frame_size * NUM_CHANNELS * sizeof(double));
	m_sample_buffer_double_out = (double*)fftw_malloc(m_frame_size * NUM_CHANNELS * sizeof(double));

	m_bar_magnitudes = (float*)malloc(NUM_BARS * sizeof(float));

	// Configure FFTW plan
	printf("Calculating FFT plan...\n");
	m_fftw_plan = fftw_plan_r2r_1d(m_frame_size, m_sample_buffer_double_in, m_sample_buffer_double_out, FFTW_REDFT00, FFTW_MEASURE);		// FFTW_HC2R  FFTW_DHT
}

AudioSampler::~AudioSampler()
{
}

bool AudioSampler::Update()
{
	int ret = snd_pcm_readi(m_alsa, m_frame_buffer, m_frame_size);
	if(ret == -EPIPE) {
		// EPIPE means overrun
		m_overrun_count++;  //fprintf(stderr, "ALSA overrun occurred\n");
		snd_pcm_prepare(m_alsa);
		return false;
	} else if(ret < 0) {
		fprintf(stderr, "ALSA error from read: %s\n", snd_strerror(ret));
		return false;
	} else if(ret != (int)m_frame_size) {
		fprintf(stderr, "ALSA short read, read %d frames\n", ret);
		return false;
	}
	else {
		return true;
	}
}

void AudioSampler::Analyze()
{
	int i;

	// Copy float->double for FFTW
	for (i=0 ; i<m_frame_size ; i++) {
		m_sample_buffer_double_in[i] = (double)m_frame_buffer[i];
	}

	// Run FFT.  NOTE: It reads directly from and writes to the buffers passed to it in the fftw_plan_* call above.
	fftw_execute(m_fftw_plan);

	// Copy back to float 
	for (i=0 ; i<m_frame_size ; i++) {
		m_frame_buffer[i] = (float)m_sample_buffer_double_out[i];
	}

	// Calculate 0-1 magnitudes for each analyzer bar
	int samples_per_bar = (m_frame_size / 6) / NUM_BARS;
	for(i=0 ; i<NUM_BARS ; i++) {
		m_bar_magnitudes[i] = 0.18 * log(average_of_floats(&m_frame_buffer[i * samples_per_bar], samples_per_bar));
	}
}

float* AudioSampler::GetMagnitudeArray()
{
	return m_bar_magnitudes;
}

int AudioSampler::GetMagnitudeCount()
{
	return NUM_BARS;
}
