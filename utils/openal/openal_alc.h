#ifndef RUBY_OPENAL_ALC_H
#define RUBY_OPENAL_ALC_H

#ifdef __cplusplus
extern "C" {
#endif

/// module variables
extern VALUE vALC;

/// class variables
extern VALUE vALC_Device;
extern VALUE vALC_Context;
extern VALUE vALC_CaptureDevice;

/// ALC module's constants
extern VALUE vALC_NO_ERROR; // errors
extern VALUE vALC_INVALID_DEVICE;
extern VALUE vALC_INVALID_CONTEXT;
extern VALUE vALC_INVALID_ENUM;
extern VALUE vALC_INVALID_VALUE;
extern VALUE vALC_OUT_OF_MEMORY;
extern VALUE vALC_DEFAULT_DEVICE_SPECIFIER; // states
extern VALUE vALC_CAPTURE_DEFAULT_DEVICE_SPECIFIER;
extern VALUE vALC_DEVICE_SPECIFIER;
extern VALUE vALC_CAPTURE_DEVICE_SPECIFIER;
extern VALUE vALC_EXTENSIONS;
extern VALUE vALC_MAJOR_VERSION;
extern VALUE vALC_MINOR_VERSION;
extern VALUE vALC_ATTRIBUTES_SIZE;
extern VALUE vALC_ALL_ATTRIBUTES;
extern VALUE vALC_FREQUENCY; // options
extern VALUE vALC_SYNC;
extern VALUE vALC_REFRESH;
extern VALUE vALC_MONO_SOURCES;
extern VALUE vALC_STEREO_SOURCES;

extern void setup_module_ALC();

#ifdef __cplusplus
}
#endif

#endif
