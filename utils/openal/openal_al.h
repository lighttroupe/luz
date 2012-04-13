#ifndef RUBY_OPENAL_AL_H
#define RUBY_OPENAL_AL_H

#ifdef __cplusplus
extern "C" {
#endif

/// module variable
extern VALUE vAL;

/// class variables
extern VALUE vAL_Listener;
extern VALUE vAL_SampleData;
extern VALUE vAL_Buffer;
extern VALUE vAL_Source;

/// AL module's constants
extern VALUE vAL_NO_ERROR;  // errors
extern VALUE vAL_INVALID_NAME;
extern VALUE vAL_INVALID_ENUM;
extern VALUE vAL_INVALID_VALUE;
extern VALUE vAL_INVALID_OPERATION;
extern VALUE vAL_OUT_OF_MEMORY;
extern VALUE vAL_DOPPLER_FACTOR;  // states
extern VALUE vAL_SPEED_OF_SOUND;
extern VALUE vAL_DISTANCE_MODEL;
extern VALUE vAL_VENDOR;  // specs
extern VALUE vAL_VERSION;
extern VALUE vAL_RENDERER;
extern VALUE vAL_EXTENSIONS;
extern VALUE vAL_INVERSE_DISTANCE;  // disance model
extern VALUE vAL_INVERSE_DISTANCE_CLAMPED;
extern VALUE vAL_LINEAR_DISTANCE;
extern VALUE vAL_LINEAR_DISTANCE_CLAMPED;
extern VALUE vAL_EXPONENT_DISTANCE;
extern VALUE vAL_EXPONENT_DISTANCE_CLAMPED;
extern VALUE vAL_NONE;
extern VALUE vAL_FORMAT_MONO8;  // formats
extern VALUE vAL_FORMAT_MONO16;
extern VALUE vAL_FORMAT_STEREO8;
extern VALUE vAL_FORMAT_STEREO16;
extern VALUE vAL_UNDETERMINED; // source types
extern VALUE vAL_STATIC;
extern VALUE vAL_STREAMING;

extern void setup_module_AL();
extern VALUE AL_Buffer_from_albuf(const ALuint b);

#ifdef __cplusplus
}
#endif

#endif
