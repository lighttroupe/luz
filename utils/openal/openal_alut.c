#include "ruby.h"
#include "openal.h"
#include "openal_alut.h"
#include "AL/al.h"
#include "AL/alut.h"

/// module values
VALUE vALUT;

/// module constants
VALUE  vALUT_API_MAJOR_VERSION  = INT2FIX(ALUT_API_MAJOR_VERSION);
VALUE  vALUT_API_MINOR_VERSION  = INT2FIX(ALUT_API_MINOR_VERSION);
VALUE  vALUT_ERROR_NO_ERROR = INT2FIX(ALUT_ERROR_NO_ERROR);
VALUE  vALUT_ERROR_OUT_OF_MEMORY  = INT2FIX(ALUT_ERROR_OUT_OF_MEMORY);
VALUE  vALUT_ERROR_INVALID_ENUM = INT2FIX(ALUT_ERROR_INVALID_ENUM);
VALUE  vALUT_ERROR_INVALID_VALUE  = INT2FIX(ALUT_ERROR_INVALID_VALUE);
VALUE  vALUT_ERROR_INVALID_OPERATION  = INT2FIX(ALUT_ERROR_INVALID_OPERATION);
VALUE  vALUT_ERROR_NO_CURRENT_CONTEXT = INT2FIX(ALUT_ERROR_NO_CURRENT_CONTEXT);
VALUE  vALUT_ERROR_AL_ERROR_ON_ENTRY  = INT2FIX(ALUT_ERROR_AL_ERROR_ON_ENTRY);
VALUE  vALUT_ERROR_ALC_ERROR_ON_ENTRY = INT2FIX(ALUT_ERROR_ALC_ERROR_ON_ENTRY);
VALUE  vALUT_ERROR_OPEN_DEVICE  = INT2FIX(ALUT_ERROR_OPEN_DEVICE);
VALUE  vALUT_ERROR_CLOSE_DEVICE = INT2FIX(ALUT_ERROR_CLOSE_DEVICE);
VALUE  vALUT_ERROR_CREATE_CONTEXT = INT2FIX(ALUT_ERROR_CREATE_CONTEXT);
VALUE  vALUT_ERROR_MAKE_CONTEXT_CURRENT = INT2FIX(ALUT_ERROR_MAKE_CONTEXT_CURRENT);
VALUE  vALUT_ERROR_DESTROY_CONTEXT  = INT2FIX(ALUT_ERROR_DESTROY_CONTEXT);
VALUE  vALUT_ERROR_GEN_BUFFERS  = INT2FIX(ALUT_ERROR_GEN_BUFFERS);
VALUE  vALUT_ERROR_BUFFER_DATA  = INT2FIX(ALUT_ERROR_BUFFER_DATA);
VALUE  vALUT_ERROR_IO_ERROR = INT2FIX(ALUT_ERROR_IO_ERROR);
VALUE  vALUT_ERROR_UNSUPPORTED_FILE_TYPE  = INT2FIX(ALUT_ERROR_UNSUPPORTED_FILE_TYPE);
VALUE  vALUT_ERROR_UNSUPPORTED_FILE_SUBTYPE = INT2FIX(ALUT_ERROR_UNSUPPORTED_FILE_SUBTYPE);
VALUE  vALUT_ERROR_CORRUPT_OR_TRUNCATED_DATA  = INT2FIX(ALUT_ERROR_CORRUPT_OR_TRUNCATED_DATA);
VALUE  vALUT_WAVEFORM_SINE  = INT2FIX(ALUT_WAVEFORM_SINE);
VALUE  vALUT_WAVEFORM_SQUARE  = INT2FIX(ALUT_WAVEFORM_SQUARE);
VALUE  vALUT_WAVEFORM_SAWTOOTH  = INT2FIX(ALUT_WAVEFORM_SAWTOOTH);
VALUE  vALUT_WAVEFORM_WHITENOISE  = INT2FIX(ALUT_WAVEFORM_WHITENOISE);
VALUE  vALUT_WAVEFORM_IMPULSE = INT2FIX(ALUT_WAVEFORM_IMPULSE);
VALUE  vALUT_LOADER_BUFFER  = INT2FIX(ALUT_LOADER_BUFFER);
VALUE  vALUT_LOADER_MEMORY  = INT2FIX(ALUT_LOADER_MEMORY);


