#include "ruby.h"
#include "openal.h"
#include "openal_al.h"
#include "AL/al.h"
#include "AL/alc.h"

/// module privates
static VALUE __arContextRegs;
static VALUE __arDeviceRegs;

/// module values
VALUE vALC;

/// class values
VALUE vALC_Device;
VALUE vALC_Context;
VALUE vALC_CaptureDevice;

/// ALC: error constants
VALUE vALC_NO_ERROR = INT2FIX(ALC_NO_ERROR);
VALUE vALC_INVALID_DEVICE = INT2FIX(ALC_INVALID_DEVICE);
VALUE vALC_INVALID_CONTEXT  = INT2FIX(ALC_INVALID_CONTEXT);
VALUE vALC_INVALID_ENUM = INT2FIX(ALC_INVALID_ENUM);
VALUE vALC_INVALID_VALUE  = INT2FIX(ALC_INVALID_VALUE);
VALUE vALC_OUT_OF_MEMORY  = INT2FIX(ALC_OUT_OF_MEMORY);

static void define_ALC_error_consts() {
  rb_define_const(vALC, "NO_ERROR", vALC_NO_ERROR);
  rb_define_const(vALC, "INVALID_DEVICE", vALC_INVALID_DEVICE);
  rb_define_const(vALC, "INVALID_CONTEXT", vALC_INVALID_CONTEXT);
  rb_define_const(vALC, "INVALID_ENUM", vALC_INVALID_ENUM);
  rb_define_const(vALC, "INVALID_VALUE", vALC_INVALID_VALUE);
  rb_define_const(vALC, "OUT_OF_MEMORY", vALC_OUT_OF_MEMORY);
}

/// ALC: state constants
VALUE vALC_DEFAULT_DEVICE_SPECIFIER = INT2FIX(ALC_DEFAULT_DEVICE_SPECIFIER);
VALUE vALC_CAPTURE_DEFAULT_DEVICE_SPECIFIER = INT2FIX(ALC_CAPTURE_DEFAULT_DEVICE_SPECIFIER);
VALUE vALC_DEVICE_SPECIFIER = INT2FIX(ALC_DEVICE_SPECIFIER);
VALUE vALC_CAPTURE_DEVICE_SPECIFIER = INT2FIX(ALC_CAPTURE_DEVICE_SPECIFIER);
VALUE vALC_EXTENSIONS = INT2FIX(ALC_EXTENSIONS);
VALUE vALC_MAJOR_VERSION  = INT2FIX(ALC_MAJOR_VERSION);
VALUE vALC_MINOR_VERSION  = INT2FIX(ALC_MINOR_VERSION);
VALUE vALC_ATTRIBUTES_SIZE  = INT2FIX(ALC_ATTRIBUTES_SIZE);
VALUE vALC_ALL_ATTRIBUTES = INT2FIX(ALC_ALL_ATTRIBUTES);

static void define_ALC_state_consts() {
  rb_define_const(vALC, "DEFAULT_DEVICE_SPECIFIER", vALC_DEFAULT_DEVICE_SPECIFIER);
  rb_define_const(vALC, "CAPTURE_DEFAULT_DEVICE_SPECIFIER", vALC_CAPTURE_DEFAULT_DEVICE_SPECIFIER);
  rb_define_const(vALC, "DEVICE_SPECIFIER", vALC_DEVICE_SPECIFIER);
  rb_define_const(vALC, "CAPTURE_DEVICE_SPECIFIER", vALC_CAPTURE_DEVICE_SPECIFIER);
  rb_define_const(vALC, "EXTENSIONS", vALC_EXTENSIONS);
  rb_define_const(vALC, "MAJOR_VERSION", vALC_MAJOR_VERSION);
  rb_define_const(vALC, "MINOR_VERSION", vALC_MINOR_VERSION);
  rb_define_const(vALC, "ATTRIBUTES_SIZE", vALC_ATTRIBUTES_SIZE);
  rb_define_const(vALC, "ALL_ATTRIBUTES", vALC_ALL_ATTRIBUTES);
}

/// ALC: opts constants
VALUE vALC_FREQUENCY  = INT2FIX(ALC_FREQUENCY);
VALUE vALC_SYNC = INT2FIX(ALC_SYNC);
VALUE vALC_REFRESH  = INT2FIX(ALC_REFRESH);
VALUE vALC_MONO_SOURCES = INT2FIX(ALC_MONO_SOURCES);
VALUE vALC_STEREO_SOURCES = INT2FIX(ALC_STEREO_SOURCES);