// version constants
static void define_ALUT_version_consts() {
  rb_define_const(vALUT,"MAJOR_VERSION",vALUT_API_MAJOR_VERSION);
  rb_define_const(vALUT,"MINOR_VERSION",vALUT_API_MINOR_VERSION);
}

// errors constants
static void define_ALUT_error_consts() {
  rb_define_const(vALUT,"ERROR_NO_ERROR",vALUT_ERROR_NO_ERROR);
  rb_define_const(vALUT,"ERROR_OUT_OF_MEMORY",vALUT_ERROR_OUT_OF_MEMORY);
  rb_define_const(vALUT,"ERROR_INVALID_ENUM",vALUT_ERROR_INVALID_ENUM);
  rb_define_const(vALUT,"ERROR_INVALID_VALUE",vALUT_ERROR_INVALID_VALUE);
  rb_define_const(vALUT,"ERROR_INVALID_OPERATION",vALUT_ERROR_INVALID_OPERATION);
  rb_define_const(vALUT,"ERROR_NO_CURRENT_CONTEXT",vALUT_ERROR_NO_CURRENT_CONTEXT);
  rb_define_const(vALUT,"ERROR_AL_ERROR_ON_ENTRY",vALUT_ERROR_AL_ERROR_ON_ENTRY);
  rb_define_const(vALUT,"ERROR_ALC_ERROR_ON_ENTRY",vALUT_ERROR_ALC_ERROR_ON_ENTRY);
  rb_define_const(vALUT,"ERROR_OPEN_DEVICE",vALUT_ERROR_OPEN_DEVICE);
  rb_define_const(vALUT,"ERROR_CLOSE_DEVICE",vALUT_ERROR_CLOSE_DEVICE);
  rb_define_const(vALUT,"ERROR_CREATE_CONTEXT",vALUT_ERROR_CREATE_CONTEXT);
  rb_define_const(vALUT,"ERROR_MAKE_CONTEXT_CURRENT",vALUT_ERROR_MAKE_CONTEXT_CURRENT);
  rb_define_const(vALUT,"ERROR_DESTROY_CONTEXT",vALUT_ERROR_DESTROY_CONTEXT);
  rb_define_const(vALUT,"ERROR_GEN_BUFFERS",vALUT_ERROR_GEN_BUFFERS);
  rb_define_const(vALUT,"ERROR_BUFFER_DATA",vALUT_ERROR_BUFFER_DATA);
  rb_define_const(vALUT,"ERROR_IO_ERR",vALUT_ERROR_IO_ERROR);
  rb_define_const(vALUT,"ERROR_UNSUPPORTED_FILE_TYPE",vALUT_ERROR_UNSUPPORTED_FILE_TYPE);
  rb_define_const(vALUT,"ERROR_UNSUPPORTED_FILE_SUBTYPE",vALUT_ERROR_UNSUPPORTED_FILE_SUBTYPE);
  rb_define_const(vALUT,"ERROR_CORRUPT_OR_TRUNCATED_DATA",vALUT_ERROR_CORRUPT_OR_TRUNCATED_DATA);

}

// waveform constants
static void define_ALUT_waveform_consts() {
  rb_define_const(vALUT,"WAVEFORM_SINE",vALUT_WAVEFORM_SINE);
  rb_define_const(vALUT,"WAVEFORM_SQUARE",vALUT_WAVEFORM_SQUARE);
  rb_define_const(vALUT,"WAVEFORM_SAWTOOTH",vALUT_WAVEFORM_SAWTOOTH);
  rb_define_const(vALUT,"WAVEFORM_WHITENOISE",vALUT_WAVEFORM_WHITENOISE);
  rb_define_const(vALUT,"WAVEFORM_IMPULSE",vALUT_WAVEFORM_IMPULSE);
}

// loader constants
static void define_ALUT_loader_consts() {
  rb_define_const(vALUT, "LOADER_BUFFER", vALUT_LOADER_BUFFER);
  rb_define_const(vALUT, "LOADER_MEMORY", vALUT_LOADER_MEMORY);
}

/// ALUT::get_error : ALenum
static VALUE ALUT_get_error(VALUE self) {
  ALenum e = alutGetError();
  return INT2FIX(e);
}

/// ALUT::get_error_string(err : ALenum) : String
static VALUE ALUT_get_error_string(VALUE self, VALUE en) {
  ALenum e = NUM2INT(en);
  const char* s = alutGetErrorString(e);
  return rb_str_new2(s);
}

/// ALUT::sleep(duration : ALfloat) : Boolean
static VALUE ALUT_sleep(VALUE self, VALUE duration) {
  ALfloat f = (float) NUM2DBL(duration);
  ALboolean b = alutSleep(f);
  return albool2rbbool(b);
}

/// ALUT::exit : Boolean
static VALUE ALUT_exit(VALUE self) {
  ALboolean b = alutExit();
  return albool2rbbool(b);
}

/// ALUT::major_version : ALint
static VALUE ALUT_get_major_version(VALUE self) {
  ALint v = alutGetMajorVersion();
  return INT2FIX(v);
}

/// ALUT::minor_version : ALint
static VALUE ALUT_get_minor_version(VALUE self) {
  ALint v = alutGetMinorVersion();
  return INT2FIX(v);
}

/// ALUT::mime_types(loader : ALenum) : String
static VALUE ALUT_get_mime_types(VALUE self, VALUE loader) {
  ALenum enLoader = NUM2INT(loader);
  const char* s = alutGetMIMETypes(enLoader);
  return rb_str_new2(s);
}

/// ALUT::init : ALboolean
static VALUE ALUT_init(VALUE self) {
  ALboolean b = alutInit(NULL, NULL);
  return albool2rbbool(b);
}

/// ALUT::init_without_context : ALboolean
static VALUE ALUT_init_without_context(VALUE self) {
  ALboolean b = alutInitWithoutContext(NULL, NULL);
  return albool2rbbool(b);
}

// module functions
static void define_ALUT_module_funcs() {
  /// ALUT::init_without_context : ALboolean
  rb_define_module_function(vALUT, "init_without_context", &ALUT_init_without_context, 0);

  /// ALUT::init : ALboolean
  rb_define_module_function(vALUT, "init", &ALUT_init, 0);

  /// ALUT::get_error : ALenum
  rb_define_module_function(vALUT, "get_error", &ALUT_get_error, 0);

  /// ALUT::get_error_string(err : ALenum) : String
  rb_define_module_function(vALUT, "get_error_string", &ALUT_get_error_string, 1);

  /// ALUT::sleep(duration : ALfloat) : Boolean
  rb_define_module_function(vALUT, "sleep", &ALUT_sleep, 1);

  /// ALUT::exit : Boolean
  rb_define_module_function(vALUT, "exit", &ALUT_exit, 0);

  /// ALUT::major_version : ALint
  rb_define_module_function(vALUT, "major_version", &ALUT_get_major_version, 0);

  /// ALUT::minor_version : ALint
  rb_define_module_function(vALUT, "minor_version", &ALUT_get_minor_version, 0);

  /// ALUT::mime_types(loader : ALenum) : String
  rb_define_module_function(vALUT, "mime_types", &ALUT_get_mime_types, 1);
}

///
void setup_module_ALUT() {
  vALUT = rb_define_module("ALUT");
  // version constants
  define_ALUT_version_consts();
  // errors constants
  define_ALUT_error_consts();
  // waveform constants
  define_ALUT_waveform_consts();
  // loader constants
  define_ALUT_loader_consts();
  // module functions
  define_ALUT_module_funcs();

}