static void define_ALC_opts_consts() {
  rb_define_const(vALC, "FREQUENCY", vALC_FREQUENCY);
  rb_define_const(vALC, "SYNC", vALC_SYNC);
  rb_define_const(vALC, "REFRESH", vALC_REFRESH);
  rb_define_const(vALC, "MONO_SOURCES", vALC_MONO_SOURCES);
  rb_define_const(vALC, "STEREO_SOURCES", vALC_STEREO_SOURCES);
}

static void __ALC_Device_free(ALCdevice* device) {
  alcCloseDevice(device);
}

/// ALC::Device#new
static VALUE ALC_Device_new(int argc, VALUE* argv, VALUE klass) {
  VALUE self;
  char* s = NULL;
  //if (!NIL_P(argv[0])) s = RSTRING_PTR(argv[0]);
  ALCdevice* device = alcOpenDevice(s);
  if ( NULL == device ) return Qnil;
  self = Data_Wrap_Struct(vALC_Device, 0, __ALC_Device_free, device);
  rb_obj_call_init(self, argc, argv);
  return self;
}

/// ALC::Device#initialize
static VALUE ALC_Device_initialize(int argc, VALUE* argv, VALUE self) {
  rb_ary_push(__arDeviceRegs, self);
  return self;
}

/// ALC::Device#extension_present?(extname)
static VALUE ALC_Device_extension_present_p(VALUE self, VALUE extname) {
  ALboolean rslt;
  const char* s = NULL;
  ALCdevice* d = NULL;
  // device
  Data_Get_Struct(self, ALCdevice, d);
  // extname
  Check_Type(extname, T_STRING);
  s = RSTRING_PTR(extname);
  //
  rslt = alcIsExtensionPresent(d, s);
  return albool2rbbool(rslt);
}

/// ALC::Device#enum_value_of(enumname)
static VALUE ALC_Device_enum_value_of(VALUE self, VALUE enumname) {
  const char* str = NULL;
  ALCdevice* d = NULL;
  // device
  Data_Get_Struct(self, ALCdevice, d);
  // enum-name
  Check_Type(enumname, T_STRING);
  str = RSTRING_PTR(enumname);
  //
  return INT2FIX(alcGetEnumValue(d, str));

}

/// ALC::Device#get_error
static VALUE ALC_Device_get_error(VALUE self) {
  ALCdevice* d = NULL;
  ALenum e;
  Data_Get_Struct(self, ALCdevice, d);
  e = alcGetError(d);
  return INT2FIX(e);
}

/// ALC::Device#string(enum)
static VALUE ALC_Device_get_string(VALUE self, VALUE en) {
  ALenum e;
  ALCdevice* d = NULL;
  // device
  Data_Get_Struct(self, ALCdevice, d);
  // enum
  e = NUM2INT(en);
  //
  return rb_str_new2(alcGetString(d, e));
}

static VALUE ALC_Device_to_s(VALUE self) {
  const long slen = 4096;
  char s[4096];
  ALCdevice* p;
  Data_Get_Struct(self, ALCdevice, p);
  snprintf(s, slen, "#<ALC::Device@%p>", p);
  return rb_str_new2(s);
}

static void define_ALC_Device_methods() {
  /// ALC::Device#new
  rb_define_singleton_method(vALC_Device, "new", ALC_Device_new, -1);
  /// ALC::Device#initialize
  rb_define_method(vALC_Device, "initialize", ALC_Device_initialize, -1);

  // error
  /// ALC::device#get_error
  rb_define_method(vALC_Device, "get_error", ALC_Device_get_error, 0);

  // extensions
  /// ALC::Device#extension_present?(extname)
  rb_define_method(vALC_Device, "extension_present?", ALC_Device_extension_present_p, 1);
  /// ALC::Device#enum_value_of(enumname)
  rb_define_method(vALC_Device, "enum_value_of", ALC_Device_enum_value_of, 1);

  // queries, states
  /// ALC::Device#string(enumname)
  rb_define_method(vALC_Device, "string", ALC_Device_get_string, 1);
  ///FIXME: ALC::Device#integers(enumname)

  // ALC::Device#to_s
  rb_define_method(vALC_Device, "to_s", ALC_Device_to_s, 0);
}

static void setup_class_ALC_Device() {
  __arDeviceRegs = rb_ary_new();
  vALC_Device = rb_define_class_under(vALC, "Device", rb_cObject);
  define_ALC_Device_methods();
}


static void __ALC_Context_free(ALCcontext* ctx) {
  alcDestroyContext(ctx);
}

/// +ALC::Context#new
static VALUE ALC_Context_new(int argc, VALUE* argv, VALUE klass) {
  VALUE self;
  ALCcontext* ctx = NULL;
  ALCdevice* dvc = NULL;
  // device
  Data_Get_Struct(argv[0], ALCdevice, dvc);
  // FIXME: accept args for opts
  ctx = alcCreateContext(dvc, NULL);
  if ( NULL == ctx ) return Qnil;
  self = Data_Wrap_Struct(vALC_Context, 0, __ALC_Context_free, ctx);
  rb_obj_call_init(self, argc, argv);
  return self;
}

/// ALC::Context#initialize
static VALUE ALC_Context_initialize(int argc, VALUE* argv, VALUE self) {
  rb_ary_push(__arContextRegs, self);
  return self;
}

/// +ALC::Context#current
static VALUE ALC_Context_get_current(VALUE self) {
  ALCcontext* ctx = alcGetCurrentContext();
  ALCcontext* ctx2;
  long len = RARRAY_LEN(__arContextRegs);
  long n;
  VALUE v;
  if ( NULL == ctx ) return Qnil;
  for ( n = 0 ; n < len ; n ++ ) {
    v = rb_ary_entry(__arContextRegs, n);
    ctx2 = NULL;
    Data_Get_Struct(v, ALCcontext, ctx2);
    if ( ctx2 == ctx ) return v;
  }
  return Qnil;
}

/// +ALC::Context#current=(context)
static VALUE ALC_Context_set_current(VALUE self, VALUE context) {
  ALCcontext* ctx;
  ALCboolean b;
  Data_Get_Struct(context, ALCcontext, ctx);
  b = alcMakeContextCurrent(ctx);
  return albool2rbbool(b);
}

/// ALC::Context#make_current
static VALUE ALC_Context_make_current(VALUE self) {
  ALCcontext* ctx;
  ALCboolean b;
  Data_Get_Struct(self, ALCcontext, ctx);
  b = alcMakeContextCurrent(ctx);
  return albool2rbbool(b);
}

/// ALC::Context#device
static VALUE ALC_Context_get_device(VALUE self) {
  ALCcontext* ctx;
  ALCdevice* dvc;
  ALCdevice* dvc2;
  long len = RARRAY_LEN(__arDeviceRegs);
  long n;
  VALUE v;
  // device?
  Data_Get_Struct(self, ALCcontext, ctx);
  dvc = alcGetContextsDevice(ctx);
  if ( NULL == dvc ) return Qnil;
  for ( n = 0 ; n < len ; n ++ ) {
    v = rb_ary_entry(__arDeviceRegs, n);
    dvc2 = NULL;
    Data_Get_Struct(v, ALCdevice, dvc2);
    if ( dvc2 == dvc ) return v;
  }
  return Qnil;
}

/// ALC::Context#process
static VALUE ALC_Context_process(VALUE self) {
  ALCcontext* ctx;
  Data_Get_Struct(self, ALCcontext, ctx);
  alcProcessContext(ctx);
  return Qnil;
}

/// ALC::Context#suspend
static VALUE ALC_Context_suspend(VALUE self) {
  ALCcontext* ctx;
  Data_Get_Struct(self, ALCcontext, ctx);
  alcSuspendContext(ctx);
  return Qnil;
}

/// ALC::Context#to_s
static VALUE ALC_Context_to_s(VALUE self) {
  const long slen=4096;
  char s[4096];
  ALCcontext* p;
  Data_Get_Struct(self, ALCcontext, p);
  snprintf(s, slen, "#<ALC::Context@%p>", p);
  return rb_str_new2(s);
}

static void define_ALC_Context_methods() {
  /// +ALC::Context#new(device)
  rb_define_singleton_method(vALC_Context, "new", ALC_Context_new, -1);
  /// ALC::Context#initialize(device)
  rb_define_method(vALC_Context, "initialize", ALC_Context_initialize, -1);
  /// +ALC::Context#current=(context)
  rb_define_singleton_method(vALC_Context, "current=", ALC_Context_set_current, 1);
  /// +ALC::Context#current
  rb_define_singleton_method(vALC_Context, "current", ALC_Context_get_current, 0);
  /// ALC::Context#make_current
  rb_define_method(vALC_Context, "make_current", ALC_Context_make_current, 0);
  /// ALC::Context#process
  rb_define_method(vALC_Context, "process", ALC_Context_process, 0);
  /// ALC::Context#suspend
  rb_define_method(vALC_Context, "suspend", ALC_Context_suspend, 0);
  /// ALC::Context#device
  rb_define_method(vALC_Context, "device", ALC_Context_get_device, 0);
  ///FIXME: ALC::Context#destroy
  // ALC::Context#to_s
  rb_define_method(vALC_Context, "to_s", ALC_Context_to_s, 0);
}

static void setup_class_ALC_Context() {
  __arContextRegs = rb_ary_new();
  vALC_Context = rb_define_class_under(vALC, "Context", rb_cObject);
  define_ALC_Context_methods();
}


static void __ALC_CaptureDevice_free(ALCdevice* dvc) {
  alcCaptureCloseDevice(dvc);
}

/// - ALC::CaptureDevice#initialize
static VALUE ALC_CaptureDevice_initialize(VALUE self) {
  return self;
}

/// + ALC::CaptureDeivce#new(device_name, frequency : Fixnum, format : ALenum, bufsize : Fixnum)
static VALUE ALC_CaptureDevice_new(VALUE klass, VALUE vDvcNm, VALUE vFreq, VALUE vFmt, VALUE vBufSize) {
  VALUE self;
  ALCdevice* dvc;
  // params
  const char* dvcnm = NULL;
  if ( !NIL_P(vDvcNm) ) {
    Check_Type(vDvcNm, T_STRING);
    dvcnm = RSTRING_PTR(vDvcNm);
  }
  ALuint freq = NUM2UINT(vFreq);
  ALenum fmt = NUM2INT(vFmt);
  ALsizei bufsize = NUM2LONG(vBufSize);
  // device
  dvc = alcCaptureOpenDevice(dvcnm, freq, fmt, bufsize);
  // device->val
  if (NULL == dvc) return Qnil;
  else {
    self = Data_Wrap_Struct(vALC_CaptureDevice, 0, __ALC_CaptureDevice_free, dvc);
    //rb_obj_call_init(self, argc, argv);
    ALC_CaptureDevice_initialize(self);
    return self;
  }
}

/// - ALC::CaptureDevice#start
static VALUE ALC_CaptureDevice_start(VALUE self) {
  ALCdevice* p;
  Data_Get_Struct(self, ALCdevice, p);
  alcCaptureStart(p);
  return Qnil;
}

/// - ALC::CaptureDevice#stop
static VALUE ALC_CaptureDevice_stop(VALUE self) {
  ALCdevice* p;
  Data_Get_Struct(self, ALCdevice, p);
  alcCaptureStop(p);
  return Qnil;
}

/// - ALC::CaptureDevice#to_s
static VALUE ALC_CaptureDevice_to_s(VALUE self) {
  const long slen=4096;
  char s[4096];
  ALCdevice* p;
  Data_Get_Struct(self, ALCdevice, p);
  snprintf(s, slen, "ALC::CaptureDevice@%p", p);
  return rb_str_new2(s);
}


static void define_ALC_CaptureDevice_methods() {
  /// + ALC::CaptureDeivce#new(device_name, frequency : Fixnum, format : ALenum, bufsize : Fixnum)
  rb_define_singleton_method(vALC_CaptureDevice, "new", ALC_CaptureDevice_new, 4);
  /// - ALC::CaptureDevice#initialize
  rb_define_method(vALC_CaptureDevice, "initialize", ALC_CaptureDevice_initialize, 0);
  /// - ALC::CaptureDevice#start
  rb_define_method(vALC_CaptureDevice, "start", ALC_CaptureDevice_start, 0);
  /// - ALC::CaptureDevice#stop
  rb_define_method(vALC_CaptureDevice, "stop", ALC_CaptureDevice_stop, 0);
  /// - ALC::CaptureDevice#to_s
  rb_define_method(vALC_CaptureDevice, "to_s", ALC_CaptureDevice_to_s, 0);
  //TODO: - ALC::CaptureDevice#retrive???
}

static void setup_class_ALC_CaptureDevice() {
  vALC_CaptureDevice = rb_define_class_under(vALC, "CaptureDevice", rb_cObject);
  define_ALC_CaptureDevice_methods();
}

void setup_module_ALC() {
  vALC = rb_define_module("ALC");
  // constants: ALC
  define_ALC_error_consts();
  define_ALC_state_consts();
  define_ALC_opts_consts();
  // module functions: ALC
  // ALC::Device
  setup_class_ALC_Device();
  // ALC::Context
  setup_class_ALC_Context();
  // ALC::CaptureDevice
  setup_class_ALC_CaptureDevice();
}
