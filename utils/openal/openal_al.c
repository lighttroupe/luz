#include "ruby.h"
#include "openal.h"
#include "openal_al.h"
#include "AL/al.h"
#include "AL/alc.h"
#include "AL/alut.h"
#include "efx.h"

#include <vorbis/codec.h>
#include <vorbis/vorbisfile.h>

// OpenAL Effect function pointers
LPALGENEFFECTS alGenEffects;
LPALDELETEEFFECTS alDeleteEffects;
LPALISEFFECT alIsEffect;
LPALEFFECTI alEffecti;
LPALEFFECTIV alEffectiv;
LPALEFFECTF alEffectf;
LPALEFFECTFV alEffectfv;
LPALGETEFFECTI alGetEffecti;
LPALGETEFFECTIV alGetEffectiv;
LPALGETEFFECTF alGetEffectf;
LPALGETEFFECTFV alGetEffectfv;

//Filter objects
LPALGENFILTERS alGenFilters;
LPALDELETEFILTERS alDeleteFilters;
LPALISFILTER alIsFilter;
LPALFILTERI alFilteri;
LPALFILTERIV alFilteriv;
LPALFILTERF alFilterf;
LPALFILTERFV alFilterfv;
LPALGETFILTERI alGetFilteri;
LPALGETFILTERIV alGetFilteriv;
LPALGETFILTERF alGetFilterf;
LPALGETFILTERFV alGetFilterfv;

// Auxiliary slot object
LPALGENAUXILIARYEFFECTSLOTS alGenAuxiliaryEffectSlots;
LPALDELETEAUXILIARYEFFECTSLOTS alDeleteAuxiliaryEffectSlots;
LPALISAUXILIARYEFFECTSLOT alIsAuxiliaryEffectSlot;
LPALAUXILIARYEFFECTSLOTI alAuxiliaryEffectSloti;
LPALAUXILIARYEFFECTSLOTIV alAuxiliaryEffectSlotiv;
LPALAUXILIARYEFFECTSLOTF alAuxiliaryEffectSlotf;
LPALAUXILIARYEFFECTSLOTFV alAuxiliaryEffectSlotfv;
LPALGETAUXILIARYEFFECTSLOTI alGetAuxiliaryEffectSloti;
LPALGETAUXILIARYEFFECTSLOTIV alGetAuxiliaryEffectSlotiv;
LPALGETAUXILIARYEFFECTSLOTF alGetAuxiliaryEffectSlotf;
LPALGETAUXILIARYEFFECTSLOTFV alGetAuxiliaryEffectSlotfv;

void lookup_functions()
{
	alGenEffects = (LPALGENEFFECTS)alGetProcAddress("alGenEffects");
	alDeleteEffects = (LPALDELETEEFFECTS )alGetProcAddress("alDeleteEffects");
	alIsEffect = (LPALISEFFECT )alGetProcAddress("alIsEffect");
	alEffecti = (LPALEFFECTI)alGetProcAddress("alEffecti");
	alEffectiv = (LPALEFFECTIV)alGetProcAddress("alEffectiv");
	alEffectf = (LPALEFFECTF)alGetProcAddress("alEffectf");
	alEffectfv = (LPALEFFECTFV)alGetProcAddress("alEffectfv");
	alGetEffecti = (LPALGETEFFECTI)alGetProcAddress("alGetEffecti");
	alGetEffectiv = (LPALGETEFFECTIV)alGetProcAddress("alGetEffectiv");
	alGetEffectf = (LPALGETEFFECTF)alGetProcAddress("alGetEffectf");
	alGetEffectfv = (LPALGETEFFECTFV)alGetProcAddress("alGetEffectfv");
	alGenFilters = (LPALGENFILTERS)alGetProcAddress("alGenFilters");
	alDeleteFilters = (LPALDELETEFILTERS)alGetProcAddress("alDeleteFilters");
	alIsFilter = (LPALISFILTER)alGetProcAddress("alIsFilter");
	alFilteri = (LPALFILTERI)alGetProcAddress("alFilteri");
	alFilteriv = (LPALFILTERIV)alGetProcAddress("alFilteriv");
	alFilterf = (LPALFILTERF)alGetProcAddress("alFilterf");
	alFilterfv = (LPALFILTERFV)alGetProcAddress("alFilterfv");
	alGetFilteri = (LPALGETFILTERI )alGetProcAddress("alGetFilteri");
	alGetFilteriv = (LPALGETFILTERIV )alGetProcAddress("alGetFilteriv");
	alGetFilterf = (LPALGETFILTERF )alGetProcAddress("alGetFilterf");
	alGetFilterfv = (LPALGETFILTERFV )alGetProcAddress("alGetFilterfv");
	alGenAuxiliaryEffectSlots = (LPALGENAUXILIARYEFFECTSLOTS)alGetProcAddress("alGenAuxiliaryEffectSlots");
	alDeleteAuxiliaryEffectSlots = (LPALDELETEAUXILIARYEFFECTSLOTS)alGetProcAddress("alDeleteAuxiliaryEffectSlots");
	alIsAuxiliaryEffectSlot = (LPALISAUXILIARYEFFECTSLOT)alGetProcAddress("alIsAuxiliaryEffectSlot");
	alAuxiliaryEffectSloti = (LPALAUXILIARYEFFECTSLOTI)alGetProcAddress("alAuxiliaryEffectSloti");
	alAuxiliaryEffectSlotiv = (LPALAUXILIARYEFFECTSLOTIV)alGetProcAddress("alAuxiliaryEffectSlotiv");
	alAuxiliaryEffectSlotf = (LPALAUXILIARYEFFECTSLOTF)alGetProcAddress("alAuxiliaryEffectSlotf");
	alAuxiliaryEffectSlotfv = (LPALAUXILIARYEFFECTSLOTFV)alGetProcAddress("alAuxiliaryEffectSlotfv");
	alGetAuxiliaryEffectSloti = (LPALGETAUXILIARYEFFECTSLOTI)alGetProcAddress("alGetAuxiliaryEffectSloti");
	alGetAuxiliaryEffectSlotiv = (LPALGETAUXILIARYEFFECTSLOTIV)alGetProcAddress("alGetAuxiliaryEffectSlotiv");
	alGetAuxiliaryEffectSlotf = (LPALGETAUXILIARYEFFECTSLOTF)alGetProcAddress("alGetAuxiliaryEffectSlotf");
	alGetAuxiliaryEffectSlotfv = (LPALGETAUXILIARYEFFECTSLOTFV)alGetProcAddress("alGetAuxiliaryEffectSlotfv");
}

/// module values
VALUE vAL;

/// class values
VALUE vAL_Listener;
VALUE vAL_SampleData;
VALUE vAL_Buffer;
VALUE vAL_Source;
VALUE vAL_Filter;
VALUE vAL_AuxiliaryEffectSlot;
VALUE vAL_Effect;

/// AL: error constants
VALUE vAL_NO_ERROR  = INT2FIX(AL_NO_ERROR);
VALUE vAL_INVALID_NAME  = INT2FIX(AL_INVALID_NAME);
VALUE vAL_INVALID_ENUM  = INT2FIX(AL_INVALID_ENUM);
VALUE vAL_INVALID_VALUE = INT2FIX(AL_INVALID_VALUE);
VALUE vAL_INVALID_OPERATION = INT2FIX(AL_INVALID_OPERATION);
VALUE vAL_OUT_OF_MEMORY = INT2FIX(AL_OUT_OF_MEMORY);

/// AL: state constants
VALUE vAL_DOPPLER_FACTOR  = INT2FIX(AL_DOPPLER_FACTOR);
VALUE vAL_SPEED_OF_SOUND  = INT2FIX(AL_SPEED_OF_SOUND);
VALUE vAL_DISTANCE_MODEL  = INT2FIX(AL_DISTANCE_MODEL);

/// AL: spec constants
VALUE vAL_VENDOR  = INT2FIX(AL_VENDOR);
VALUE vAL_VERSION = INT2FIX(AL_VERSION);
VALUE vAL_RENDERER  = INT2FIX(AL_RENDERER);
VALUE vAL_EXTENSIONS  = INT2FIX(AL_EXTENSIONS);

/// AL: distance model constants
VALUE vAL_INVERSE_DISTANCE  = INT2FIX(AL_INVERSE_DISTANCE);
VALUE vAL_INVERSE_DISTANCE_CLAMPED  = INT2FIX(AL_INVERSE_DISTANCE_CLAMPED);
VALUE vAL_LINEAR_DISTANCE = INT2FIX(AL_LINEAR_DISTANCE);
VALUE vAL_LINEAR_DISTANCE_CLAMPED = INT2FIX(AL_LINEAR_DISTANCE_CLAMPED);
VALUE vAL_EXPONENT_DISTANCE = INT2FIX(AL_EXPONENT_DISTANCE);
VALUE vAL_EXPONENT_DISTANCE_CLAMPED = INT2FIX(AL_EXPONENT_DISTANCE_CLAMPED);
VALUE vAL_NONE  = INT2FIX(AL_NONE);

/// AL: format constants
VALUE vAL_FORMAT_MONO8  = INT2FIX(AL_FORMAT_MONO8);
VALUE vAL_FORMAT_MONO16 = INT2FIX(AL_FORMAT_MONO16);
VALUE vAL_FORMAT_STEREO8  = INT2FIX(AL_FORMAT_STEREO8);
VALUE vAL_FORMAT_STEREO16 = INT2FIX(AL_FORMAT_STEREO16);

/// AL: source type constants
VALUE vAL_UNDETERMINED = INT2FIX(AL_UNDETERMINED);
VALUE vAL_STATIC        = INT2FIX(AL_STATIC);
VALUE vAL_STREAMING     = INT2FIX(AL_STREAMING);

/// AL: filter type constants
VALUE vAL_FILTER_LOWPASS = INT2FIX(AL_FILTER_LOWPASS);
VALUE vAL_FILTER_NULL = INT2FIX(AL_FILTER_NULL);

/// AL: effect type constants
VALUE vAL_EFFECT_NULL = INT2FIX(AL_EFFECT_NULL);
VALUE vAL_EFFECT_REVERB = INT2FIX(AL_EFFECT_REVERB);

/// AL::get_error
static VALUE AL_get_error(VALUE self) {
  return INT2FIX(alGetError());
}

/// AL::extension_present?(extname)
static VALUE AL_extension_present_p(VALUE self, VALUE extension_name) {
  ALboolean rslt;
  const char* str;
  Check_Type(extension_name, T_STRING);
  str = RSTRING_PTR(extension_name);
  rslt = alIsExtensionPresent(str);
  return albool2rbbool(rslt);
}

/// AL::enum_value_of(enum_name)
static VALUE AL_enum_value_of(VALUE self, VALUE enum_name) {
  const char* str;
  Check_Type(enum_name, T_STRING);
  str = RSTRING_PTR(enum_name);
  return INT2FIX(alGetEnumValue(str));
}

/// AL::enable(capacity)
static VALUE AL_enable(VALUE self, VALUE capacity) {
  ALenum c = NUM2INT(capacity);
  alEnable(c);
  return Qnil;
}

/// AL::disable(capacity)
static VALUE AL_disable(VALUE self, VALUE capacity) {
  ALenum c = NUM2INT(capacity);
  alDisable(c);
  return Qnil;
}

/// AL::enable?
static VALUE AL_enable_p(VALUE self, VALUE capacity) {
  ALenum c = NUM2INT(capacity);
  ALboolean rslt = alIsEnabled(c);
  return albool2rbbool(rslt);
}

/// AL::boolean
static VALUE AL_get_boolean(VALUE self, VALUE capacity) {
  ALenum c = NUM2INT(capacity);
  ALboolean rslt = alGetBoolean(c);
  return albool2rbbool(rslt);
}

/// AL::float
static VALUE AL_get_float(VALUE self, VALUE capacity) {
  ALenum c = NUM2INT(capacity);
  ALfloat f = alGetFloat(c);
  return rb_float_new((double)f);
}

/// AL::double
static VALUE AL_get_double(VALUE self, VALUE capacity) {
  ALenum c = NUM2INT(capacity);
  ALdouble d = alGetDouble(c);
  return rb_float_new(d);
}

/// AL::integer
static VALUE AL_get_integer(VALUE self, VALUE capacity) {
  ALenum c = NUM2INT(capacity);
  ALint i = alGetInteger(c);
  return INT2FIX(i);
}

/// AL::string
static VALUE AL_get_string(VALUE self, VALUE capacity) {
  ALenum c = NUM2INT(capacity);
  const char* s = alGetString(c);
  if (NULL == s) return Qnil;
  else return rb_str_new2(s);
}

/// AL::distance_model=(val)
static VALUE AL_set_distance_model(VALUE self, VALUE v) {
  ALenum e = NUM2INT(v);
  alDistanceModel(e);
  return Qnil;
}

/// AL::doppler_factor=(val)
static VALUE AL_set_doppler_factor(VALUE self, VALUE v) {
  ALfloat f = (ALfloat) NUM2DBL(v);
  alDopplerFactor(f);
  return Qnil;
}

/// AL::doppler_velocity=(val)
static VALUE AL_set_doppler_velocity(VALUE self, VALUE v) {
  ALfloat f = (ALfloat) NUM2DBL(v);
  alDopplerVelocity(f);
  return Qnil;
}

/// AL::speed_of_sound=(val)
static VALUE AL_set_speed_of_sound(VALUE self, VALUE v) {
  ALfloat f = (ALfloat) NUM2DBL(v);
  alSpeedOfSound(f);
  return Qnil;
}

static void define_AL_error_consts() {
  rb_define_const(vAL, "NO_ERROR", vAL_NO_ERROR);
  rb_define_const(vAL, "INVALID_NAME", vAL_INVALID_NAME);
  rb_define_const(vAL, "INVALID_ENUM", vAL_INVALID_ENUM);
  rb_define_const(vAL, "INVALID_VALUE", vAL_INVALID_VALUE);
  rb_define_const(vAL, "INVALID_OPERATION", vAL_INVALID_OPERATION);
  rb_define_const(vAL, "OUT_OF_MEMORY", vAL_OUT_OF_MEMORY);
}

static void define_AL_state_consts() {
  rb_define_const(vAL, "DOPPLER_FACTOR", vAL_DOPPLER_FACTOR);
  rb_define_const(vAL, "SPEED_OF_SOUND", vAL_SPEED_OF_SOUND);
  rb_define_const(vAL, "DISTANCE_MODEL", vAL_DISTANCE_MODEL);
}

static void define_AL_spec_consts() {
  rb_define_const(vAL, "VENDOR", vAL_VENDOR);
  rb_define_const(vAL, "VERSION", vAL_VERSION);
  rb_define_const(vAL, "RENDERER", vAL_RENDERER);
  rb_define_const(vAL, "EXTENSIONS", vAL_EXTENSIONS);
}

static void define_AL_distance_model_consts() {
  rb_define_const(vAL, "INVERSE_DISTANCE", vAL_INVERSE_DISTANCE);
  rb_define_const(vAL, "INVERSE_DISTANCE_CLAMPED", vAL_INVERSE_DISTANCE_CLAMPED);
  rb_define_const(vAL, "LINEAR_DISTANCE", vAL_LINEAR_DISTANCE);
  rb_define_const(vAL, "LINEAR_DISTANCE_CLAMPED", vAL_LINEAR_DISTANCE_CLAMPED);
  rb_define_const(vAL, "EXPONENT_DISTANCE", vAL_EXPONENT_DISTANCE);
  rb_define_const(vAL, "EXPONENT_DISTANCE_CLAMPED", vAL_EXPONENT_DISTANCE_CLAMPED);
  rb_define_const(vAL, "NONE", vAL_NONE);
}

static void define_AL_format_consts() {
  rb_define_const(vAL, "FORMAT_MONO8", vAL_FORMAT_MONO8);
  rb_define_const(vAL, "FORMAT_MONO16", vAL_FORMAT_MONO16);
  rb_define_const(vAL, "FORMAT_STEREO8", vAL_FORMAT_STEREO8);
  rb_define_const(vAL, "FORMAT_STEREO16", vAL_FORMAT_STEREO16);
}

static void define_AL_source_type_consts() {
  rb_define_const(vAL, "UNDETERMINED", vAL_UNDETERMINED);
  rb_define_const(vAL, "STATIC", vAL_STATIC);
  rb_define_const(vAL, "STREAMING", vAL_STREAMING);
}

static void define_AL_error_funcs() {
  // error handling.
  /// AL::get_error
  rb_define_module_function(vAL, "get_error", &AL_get_error, 0);
}

static void define_AL_exts_funcs() {
  // extension.
  /// AL::extension_present?(extname)
  rb_define_module_function(vAL, "extension_present?", &AL_extension_present_p, 1);
  /// AL::enum_value_of(enum_name)
  rb_define_module_function(vAL, "enum_value_of", &AL_enum_value_of, 1);
}

static void define_AL_state_funcs() {
  // states
  /// AL::enable(capacity)
  rb_define_module_function(vAL, "enable", &AL_enable, 1);
  /// AL::disable(capacity)
  rb_define_module_function(vAL, "disable", &AL_disable, 1);
  /// AL::enable?(capacity)
  rb_define_module_function(vAL, "enable?", &AL_enable_p, 1);
  /// AL::boolean(param)
  rb_define_module_function(vAL, "boolean", &AL_get_boolean, 1);
  /// AL::double(param)
  rb_define_module_function(vAL, "double", &AL_get_double, 1);
  /// AL::float(param)
  rb_define_module_function(vAL, "float", &AL_get_float, 1);
  /// AL::integer(param)
  rb_define_module_function(vAL, "integer", &AL_get_integer, 1);
  /// FIXME: AL::booleans(param)
  //rb_define_module_function(vAL, "booleans", &AL_get_booleans, 1);
  /// FIXME: AL::doubles(param)
  //rb_define_module_function(vAL, "doubles", &AL_get_doubles, 1);
  /// FIXME: AL::floats(param)
  //rb_define_module_function(vAL, "floats", &AL_get_floats, 1);
  /// FIXME: AL::integers(param)
  //rb_define_module_function(vAL, "integers", &AL_get_integers, 1);
  /// AL::string(param)
  rb_define_module_function(vAL, "string", &AL_get_string, 1);

  /// TODO: getters!
  /// AL::distance_model=(val)
  rb_define_module_function(vAL, "distance_model=", &AL_set_distance_model, 1);
  /// AL::doppler_factor=(val)
  rb_define_module_function(vAL, "doppler_factor=", &AL_set_doppler_factor, 1);
  /// AL::doppler_velocity=(val)
  rb_define_module_function(vAL, "doppler_velocity=", &AL_set_doppler_velocity, 1);
  /// AL::speed_of_sound=(val)
  rb_define_module_function(vAL, "speed_of_sound=", &AL_set_speed_of_sound, 1);
}

/// + AL::Listener.orientation rw:([fx, fy, fz, ux, uy, uz])
static VALUE AL_Listener_get_orientation(VALUE self) {
  ALfloat v[] = {0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f};
  VALUE ary;
  ary = rb_ary_new();
  alGetListenerfv(AL_ORIENTATION, v);
  ARRAY2RARRAY(v, ary, 6, rb_float_new);
  return ary;
}

static VALUE AL_Listener_set_orientation(VALUE self, VALUE a) {
  ALfloat vec[6];
  RARRAY2ARRAY(a, vec, 6, NUM2DBL);
  alListenerfv(AL_ORIENTATION, vec);
  return Qnil;
}

/// + AL::Listener.gain rw:(v)
static VALUE AL_Listener_get_gain(VALUE self) {
  ALfloat n = 0.0f;
  alGetListenerf(AL_GAIN, &n);
  return rb_float_new(n);
}

static VALUE AL_Listener_set_gain(VALUE self, VALUE gain) {
  ALfloat n = (float) NUM2DBL(gain);
  alListenerf(AL_GAIN, n);
  return Qnil;
}

/// + AL::Listener.position rw:([x, y, z])
static VALUE AL_Listener_get_position(VALUE self) {
  ALfloat v[] = {0.0f, 0.0f, 0.0f};
  VALUE ary;
  ary = rb_ary_new();
  alGetListenerfv(AL_POSITION, v);
  ARRAY2RARRAY(v, ary, 3, rb_float_new);
  return ary;
}

static VALUE AL_Listener_set_position(VALUE self, VALUE a) {
  ALfloat vec[3];
  RARRAY2ARRAY(a, vec, 3, NUM2DBL);
  alListenerfv(AL_POSITION, vec);
  return Qnil;
}

/// + AL::Listener.velocity rw:([x, y, z])
static VALUE AL_Listener_get_velocity(VALUE self) {
  ALfloat v[] = {0.0f, 0.0f, 0.0f};
  VALUE ary;
  ary = rb_ary_new();
  alGetListenerfv(AL_VELOCITY, v);
  ARRAY2RARRAY(v, ary, 3, rb_float_new);
  return ary;
}

static VALUE AL_Listener_set_velocity(VALUE self, VALUE a) {
  ALfloat vec[3];
  RARRAY2ARRAY(a, vec, 3, NUM2DBL);
  alListenerfv(AL_VELOCITY, vec);
  return Qnil;
}

static VALUE AL_Listener_to_s(VALUE self) {
  ALfloat gain;
  ALfloat position[3];
  ALfloat velocity[3];
  ALfloat orientation[6];
  const long slen = 4096;
  char s[slen];

  alGetListenerf(AL_GAIN, &gain);
  alGetListenerfv(AL_POSITION, position);
  alGetListenerfv(AL_VELOCITY, velocity);
  alGetListenerfv(AL_ORIENTATION, orientation);

  snprintf(s, slen, "#<AL::Listner{:gain=>%f, :position=>[%f, %f, %f], :orientation=>[%f, %f, %f, %f, %f, %f], :velocity=>[%f, %f, %f]}>",
  gain, position[0], position[1], position[2],
  orientation[0], orientation[1], orientation[2], orientation[3], orientation[4], orientation[5],
  velocity[0], velocity[1], velocity[2]);

  return rb_str_new2(s);
}


static void define_AL_Listener_methods() {
  /// + AL::Listener.orientation rw:([fx, fy, fz, ux, uy, uz])
  rb_define_singleton_method(vAL_Listener, "orientation", AL_Listener_get_orientation, 0);
  rb_define_singleton_method(vAL_Listener, "orientation=", AL_Listener_set_orientation, 1);

  /// + AL::Listener.gain rw:(v)
  rb_define_singleton_method(vAL_Listener, "gain", AL_Listener_get_gain, 0);
  rb_define_singleton_method(vAL_Listener, "gain=", AL_Listener_set_gain, 1);

  /// + AL::Listener.position rw:([x, y, z])
  rb_define_singleton_method(vAL_Listener, "position", AL_Listener_get_position, 0);
  rb_define_singleton_method(vAL_Listener, "position=", AL_Listener_set_position, 1);

  /// + AL::Listener.velocity rw:([x, y, z])
  rb_define_singleton_method(vAL_Listener, "velocity", AL_Listener_get_velocity, 0);
  rb_define_singleton_method(vAL_Listener, "velocity=", AL_Listener_set_velocity, 1);

  /// + AL::Listener.to_s r:String
  rb_define_singleton_method(vAL_Listener, "to_s", AL_Listener_to_s, 0);
}

static void setup_class_AL_Listener() {
  vAL_Listener = rb_define_class_under(vAL, "Listener", rb_cObject);
  define_AL_Listener_methods();
}


al_sample_data_t* AL_SampleData_new() {
  al_sample_data_t* p = NULL;
  p = (al_sample_data_t*)malloc(sizeof(al_sample_data_t));
  memset((void*)p, 0, sizeof(al_sample_data_t));
  return p;
}

void AL_SampleData_free(al_sample_data_t* p) {
  if ( p != NULL ) {
    if ( p->buf != NULL) {
      free((void*)p->buf);
    }
    free((void*)p);
  }
}

/// - AL::SampleData#to_s
static VALUE AL_SampleData_to_s(VALUE self) {
  al_sample_data_t* p = NULL;
  const long slen = 4096;
  char s[slen];
  Data_Get_Struct(self, al_sample_data_t, p);
  snprintf(s, slen, "#<AL::SampleData {buf@%p, :bufsize=>%d, :freq=>%d, :fmt=>%d}@%p>",
    (p->buf), (p->bufsize), (p->freq), (p->fmt), p);
  return rb_str_new2(s);
}

/// - AL::SampleData#buffer_size
static VALUE AL_SampleData_get_buffer_size(VALUE self) {
  al_sample_data_t* p = NULL;
  Data_Get_Struct(self, al_sample_data_t, p);
  return LONG2FIX(p->bufsize);
}

/// - AL::SampleData#format
static VALUE AL_SampleData_get_format(VALUE self) {
  al_sample_data_t* p = NULL;
  Data_Get_Struct(self, al_sample_data_t, p);
  return INT2FIX(p->fmt);
}

/// - AL::SampleData#frequency
static VALUE AL_SampleData_get_frequency(VALUE self) {
  al_sample_data_t* p = NULL;
  Data_Get_Struct(self, al_sample_data_t, p);
  return LONG2FIX(p->freq);
}

/// + helloWorld (alutLoadMemoryHelloWorld)
/*
static VALUE AL_SampleData_helloWorld(VALUE klass) {
  VALUE self;
  al_sample_data_t* p = AL_SampleData_new();
  p->buf = alutLoadMemoryHelloWorld(&(p->fmt), &(p->bufsize), &(p->freq));
  if ( NULL == (p->buf) ) {
    AL_SampleData_free(p);
    return Qnil;
  } else {
    self = Data_Wrap_Struct(vAL_SampleData, 0, AL_SampleData_free, p);
    return self;
  }
}
*/

/// + load_from_file(filename) (alutLoadMemoryFromFile)
static VALUE AL_SampleData_load_from_file(VALUE klass, VALUE vFilename) {
  VALUE self;
  char* filename;
  al_sample_data_t* p;
  Check_Type(vFilename, T_STRING);
  filename = RSTRING_PTR(vFilename);
  p = AL_SampleData_new();
  p->buf = alutLoadMemoryFromFile(filename, &(p->fmt), &(p->bufsize), (ALfloat*)&(p->freq));
  if ( NULL == (p->buf) ) {
    AL_SampleData_free(p);
    return Qnil;
  } else {
    self = Data_Wrap_Struct(vAL_SampleData, 0, AL_SampleData_free, p);
    return self;
  }
}

/// + load_from_string(io) (alutLoadMemoryFromFileImage)
static VALUE AL_SampleData_load_from_string(VALUE klass, VALUE s) {
  VALUE self;
  al_sample_data_t* p;
  Check_Type(s, T_STRING);
  p = AL_SampleData_new();
  p->buf = alutLoadMemoryFromFileImage(
    RSTRING_PTR(s), RSTRING_LEN(s),
    &(p->fmt), &(p->bufsize), (ALfloat*)&(p->freq));
  if ( NULL == (p->buf) ) {
    AL_SampleData_free(p);
    return Qnil;
  } else {
    self = Data_Wrap_Struct(vAL_SampleData, 0, AL_SampleData_free, p);
    return self;
  }
}

static void define_AL_SampleData_methods() {
  /// C-Level SampleData.new
  /// - AL::SampleData#buffer_size
  rb_define_method(vAL_SampleData, "buffer_size", &AL_SampleData_get_buffer_size, 0);
  /// - AL::SampleData#format
  rb_define_method(vAL_SampleData, "format", &AL_SampleData_get_format, 0);
  /// - AL::SampleData#frequency
  rb_define_method(vAL_SampleData, "frequency", &AL_SampleData_get_frequency, 0);
  /// - AL::SampleData#to_s
  rb_define_method(vAL_SampleData, "to_s", &AL_SampleData_to_s, 0);
  /// + load_from_file(filename) (alutLoadMemoryFromFile)
  rb_define_singleton_method(vAL_SampleData, "load_from_file", &AL_SampleData_load_from_file, 1);
  /// + load_from_string(io) (alutLoadMemoryFromFileImage)
  rb_define_singleton_method(vAL_SampleData, "load_from_string", &AL_SampleData_load_from_string, 1);
}

static void setup_class_AL_SampleData() {
  vAL_SampleData = rb_define_class_under(vAL, "SampleData", rb_cObject);
  define_AL_SampleData_methods();
}

/// - AL::Buffer#free
void AL_Buffer_free(ALuint* p) {
  if ( NULL != p ) {
    if ( alIsBuffer(*p) ) {
      alDeleteBuffers(1, p);
    }
    free((void*)p);
  }
}

VALUE AL_Buffer_from_albuf(const ALuint b) {
  ALsizei* p = NULL;
  p = malloc(sizeof(ALsizei));
  *p = b;
  return Data_Wrap_Struct(vAL_Buffer, 0, AL_Buffer_free, p);
}

/// + AL::Buffer#new
static VALUE AL_Buffer_new(VALUE klass) {
  ALuint b;
  alGenBuffers(1, (ALuint*)&b);
  return AL_Buffer_from_albuf(b);
}

/// - AL::Buffer#initialize
static VALUE AL_Buffer_initialize(VALUE self) {
  return self;
}

/// - r: AL::Buffer#frequency : ALint
static VALUE AL_Buffer_get_frequency(VALUE self) {
  ALuint* p;
  ALint v;
  Data_Get_Struct(self, ALuint, p);
  alGetBufferi(*p, AL_FREQUENCY, &v);
  return INT2FIX(v);
}

/// - r: AL::Buffer#size : ALint
static VALUE AL_Buffer_get_size(VALUE self) {
  ALuint* p;
  ALint v;
  Data_Get_Struct(self, ALuint, p);
  alGetBufferi(*p, AL_SIZE, &v);
  return INT2FIX(v);
}

/// - r: AL::Buffer#bits : ALint
static VALUE AL_Buffer_get_bits(VALUE self) {
  ALuint* p;
  ALint v;
  Data_Get_Struct(self, ALuint, p);
  alGetBufferi(*p, AL_BITS, &v);
  return INT2FIX(v);
}

/// - r: AL::Buffer#channels : ALint
static VALUE AL_Buffer_get_channels(VALUE self) {
  ALuint* p;
  ALint v;
  Data_Get_Struct(self, ALuint, p);
  alGetBufferi(*p, AL_CHANNELS, &v);
  return INT2FIX(v);
}

/// + AL::Buffer#load_hello_world # alutCreateBufferHelloWorld
static VALUE AL_Buffer_load_hello_world(VALUE klass) {
  ALuint b = alutCreateBufferHelloWorld();
  return AL_Buffer_from_albuf(b);
}

/// - AL::Buffer#attach(sample_data)
static VALUE AL_Buffer_attach(VALUE self, VALUE vSampleData) {
  ALuint* pBuf;
  al_sample_data_t* pSampleData;
  if ( CLASS_OF(vSampleData) != vAL_SampleData )
    return Qfalse;
  Data_Get_Struct(self, ALuint, pBuf);
  Data_Get_Struct(vSampleData, al_sample_data_t, pSampleData);
  ///FIXME: it doesn't works.
  /*
  alBufferData(*pBuf,
    pSampleData->fmt, pSampleData->buf,
    pSampleData->bufsize, pSampleData->freq);
  */
  return Qtrue;
}

static VALUE AL_Buffer_load_from_data(VALUE klass, VALUE vFormat, VALUE vSampleData, VALUE vFrequency) {
	VALUE self;
	self = AL_Buffer_new(klass);

	ALuint* pBuf;
	Data_Get_Struct(self, ALuint, pBuf);

	ALint format = NUM2INT(vFormat);

	void* data = RSTRING_PTR(vSampleData);		//RSTRING(vSampleData)->ptr;
	ALint size = RSTRING_LEN(vSampleData);		//RSTRING(vSampleData)->len;
	ALint frequency = NUM2INT(vFrequency);

	alBufferData(*pBuf, format, data, size, frequency);

	return self;
}

/// + AL::Buffer#load_waveform(enWave : ALenum, freq : ALfloat, phase : ALfloat, duration : ALfloat)
static VALUE AL_Buffer_load_waveform(VALUE self, VALUE vEnWave, VALUE vFltFreq, VALUE vFltPhase, VALUE vFltDuration) {
  ALenum wave = NUM2INT(vEnWave);
  ALfloat freq  = (float) NUM2DBL(vFltFreq);
  ALfloat phase = (float) NUM2DBL(vFltPhase);
  ALfloat duration  = (float) NUM2DBL(vFltDuration);
  ALuint b = alutCreateBufferWaveform(wave, freq, phase, duration);
  if ( AL_NONE == b ) return Qnil;
  return AL_Buffer_from_albuf(b);
}

/// + AL::Buffer#load_from_sample_data(sample_data)
static VALUE AL_Buffer_load_from_sample_data(VALUE klass, VALUE vSampleData) {
  VALUE self;
  self = AL_Buffer_new(klass);
  AL_Buffer_attach(self, vSampleData);
  return self;
}

/// + AL::Buffer#load_from_file(filename) # alutCreateBufferFromFile
static VALUE AL_Buffer_load_from_file(VALUE klass, VALUE vFilename) {
  char* filename;
  ALuint b;
  Check_Type(vFilename, T_STRING);
  filename = RSTRING_PTR(vFilename);

  alGetError();		// avoids error ALUT_ERROR_AL_ERROR_ON_ENTRY (TODO: check return value everywhere else)

  b = alutCreateBufferFromFile(filename);

  if ( AL_NONE == b ) {
    return Qnil;
  }
  else {
    return AL_Buffer_from_albuf(b);
  }
}

void print_ogg_error(int error) {
	if(error == OV_EREAD) {
		printf("A read from media returned an error.\n");
	} else if(error == OV_ENOTVORBIS) {
		printf("Bitstream does not contain any Vorbis data.\n");
	} else if(error == OV_EVERSION) {
		printf("Vorbis version mismatch.\n");
	} else if(error == OV_EBADHEADER) {
		printf("Invalid Vorbis bitstream header.\n");
	} else if(error == OV_EFAULT) {
		printf("Internal logic fault; indicates a bug or heap/stack corruption.\n");
	} else {
		printf("unknown ogg error %d\n", error);
	}
}

static VALUE AL_Buffer_load_from_ogg_file(VALUE klass, VALUE vFilename) {
	VALUE self;
	char* filename;
	Check_Type(vFilename, T_STRING);
	filename = RSTRING_PTR(vFilename);
	int __unused_bitstream;

	static ogg_sync_state oy; // "sync and verify incoming physical bitstream"
	static int ogg_init=0;		// init once as needed
	if(ogg_init == 0) {
		ogg_sync_init(&oy); 		// "Now we can read pages"
		ogg_init = 1;
	}

	//printf("Loading %s\n", filename);
	OggVorbis_File vf;
	int ret;
	if((ret = ov_fopen(filename, &vf)) < 0) {
		//printf("Failed to load %s\n", filename);
		print_ogg_error(ret);
		return Qnil;
	}
	//printf("Opened %s\n", filename);

	vorbis_info *vi = ov_info(&vf, -1);
	ogg_int64_t pcm_total = ov_pcm_total(&vf, -1);
	//printf("Channels: %d, Rate: %d, pcm total: %d\n", vi->channels, (int)vi->rate, (int)pcm_total);
	int buffer_size = ((int)pcm_total * vi->channels * 2);		// 2 = bytes per sample
	//printf("total bytes expected: %d\n", buffer_size);

	char* buffer = ALLOC_N(char, buffer_size);
	long read_size;
	int bytes_read = 0;
	while((read_size=ov_read(&vf, &buffer[bytes_read], (buffer_size-bytes_read), 0, 2, 1, &__unused_bitstream)) > 0) {	// 0, 2, 1 = little endian, 16-bit, signed
		bytes_read += read_size;
	}
	if(bytes_read != buffer_size) {
		printf("OpenAL ogg error: expected %d but read %d bytes!\n", buffer_size, bytes_read);
	}

	int format;
	if(vi->channels == 2) {
		format = AL_FORMAT_STEREO16;
	}
	else if(vi->channels == 1) {
		format = AL_FORMAT_MONO16;
	}
	else {
		printf("unsupported channel count %d\n", vi->channels);
		free(buffer);		// TODO: proper way to free ALLOC_N?
		return Qnil;
	}

	// Create and return AL::Buffer
	ALuint b;
	alGenBuffers(1, (ALuint*)&b);		// TODO: this rate calculation is a hack
	alBufferData(b, format, buffer, bytes_read, (int)vi->rate);
	free(buffer);		// TODO: proper way to free ALLOC_N?
	return AL_Buffer_from_albuf(b);
}

/// + AL::Buffer#load_from_string(s) # alutCreateBufferFromFileImage
static VALUE AL_Buffer_load_from_string(VALUE klass, VALUE vStr) {
  char* s;
  long slen;
  ALuint b;
  Check_Type(vStr, T_STRING);
  s = RSTRING_PTR(vStr);
  slen = RSTRING_LEN(vStr);
  b = alutCreateBufferFromFileImage(s, slen);
  if ( AL_NONE == b ) return Qnil;
  else return AL_Buffer_from_albuf(b);
}

/// - AL::Buffer#to_s
static VALUE AL_Buffer_to_s(VALUE self) {
  ALuint* p = NULL;
  const long slen = 4096;
  char s[slen];
  ALint freq, size, bits, channels;
  Data_Get_Struct(self, ALuint, p);
  alGetBufferi(*p, AL_FREQUENCY, &freq);
  alGetBufferi(*p, AL_SIZE, &size);
  alGetBufferi(*p, AL_BITS, &bits);
  alGetBufferi(*p, AL_CHANNELS, &channels);
  snprintf(s, slen, "#<AL::Buffer {:freq=>%d, :size=>%d, :bits=>%d, :channels=>%d}@%p>",
    freq, size, bits, channels, p);
  return rb_str_new2(s);
}


static void define_AL_Buffer_methods() {
  /// + AL::Buffer#new
  rb_define_singleton_method(vAL_Buffer, "new", &AL_Buffer_new, 0);

  /// - AL::Buffer#initialize
  rb_define_method(vAL_Buffer, "initialize", &AL_Buffer_initialize, 0);

  /// + AL::Buffer#load_hello_world # alutCreateBufferHelloWorld
  rb_define_singleton_method(vAL_Buffer, "load_hello_world", &AL_Buffer_load_hello_world, 0);

  /// - r: AL::Buffer#frequency : ALint
  rb_define_method(vAL_Buffer, "frequency", &AL_Buffer_get_frequency, 0);

  /// - r: AL::Buffer#size : ALint
  rb_define_method(vAL_Buffer, "size", &AL_Buffer_get_size, 0);

  /// - r: AL::Buffer#bits : ALint
  rb_define_method(vAL_Buffer, "bits", &AL_Buffer_get_bits, 0);

  /// - r: AL::Buffer#channels : ALint
  rb_define_method(vAL_Buffer, "channels", &AL_Buffer_get_channels, 0);

  /// - AL::Buffer#attach(sample_data)
  rb_define_method(vAL_Buffer, "attach", &AL_Buffer_attach, 1);

  /// + AL::Buffer#load_waveform(enWave : ALenum, freq : ALfloat, phase : ALfloat, duration : ALfloat)
  rb_define_singleton_method(vAL_Buffer, "load_waveform", &AL_Buffer_load_waveform, 4);

  /// + AL::Buffer#load_from_sample_data(sample_data)
  rb_define_singleton_method(vAL_Buffer, "load_from_sample_data", &AL_Buffer_load_from_sample_data, 1);

  rb_define_singleton_method(vAL_Buffer, "load_from_data", &AL_Buffer_load_from_data, 3);

  /// + AL::Buffer#load_from_file(filename) # alutCreateBufferFromFile
  rb_define_singleton_method(vAL_Buffer, "load_from_file", &AL_Buffer_load_from_file, 1);

  /// + AL::Buffer#load_from_ogg_file(filename)
  rb_define_singleton_method(vAL_Buffer, "load_from_ogg_file", &AL_Buffer_load_from_ogg_file, 1);

  /// + AL::Buffer#load_from_string(s) # alutCreateBufferFromFileImage
  rb_define_singleton_method(vAL_Buffer, "load_from_string", &AL_Buffer_load_from_string, 1);

  /// - AL::Buffer#to_s
  rb_define_method(vAL_Buffer, "to_s", &AL_Buffer_to_s, 0);

}

static void setup_class_AL_Buffer() {
  vAL_Buffer = rb_define_class_under(vAL, "Buffer", rb_cObject);
  define_AL_Buffer_methods();
}


/// - AL::Source#free
void AL_Source_free(ALuint* p) {
  if ( NULL != p ) {
    if ( alIsSource(*p) ) {
      alDeleteSources(1, p);
    }
    free((void*)p);
  }
}

VALUE AL_Source_from_alsrc(const ALuint b) {
  ALsizei* p = NULL;
  p = malloc(sizeof(ALsizei));
  *p = b;
  return Data_Wrap_Struct(vAL_Source, 0, AL_Source_free, p);
}

/// + AL::Source#new
static VALUE AL_Source_new(VALUE klass) {
  ALuint b;
  alGenSources(1, (ALuint*)&b);
  return AL_Source_from_alsrc(b);
}

/// - AL::Source#initialize
static VALUE AL_Source_initialize(VALUE self) {
  return self;
}

/// - AL::Source#play
static VALUE AL_Source_play(VALUE self) {
  ALuint* p = NULL;
  Data_Get_Struct(self, ALuint, p);
  alSourcePlay(*p);
  return Qnil;
}

/// - AL::Source#stop
static VALUE AL_Source_stop(VALUE self) {
  ALuint* p = NULL;
  Data_Get_Struct(self, ALuint, p);
  alSourceStop(*p);
  return Qnil;
}

/// - AL::Source#pause
static VALUE AL_Source_pause(VALUE self) {
  ALuint* p = NULL;
  Data_Get_Struct(self, ALuint, p);
  alSourcePause(*p);
  return Qnil;
}

/// - AL::Source#rewind
static VALUE AL_Source_rewind(VALUE self) {
  ALuint* p = NULL;
  Data_Get_Struct(self, ALuint, p);
  alSourceRewind(*p);
  return Qnil;
}

/// - AL::Source#attach(buf)     # AL_BUFFER
static VALUE AL_Source_attach(VALUE self, VALUE vBuf) {
  ALuint* pSrc = NULL;
  ALuint* pBuf = NULL;
  Data_Get_Struct(self, ALuint, pSrc);
  if ( CLASS_OF(vBuf) != vAL_Buffer )
    return Qfalse;
  Data_Get_Struct(vBuf, ALuint, pBuf);
  alSourcei(*pSrc, AL_BUFFER, *pBuf);
  return Qtrue;
}

/// - AL::Source#queue([bufs])
static VALUE AL_Source_queue(VALUE self, VALUE vBufs) {
  long len = RARRAY_LEN(vBufs);
  ALuint* bufs;
  ALuint* pSrc;
  ALuint* pTmp;
  long n;
  VALUE vBuf;
  Data_Get_Struct(self, ALuint, pSrc);
  bufs = (ALuint*) malloc(sizeof(ALuint)*len);
  for ( n = 0 ; n < len ; n ++ ) {
    vBuf = rb_ary_entry(vBufs, n);
    Data_Get_Struct(vBuf, ALuint, pTmp);
    bufs[n] = *pTmp;
  }
  alSourceQueueBuffers(*pSrc, len, bufs);
  free((void*)bufs);
  return Qnil;
}

/// - AL::Source#unqueue([bufs])
static VALUE AL_Source_unqueue(VALUE self, VALUE vBufs) {
  long len = RARRAY_LEN(vBufs);
  ALuint* bufs;
  ALuint* pSrc;
  ALuint* pTmp;
  long n;
  VALUE vBuf;
  Data_Get_Struct(self, ALuint, pSrc);
  bufs = (ALuint*) malloc(sizeof(ALuint)*len);
  for ( n = 0 ; n < len ; n ++ ) {
    vBuf = rb_ary_entry(vBufs, n);
    Data_Get_Struct(vBuf, ALuint, pTmp);
    bufs[n] = *pTmp;
  }
  alSourceUnqueueBuffers(*pSrc, len, bufs);
  free((void*)bufs);
  return Qnil;
}

/// - r: AL::Source#buffers_processed :i
static VALUE AL_Source_buffers_processed(VALUE self) {
  // AL_BUFFERS_PROCESSED
  ALint i;
  ALuint* p = NULL;
  Data_Get_Struct(self, ALuint, p);
  alGetSourcei(*p, AL_BUFFERS_PROCESSED, &i);
  return INT2FIX(i);
}


/// - AL::Source#source_type : enum
static VALUE AL_Source_get_source_type(VALUE self) {
  ALint i;
  ALuint* p = NULL;
  Data_Get_Struct(self, ALuint, p);
  alGetSourcei(*p, AL_SOURCE_TYPE, &i);
  switch (i) {
  case AL_UNDETERMINED:
    return vAL_UNDETERMINED;
  case AL_STATIC:
    return vAL_STATIC;
  case AL_STREAMING:
    return vAL_STREAMING;
  default:
    return INT2FIX(i);
  }
}

/// - AL::Source#source_type=(enum)
static VALUE AL_Source_set_source_type(VALUE self, VALUE vSrcType) {
  ALuint e;
  ALuint* p = NULL;
  Data_Get_Struct(self, ALuint, p);
  e = NUM2INT(vSrcType);
  alSourcei(*p, AL_SOURCE_TYPE, e);
  return Qnil;
}

/// - AL::Source#looping : bool       # AL_LOOPING
static VALUE AL_Source_get_looping(VALUE self) {
  ALint e;
  ALuint* p = NULL;
  Data_Get_Struct(self, ALuint, p);
  alGetSourcei(*p, AL_LOOPING, &e);
  return albool2rbbool(e);
}

/// - AL::Source#looping=(bool)       # AL_LOOPING
static VALUE AL_Source_set_looping(VALUE self, VALUE vOnOff) {
  ALint onoff = NUM2INT(vOnOff);
  ALuint* p = NULL;
  Data_Get_Struct(self, ALuint, p);
  switch (onoff) {
  case AL_TRUE:
  case AL_FALSE:
    alSourcei(*p, AL_LOOPING, onoff);
    return vOnOff;
  default:
    return Qnil;
  }
}

/// - AL::Source#playing? : bool  # AL_SOURCE_STATE [AL_STOPPPED, AL_PLAYING]
static VALUE AL_Source_get_source_state(VALUE self) {
  ALint e;
  ALuint* p = NULL;
  Data_Get_Struct(self, ALuint, p);
  alGetSourcei(*p, AL_SOURCE_STATE, &e);
  switch (e) {
  case AL_PLAYING:
    return Qtrue;
  case AL_STOPPED:
    return Qfalse;
  default:
    return Qnil;
  }
}

/// - AL::Source#playing=(bool)  # AL_SOURCE_STATE [AL_STOPPPED, AL_PLAYING]
static VALUE AL_Source_set_source_state(VALUE self, VALUE vState) {
  ALuint* p = NULL;
  Data_Get_Struct(self, ALuint, p);
  if (Qtrue == vState) alSourcei(*p, AL_SOURCE_STATE, AL_PLAYING);
  if (Qfalse == vState) alSourcei(*p, AL_SOURCE_STATE, AL_STOPPED);
  return vState;
}

/// - AL::Source#buffers_queued : n   # AL_BUFFERS_QUEUED
static VALUE AL_Source_get_buffers_queued(VALUE self) {
  ALint n;
  ALuint* p = NULL;
  Data_Get_Struct(self, ALuint, p);
  alGetSourcei(*p, AL_BUFFERS_QUEUED, &n);
  return NUM2INT(n);
}

/// - AL::Source#buffers_queued=(n)   # AL_BUFFERS_QUEUED
static VALUE AL_Source_set_buffers_queued(VALUE self, VALUE vN) {
  ALint n = NUM2INT(vN);
  ALuint* p = NULL;
  Data_Get_Struct(self, ALuint, p);
  alSourcei(*p, AL_BUFFERS_QUEUED, n);
  return Qnil;
}

/// - AL::Source#sec_offset : nsec      # AL_SEC_OFFSET
static VALUE AL_Source_get_sec_offset(VALUE self) {
  ALint n;
  ALuint* p = NULL;
  Data_Get_Struct(self, ALuint, p);
  alGetSourcei(*p, AL_SEC_OFFSET, &n);
  return INT2FIX(n);
}

/// - AL::Source#sec_offset=(nsec)      # AL_SEC_OFFSET
static VALUE AL_Source_set_sec_offset(VALUE self, VALUE vSec) {
  ALuint* p = NULL;
  Data_Get_Struct(self, ALuint, p);
  alSourcei(*p, AL_SEC_OFFSET, NUM2INT(vSec));
  return Qnil;
}

/// - AL::Source#sample_offset : nsamples  # AL_SAMPLE_OFFSET
static VALUE AL_Source_get_sample_offset(VALUE self) {
  ALint n;
  ALuint* p = NULL;
  Data_Get_Struct(self, ALuint, p);
  alGetSourcei(*p, AL_SAMPLE_OFFSET, &n);
//  return NUM2INT(n);
  return INT2FIX(n);
}

/// - AL::Source#sample_offset=(nsamples)  # AL_SAMPLE_OFFSET
static VALUE AL_Source_set_sample_offset(VALUE self, VALUE vN) {
  ALint n = NUM2INT(vN);
  ALuint* p = NULL;
  Data_Get_Struct(self, ALuint, p);
  alSourcei(*p, AL_SAMPLE_OFFSET, n);
  return Qnil;
}

/// - AL::Source#byte_offset : nbytes # AL_BYTE_OFFSET
static VALUE AL_Source_get_byte_offset(VALUE self) {
  ALint n;
  ALuint* p = NULL;
  Data_Get_Struct(self, ALuint, p);
  alGetSourcei(*p, AL_BYTE_OFFSET, &n);
  return NUM2INT(n);
}

/// - AL::Source#byte_offset=(nbytes)  # AL_BYTE_OFFSET
static VALUE AL_Source_set_byte_offset(VALUE self, VALUE vN) {
  ALint n = NUM2INT(vN);
  ALuint* p = NULL;
  Data_Get_Struct(self, ALuint, p);
  alSourcei(*p, AL_BYTE_OFFSET, n);
  return Qnil;
}

/// - AL::Source#source_relative?
static VALUE AL_Source_is_source_relative(VALUE self) {
  ALint n;
  ALuint* p = NULL;
  Data_Get_Struct(self, ALuint, p);
  alGetSourcei(*p, AL_SOURCE_RELATIVE, &n);
  return albool2rbbool(n);
}

/// - AL::Source#source_relative=(b)
static VALUE AL_Source_set_source_relative(VALUE self, VALUE vBool) {
  ALuint* p = NULL;
  Data_Get_Struct(self, ALuint, p);
  if (vBool == Qtrue) alSourcei(*p, AL_SOURCE_RELATIVE, AL_TRUE);
  if (vBool == Qfalse) alSourcei(*p, AL_SOURCE_RELATIVE, AL_FALSE);
  return vBool;
}

/// - AL::Source#pitch : f    # AL_PITCH > 0
static VALUE AL_Source_get_pitch(VALUE self) {
  ALfloat n;
  ALuint* p = NULL;
  Data_Get_Struct(self, ALuint, p);
  alGetSourcef(*p, AL_PITCH, &n);
  return rb_float_new(n);
}

/// - AL::Source#pitch=(f)    # AL_PITCH > 0
static VALUE AL_Source_set_pitch(VALUE self, VALUE v) {
  ALuint* p = NULL;
  ALfloat n = (float) NUM2DBL(v);
  Data_Get_Struct(self, ALuint, p);
  alSourcef(*p, AL_PITCH, n);
  return v;
}

/// - AL::Source#gain : f
static VALUE AL_Source_get_gain(VALUE self) {
  ALfloat n;
  ALuint* p = NULL;
  Data_Get_Struct(self, ALuint, p);
  alGetSourcef(*p, AL_GAIN, &n);
  return rb_float_new(n);
}

/// - AL::Source#gain=(f)    #
static VALUE AL_Source_set_gain(VALUE self, VALUE v) {
  ALuint* p = NULL;
  ALfloat n = (float) NUM2DBL(v);
  Data_Get_Struct(self, ALuint, p);
  alSourcef(*p, AL_GAIN, n);
  return v;
}

/// - AL::Source#max_distance : f
static VALUE AL_Source_get_max_distance(VALUE self) {
  ALfloat n;
  ALuint* p = NULL;
  Data_Get_Struct(self, ALuint, p);
  alGetSourcef(*p, AL_MAX_DISTANCE, &n);
  return rb_float_new(n);
}

/// - AL::Source#max_distance=(f)    #
static VALUE AL_Source_set_max_distance(VALUE self, VALUE v) {
  ALuint* p = NULL;
  ALfloat n = (float) NUM2DBL(v);
  Data_Get_Struct(self, ALuint, p);
  alSourcef(*p, AL_MAX_DISTANCE, n);
  return v;
}

/// - AL::Source#rolloff_factor : f
static VALUE AL_Source_get_rolloff_factor(VALUE self) {
  ALfloat n;
  ALuint* p = NULL;
  Data_Get_Struct(self, ALuint, p);
  alGetSourcef(*p, AL_ROLLOFF_FACTOR, &n);
  return rb_float_new(n);
}

/// - AL::Source#rolloff_factor=(f)    #
static VALUE AL_Source_set_rolloff_factor(VALUE self, VALUE v) {
  ALuint* p = NULL;
  ALfloat n = (float) NUM2DBL(v);
  Data_Get_Struct(self, ALuint, p);
  alSourcef(*p, AL_ROLLOFF_FACTOR, n);
  return v;
}

/// - AL::Source#reference_distance : f
static VALUE AL_Source_get_reference_distance(VALUE self) {
  ALfloat n;
  ALuint* p = NULL;
  Data_Get_Struct(self, ALuint, p);
  alGetSourcef(*p, AL_REFERENCE_DISTANCE, &n);
  return rb_float_new(n);
}

/// - AL::Source#reference_distance=(f)    #
static VALUE AL_Source_set_reference_distance(VALUE self, VALUE v) {
  ALuint* p = NULL;
  ALfloat n = (float) NUM2DBL(v);
  Data_Get_Struct(self, ALuint, p);
  alSourcef(*p, AL_REFERENCE_DISTANCE, n);
  return v;
}

/// - AL::Source#min_gain : f
static VALUE AL_Source_get_min_gain(VALUE self) {
  ALfloat n;
  ALuint* p = NULL;
  Data_Get_Struct(self, ALuint, p);
  alGetSourcef(*p, AL_MIN_GAIN, &n);
  return rb_float_new(n);
}

/// - AL::Source#min_gain=(f)    #
static VALUE AL_Source_set_min_gain(VALUE self, VALUE v) {
  ALuint* p = NULL;
  ALfloat n = (float) NUM2DBL(v);
  Data_Get_Struct(self, ALuint, p);
  alSourcef(*p, AL_MIN_GAIN, n);
  return v;
}

/// - AL::Source#max_gain : f
static VALUE AL_Source_get_max_gain(VALUE self) {
  ALfloat n;
  ALuint* p = NULL;
  Data_Get_Struct(self, ALuint, p);
  alGetSourcef(*p, AL_MAX_GAIN, &n);
  return rb_float_new(n);
}

/// - AL::Source#max_gain=(f)    #
static VALUE AL_Source_set_max_gain(VALUE self, VALUE v) {
  ALuint* p = NULL;
  ALfloat n = (float) NUM2DBL(v);
  Data_Get_Struct(self, ALuint, p);
  alSourcef(*p, AL_MAX_GAIN, n);
  return v;
}

/// - AL::Source#cone_outer_gain : f
static VALUE AL_Source_get_cone_outer_gain(VALUE self) {
  ALfloat n;
  ALuint* p = NULL;
  Data_Get_Struct(self, ALuint, p);
  alGetSourcef(*p, AL_CONE_OUTER_GAIN, &n);
  return rb_float_new(n);
}

/// - AL::Source#cone_outer_gain=(f)    #
static VALUE AL_Source_set_cone_outer_gain(VALUE self, VALUE v) {
  ALuint* p = NULL;
  ALfloat n = (float) NUM2DBL(v);
  Data_Get_Struct(self, ALuint, p);
  alSourcef(*p, AL_CONE_OUTER_GAIN, n);
  return v;
}

/// - AL::Source#cone_inner_angle : f
static VALUE AL_Source_get_cone_inner_angle(VALUE self) {
  ALfloat n;
  ALuint* p = NULL;
  Data_Get_Struct(self, ALuint, p);
  alGetSourcef(*p, AL_CONE_INNER_ANGLE, &n);
  return rb_float_new(n);
}

/// - AL::Source#cone_inner_angle=(f)    #
static VALUE AL_Source_set_cone_inner_angle(VALUE self, VALUE v) {
  ALuint* p = NULL;
  ALfloat n = (float) NUM2DBL(v);
  Data_Get_Struct(self, ALuint, p);
  alSourcef(*p, AL_CONE_INNER_ANGLE, n);
  return v;
}

/// - AL::Source#cone_outer_angle : f
static VALUE AL_Source_get_cone_outer_angle(VALUE self) {
  ALfloat n;
  ALuint* p = NULL;
  Data_Get_Struct(self, ALuint, p);
  alGetSourcef(*p, AL_CONE_OUTER_ANGLE, &n);
  return rb_float_new(n);
}

/// - AL::Source#cone_outer_angle=(f)    #
static VALUE AL_Source_set_cone_outer_angle(VALUE self, VALUE v) {
  ALuint* p = NULL;
  ALfloat n = (float) NUM2DBL(v);
  Data_Get_Struct(self, ALuint, p);
  alSourcef(*p, AL_CONE_OUTER_ANGLE, n);
  return v;
}

/// - AL::Source#position : [x, y, z]
static VALUE AL_Source_get_position(VALUE self) {
  ALfloat v[] = {0.0f, 0.0f, 0.0f};
  VALUE ary;
  ALuint* p;
  // self
  Data_Get_Struct(self, ALuint, p);
  // self->vec
  ary = rb_ary_new();
  alGetSourcefv(*p, AL_POSITION, v);
  ARRAY2RARRAY(v, ary, 3, rb_float_new);
  return ary;
}

/// - AL::Source#position=([x, y, z])
static VALUE AL_Source_set_position(VALUE self, VALUE vPos) {
  ALfloat vec[3];
  ALuint* p;
  Data_Get_Struct(self, ALuint, p);
  RARRAY2ARRAY(vPos, vec, 3, NUM2DBL);
  alSourcefv(*p, AL_POSITION, vec);
  return Qnil;
}

/// - AL::Source#velocity : [x, y, z]
static VALUE AL_Source_get_velocity(VALUE self) {
  ALfloat v[] = {0.0f, 0.0f, 0.0f};
  VALUE ary;
  ALuint* p;
  // self
  Data_Get_Struct(self, ALuint, p);
  // self->vec
  ary = rb_ary_new();
  alGetSourcefv(*p, AL_VELOCITY, v);
  ARRAY2RARRAY(v, ary, 3, rb_float_new);
  return ary;
}

/// - AL::Source#velocity=([x, y, z])
static VALUE AL_Source_set_velocity(VALUE self, VALUE vVel) {
  ALfloat vec[3];
  ALuint* p;
  Data_Get_Struct(self, ALuint, p);
  RARRAY2ARRAY(vVel, vec, 3, NUM2DBL);
  alSourcefv(*p, AL_VELOCITY, vec);
  return Qnil;
}

/// - AL::Source#direction : [x, y, z]
static VALUE AL_Source_get_direction(VALUE self) {
  ALfloat v[] = {0.0f, 0.0f, 0.0f};
  VALUE ary;
  ALuint* p;
  // self
  Data_Get_Struct(self, ALuint, p);
  // self->vec
  ary = rb_ary_new();
  alGetSourcefv(*p, AL_DIRECTION, v);
  ARRAY2RARRAY(v, ary, 3, rb_float_new);
  return ary;
}

/// - AL::Source#direction=([x, y, z])
static VALUE AL_Source_set_direction(VALUE self, VALUE vDir) {
  ALfloat vec[3];
  ALuint* p;
  Data_Get_Struct(self, ALuint, p);
  RARRAY2ARRAY(vDir, vec, 3, NUM2DBL);
  alSourcefv(*p, AL_DIRECTION, vec);
  return Qnil;
}

/// - AL::Source#direct_filter=(filter)
static VALUE AL_Source_set_direct_filter(VALUE self, VALUE vFilter) {
  ALuint* p;
  Data_Get_Struct(self, ALuint, p);

  ALuint* f;
  Data_Get_Struct(vFilter, ALuint, f);

  alSourcei(*p, AL_DIRECT_FILTER, *f);
  return Qnil;
}

/// - AL::Source#auxiliary_send_filter=(auxiliary_effect_slot)
static VALUE AL_Source_set_auxiliary_send_filter(VALUE self, VALUE vAuxiliaryEffectSlot, VALUE vFilter) {
  ALuint* p;
  Data_Get_Struct(self, ALuint, p);

  if(vAuxiliaryEffectSlot == Qnil) {
    alSource3i(*p, AL_AUXILIARY_SEND_FILTER, AL_EFFECTSLOT_NULL, 0, AL_FILTER_NULL);
    return Qnil;
  }
  ALuint* aes;
  Data_Get_Struct(vAuxiliaryEffectSlot, ALuint, aes);

  if(vFilter == Qnil) {
    alSource3i(*p, AL_AUXILIARY_SEND_FILTER, *aes, 0, AL_FILTER_NULL);
    return Qnil;
  }

  ALuint* f;
  Data_Get_Struct(vFilter, ALuint, f);

  alSource3i(*p, AL_AUXILIARY_SEND_FILTER, *aes, 0, *f); //AL_FILTER_NULL);
  return Qnil;
}


static void define_AL_Source_methods() {
  /// + new
  rb_define_singleton_method(vAL_Source, "new", &AL_Source_new, 0);

  /// - initialize
  rb_define_method(vAL_Source, "initialize", &AL_Source_initialize, 0);

  ///FIXME: - to_s

  /// - play
  rb_define_method(vAL_Source, "play", &AL_Source_play, 0);

  /// - stop
  rb_define_method(vAL_Source, "stop", &AL_Source_stop, 0);

  /// - pause
  rb_define_method(vAL_Source, "pause", &AL_Source_pause, 0);

  /// - rewind
  rb_define_method(vAL_Source, "rewind", &AL_Source_rewind, 0);

  /// - attach(buf)     # AL_BUFFER
  rb_define_method(vAL_Source, "attach", &AL_Source_attach, 1);

  /// - queue([bufs])
  rb_define_method(vAL_Source, "queue", &AL_Source_queue, 1);

  /// - unqueue([bufs])
  rb_define_method(vAL_Source, "unqueue", &AL_Source_unqueue, 1);

  /// - r: buffers_processed :i # AL_BUFFERS_PROCESSED
  rb_define_method(vAL_Source, "buffers_processed", &AL_Source_buffers_processed, 0);

  /// - rw: pitch(f)    # AL_PITCH > 0
  rb_define_method(vAL_Source, "pitch", &AL_Source_get_pitch, 0);
  rb_define_method(vAL_Source, "pitch=", &AL_Source_set_pitch, 1);

  /// - rw: gain(f)     # AL_GAIN > 0
  rb_define_method(vAL_Source, "gain", &AL_Source_get_gain, 0);
  rb_define_method(vAL_Source, "gain=", &AL_Source_set_gain, 1);

  /// - rw: max_distance(f)   # AL_MAX_DISTANCE
  rb_define_method(vAL_Source, "max_distance", &AL_Source_get_max_distance, 0);
  rb_define_method(vAL_Source, "max_distance=", &AL_Source_set_max_distance, 1);

  /// - rw: rolloff_factor(f) # AL_ROLLOFF_FACTOR
  rb_define_method(vAL_Source, "rolloff_factor", &AL_Source_get_rolloff_factor, 0);
  rb_define_method(vAL_Source, "rolloff_factor=", &AL_Source_set_rolloff_factor, 1);

  /// - rw: reference_distance(f) # AL_REFERENCE_DISTANCE
  rb_define_method(vAL_Source, "reference_distance", &AL_Source_get_reference_distance, 0);
  rb_define_method(vAL_Source, "reference_distance=", &AL_Source_set_reference_distance, 1);

  /// - rw: min_gain(f)   # AL_MIN_GAIN
  rb_define_method(vAL_Source, "min_gain", &AL_Source_get_min_gain, 0);
  rb_define_method(vAL_Source, "min_gain=", &AL_Source_set_min_gain, 1);

  /// - rw: max_gain(f)   # AL_MAX_GAIN
  rb_define_method(vAL_Source, "max_gain", &AL_Source_get_max_gain, 0);
  rb_define_method(vAL_Source, "max_gain=", &AL_Source_set_max_gain, 1);

  /// - rw: cone_outer_gain(f)  # AL_CONE_OUTER_GAIN
  rb_define_method(vAL_Source, "cone_outer_gain", &AL_Source_get_cone_outer_gain, 0);
  rb_define_method(vAL_Source, "cone_outer_gain=", &AL_Source_set_cone_outer_gain, 1);

  /// - rw: cone_inner_angle(f) # AL_CONE_INNER_ANGLE
  rb_define_method(vAL_Source, "cone_inner_angle", &AL_Source_get_cone_inner_angle, 0);
  rb_define_method(vAL_Source, "cone_inner_angle=", &AL_Source_set_cone_inner_angle, 1);

  /// - rw: cone_outer_angle(f) # AL_CONE_OUTER_ANGLE
  rb_define_method(vAL_Source, "cone_outer_angle", &AL_Source_get_cone_outer_angle, 0);
  rb_define_method(vAL_Source, "cone_outer_angle=", &AL_Source_set_cone_outer_angle, 1);

  /// - rw: position([x, y, z]) # AL_POSITION
  rb_define_method(vAL_Source, "position", &AL_Source_get_position, 0);
  rb_define_method(vAL_Source, "position=", &AL_Source_set_position, 1);

  /// - rw: velocity([x, y, z]) # AL_VELOCITY
  rb_define_method(vAL_Source, "velocity", &AL_Source_get_velocity, 0);
  rb_define_method(vAL_Source, "velocity=", &AL_Source_set_velocity, 1);

  /// - rw: direction([x, y, z])  # AL_DIRECTION
  rb_define_method(vAL_Source, "direction", &AL_Source_get_direction, 0);
  rb_define_method(vAL_Source, "direction=", &AL_Source_set_direction, 1);

  /// - rw: source_type(enum)   # AL_SOURCE_TYPE [AL_UNDERTERMINED, AL_STATIC, AL_STREAMING]
  rb_define_method(vAL_Source, "source_type", &AL_Source_get_source_type, 0);
  rb_define_method(vAL_Source, "source_type=", &AL_Source_set_source_type, 1);

  /// - rw: looping(bool)       # AL_LOOPING
  rb_define_method(vAL_Source, "looping", &AL_Source_get_looping, 0);
  rb_define_method(vAL_Source, "looping=", &AL_Source_set_looping, 1);

  /// - rw: playing?(enum)  # AL_SOURCE_STATE [AL_STOPPPED, AL_PLAYING]
  rb_define_method(vAL_Source, "playing?", &AL_Source_get_source_state, 0);
  rb_define_method(vAL_Source, "playing=", &AL_Source_set_source_state, 1);

  /// - rw: buffers_queued(i)   # AL_BUFFERS_QUEUED
  rb_define_method(vAL_Source, "buffers_queued", &AL_Source_get_buffers_queued, 0);
  rb_define_method(vAL_Source, "buffers_queued=", &AL_Source_set_buffers_queued, 1);

  /// - rw: sec_offset(nsec)     # AL_SEC_OFFSET
  rb_define_method(vAL_Source, "sec_offset", &AL_Source_get_sec_offset, 0);
  rb_define_method(vAL_Source, "sec_offset=", &AL_Source_set_sec_offset, 1);

  /// - rw: sample_offset(nsamples)  # AL_SAMPLE_OFFSET
  rb_define_method(vAL_Source, "sample_offset", &AL_Source_get_sample_offset, 0);
  rb_define_method(vAL_Source, "sample_offset=", &AL_Source_set_sample_offset, 1);

  /// - rw: byte_offset(nbytes)  # AL_BYTE_OFFSET
  rb_define_method(vAL_Source, "byte_offset", &AL_Source_get_byte_offset, 0);
  rb_define_method(vAL_Source, "byte_offset=", &AL_Source_set_byte_offset, 1);

  /// - rw: source_relative(bool)   # AL_SOURCE_RELATIVE
  rb_define_method(vAL_Source, "source_relative?", &AL_Source_is_source_relative, 0);
  rb_define_method(vAL_Source, "source_relative=", &AL_Source_set_source_relative, 1);

  /// - rw: direct_filter(filter)   # AL_DIRECT_FILTER
//  rb_define_method(vAL_Source, "direct_filter", &AL_Source_set_direct_filter, 0);
  rb_define_method(vAL_Source, "direct_filter=", &AL_Source_set_direct_filter, 1);

//  rb_define_method(vAL_Source, "auxiliary_send_filter=", &AL_Source_set_auxiliary_send_filter, 1);
  rb_define_method(vAL_Source, "auxiliary_send_filter", &AL_Source_set_auxiliary_send_filter, 2);
}

static void setup_class_AL_Source() {
  vAL_Source = rb_define_class_under(vAL, "Source", rb_cObject);
  define_AL_Source_methods();
}

/*
 *
 * AL::Filter
 *
 *
 */

/// - AL::Filter#free
void AL_Filter_free(ALuint* p) {
  if ( NULL != p ) {
    if ( alIsFilter(*p) ) {
      alDeleteFilters(1, p);
    }
    free((void*)p);
  }
}

VALUE AL_Filter_from_alsrc(const ALuint b) {
  ALsizei* p = NULL;
  p = malloc(sizeof(ALsizei));
  *p = b;
  return Data_Wrap_Struct(vAL_Filter, 0, AL_Filter_free, p);
}

/// + AL::Filter#new
static VALUE AL_Filter_new(VALUE klass) {
  ALuint b;
  alGenFilters(1, (ALuint*)&b);
  return AL_Filter_from_alsrc(b);
}

/// - AL::Filter#initialize
static VALUE AL_Filter_initialize(VALUE self) {
  return self;
}

/// - AL::Filter#filter_type : enum
static VALUE AL_Filter_get_filter_type(VALUE self) {
  ALint i;
  ALuint* p = NULL;
  Data_Get_Struct(self, ALuint, p);
  alGetFilteri(*p, AL_FILTER_TYPE, &i);
  switch (i) {
  case AL_FILTER_NULL:
    return vAL_FILTER_NULL;
  case AL_FILTER_LOWPASS:
    return vAL_FILTER_LOWPASS;
  default:
    return INT2FIX(i);
  }
}

/// - AL::Filter#filter_type=(enum)
static VALUE AL_Filter_set_filter_type(VALUE self, VALUE vSrcType) {
  ALuint e;
  ALuint* p = NULL;
  Data_Get_Struct(self, ALuint, p);
  e = NUM2INT(vSrcType);
  alFilteri(*p, AL_FILTER_TYPE, e);
  return Qnil;
}

/// - AL::Filter#lowpass_gain : f
static VALUE AL_Filter_get_lowpass_gain(VALUE self) {
  ALfloat n;
  ALuint* p = NULL;
  Data_Get_Struct(self, ALuint, p);
  alGetFilterf(*p, AL_LOWPASS_GAIN, &n);
  return rb_float_new(n);
}

/// - AL::Filter#lowpass_gain=(f)    #
static VALUE AL_Filter_set_lowpass_gain(VALUE self, VALUE v) {
  ALuint* p = NULL;
  ALfloat n = (float) NUM2DBL(v);
  Data_Get_Struct(self, ALuint, p);
  alFilterf(*p, AL_LOWPASS_GAIN, n);
  return v;
}

/// - AL::Filter#lowpass_gainhf : f
static VALUE AL_Filter_get_lowpass_gainhf(VALUE self) {
  ALfloat n;
  ALuint* p = NULL;
  Data_Get_Struct(self, ALuint, p);
  alGetFilterf(*p, AL_LOWPASS_GAINHF, &n);
  return rb_float_new(n);
}

/// - AL::Filter#lowpass_gainhf=(f)    #
static VALUE AL_Filter_set_lowpass_gainhf(VALUE self, VALUE v) {
  ALuint* p = NULL;
  ALfloat n = (float) NUM2DBL(v);
  Data_Get_Struct(self, ALuint, p);
  alFilterf(*p, AL_LOWPASS_GAINHF, n);
  return v;
}

static void define_AL_Filter_methods() {
  /// + new
  rb_define_singleton_method(vAL_Filter, "new", &AL_Filter_new, 0);

  /// - initialize
  rb_define_method(vAL_Filter, "initialize", &AL_Filter_initialize, 0);

  /// - rw: filter_type(enum)   # AL_FILTER_TYPE [AL_FILTER_NULL, AL_FILTER_LOWPASS]
  rb_define_method(vAL_Filter, "filter_type", &AL_Filter_get_filter_type, 0);
  rb_define_method(vAL_Filter, "filter_type=", &AL_Filter_set_filter_type, 1);

  rb_define_method(vAL_Filter, "lowpass_gain", &AL_Filter_get_lowpass_gain, 0);
  rb_define_method(vAL_Filter, "lowpass_gain=", &AL_Filter_set_lowpass_gain, 1);

  rb_define_method(vAL_Filter, "lowpass_gainhf", &AL_Filter_get_lowpass_gainhf, 0);
  rb_define_method(vAL_Filter, "lowpass_gainhf=", &AL_Filter_set_lowpass_gainhf, 1);
}

static void setup_class_AL_Filter() {
  vAL_Filter = rb_define_class_under(vAL, "Filter", rb_cObject);
  define_AL_Filter_methods();

  alGenFilters = alGetProcAddress("alGenFilters");
  alFilteri = alGetProcAddress("alFilteri");
  alFilterf = alGetProcAddress("alFilterf");
}

static void define_AL_Filter_consts() {
  rb_define_const(vAL_Filter, "FILTER_NULL", vAL_FILTER_NULL);
  rb_define_const(vAL_Filter, "FILTER_LOWPASS", vAL_FILTER_LOWPASS);
}

/*
 *
 * AL::AuxiliaryEffectSlot
 *
 */

/// - AL::AuxiliaryEffectSlot#free
void AL_AuxiliaryEffectSlot_free(ALuint* p) {
  if ( NULL != p ) {
    if ( alIsAuxiliaryEffectSlot(*p) ) {
      alDeleteAuxiliaryEffectSlots(1, p);
    }
    free((void*)p);
  }
}

VALUE AL_AuxiliaryEffectSlot_from_alsrc(const ALuint b) {
  ALsizei* p = NULL;
  p = malloc(sizeof(ALsizei));
  *p = b;
  return Data_Wrap_Struct(vAL_AuxiliaryEffectSlot, 0, AL_AuxiliaryEffectSlot_free, p);
}

/// + AL::AuxiliaryEffectSlot#new
static VALUE AL_AuxiliaryEffectSlot_new(VALUE klass) {
  ALuint b;
  alGenAuxiliaryEffectSlots(1, (ALuint*)&b);
  return AL_AuxiliaryEffectSlot_from_alsrc(b);
}

/// - AL::AuxiliaryEffectSlot#initialize
static VALUE AL_AuxiliaryEffectSlot_initialize(VALUE self) {
  return self;
}

/// - AL::AuxiliaryEffectSlot#effect=(effect)
static VALUE AL_AuxiliaryEffectSlot_set_effect(VALUE self, VALUE vEffect) {
  ALuint* p;
  Data_Get_Struct(self, ALuint, p);

  if(vEffect == Qnil) {
    alAuxiliaryEffectSloti(*p, AL_EFFECTSLOT_EFFECT, AL_EFFECT_NULL);
  } else {
    ALuint* e;
    Data_Get_Struct(vEffect, ALuint, e);

    alAuxiliaryEffectSloti(*p, AL_EFFECTSLOT_EFFECT, *e);
  }
  return Qnil;
}

static void define_AL_AuxiliaryEffectSlot_methods() {
  /// + new
  rb_define_singleton_method(vAL_AuxiliaryEffectSlot, "new", &AL_AuxiliaryEffectSlot_new, 0);

  /// - initialize
  rb_define_method(vAL_AuxiliaryEffectSlot, "initialize", &AL_AuxiliaryEffectSlot_initialize, 0);

  //rb_define_method(vAL_AuxiliaryEffectSlot, "effect", &AL_AuxiliaryEffectSlot_effect, 0);
  rb_define_method(vAL_AuxiliaryEffectSlot, "effect=", &AL_AuxiliaryEffectSlot_set_effect, 1);
}

static void setup_class_AL_AuxiliaryEffectSlot() {
  vAL_AuxiliaryEffectSlot = rb_define_class_under(vAL, "AuxiliaryEffectSlot", rb_cObject);
  define_AL_AuxiliaryEffectSlot_methods();

  alGenAuxiliaryEffectSlots = alGetProcAddress("alGenAuxiliaryEffectSlots");
  alAuxiliaryEffectSloti = alGetProcAddress("alAuxiliaryEffectSloti");
}

static void define_AL_AuxiliaryEffectSlot_consts() {
}



/*
 *
 * AL::Effect
 *
 */

/// - AL::Effect#free
void AL_Effect_free(ALuint* p) {
  if ( NULL != p ) {
    if ( alIsEffect(*p) ) {
      alDeleteEffects(1, p);
    }
    free((void*)p);
  }
}

VALUE AL_Effect_from_alsrc(const ALuint b) {
  ALsizei* p = NULL;
  p = malloc(sizeof(ALsizei));
  *p = b;
  return Data_Wrap_Struct(vAL_Effect, 0, AL_Effect_free, p);
}

/// + AL::Effect#new
static VALUE AL_Effect_new(VALUE klass) {
  ALuint b;
  alGenEffects(1, (ALuint*)&b);
  return AL_Effect_from_alsrc(b);
}

/// - AL::Effect#initialize
static VALUE AL_Effect_initialize(VALUE self) {
  return self;
}

/// - AL::Effect#effect_type : enum
static VALUE AL_Effect_get_effect_type(VALUE self) {
  ALint i;
  ALuint* p = NULL;
  Data_Get_Struct(self, ALuint, p);
  alGetEffecti(*p, AL_EFFECT_TYPE, &i);
  switch (i) {
  case AL_EFFECT_NULL:
    return vAL_EFFECT_NULL;
  case AL_EFFECT_REVERB:
    return vAL_EFFECT_REVERB;
  default:
    return INT2FIX(i);
  }
}

/// - AL::Effect#effect_type=(enum)
static VALUE AL_Effect_set_effect_type(VALUE self, VALUE vSrcType) {
  ALuint e;
  ALuint* p = NULL;
  Data_Get_Struct(self, ALuint, p);
  e = NUM2INT(vSrcType);
  alEffecti(*p, AL_EFFECT_TYPE, e);
  return Qnil;
}

/*
 * Reverb - Gain
 */

/// - AL::Effect#reverb_gain : f
static VALUE AL_Effect_get_reverb_gain(VALUE self) {
  ALfloat n;
  ALuint* p = NULL;
  Data_Get_Struct(self, ALuint, p);
  alGetEffectf(*p, AL_REVERB_GAIN, &n);
  return rb_float_new(n);
}

/// - AL::Effect#reverb_gain=(f)
static VALUE AL_Effect_set_reverb_gain(VALUE self, VALUE v) {
  ALuint* p = NULL;
  ALfloat n = (float) NUM2DBL(v);
  Data_Get_Struct(self, ALuint, p);
  alEffectf(*p, AL_REVERB_GAIN, n);
  return v;
}

/*
 * Reverb - GainHF
 */

/// - AL::Effect#reverb_gainhf : f
static VALUE AL_Effect_get_reverb_gainhf(VALUE self) {
  ALfloat n;
  ALuint* p = NULL;
  Data_Get_Struct(self, ALuint, p);
  alGetEffectf(*p, AL_REVERB_GAINHF, &n);
  return rb_float_new(n);
}

/// - AL::Effect#reverb_gainhf=(f)
static VALUE AL_Effect_set_reverb_gainhf(VALUE self, VALUE v) {
  ALuint* p = NULL;
  ALfloat n = (float) NUM2DBL(v);
  Data_Get_Struct(self, ALuint, p);
  alEffectf(*p, AL_REVERB_GAINHF, n);
  return v;
}

/*
 * Reverb - Decay Time
 */

/// - AL::Effect#reverb_decay_time : f
static VALUE AL_Effect_get_reverb_decay_time(VALUE self) {
  ALfloat n;
  ALuint* p = NULL;
  Data_Get_Struct(self, ALuint, p);
  alGetEffectf(*p, AL_REVERB_DECAY_TIME, &n);
  return rb_float_new(n);
}

/// - AL::Effect#reverb_decay_time=(f)
static VALUE AL_Effect_set_reverb_decay_time(VALUE self, VALUE v) {
  ALuint* p = NULL;
  ALfloat n = (float) NUM2DBL(v);
  Data_Get_Struct(self, ALuint, p);
  alEffectf(*p, AL_REVERB_DECAY_TIME, n);
  return v;
}

/*
 * Reverb - Density
 */

/// - AL::Effect#reverb_density : f
static VALUE AL_Effect_get_reverb_density(VALUE self) {
  ALfloat n;
  ALuint* p = NULL;
  Data_Get_Struct(self, ALuint, p);
  alGetEffectf(*p, AL_REVERB_DENSITY, &n);
  return rb_float_new(n);
}

/// - AL::Effect#reverb_density=(f)
static VALUE AL_Effect_set_reverb_density(VALUE self, VALUE v) {
  ALuint* p = NULL;
  ALfloat n = (float) NUM2DBL(v);
  Data_Get_Struct(self, ALuint, p);
  alEffectf(*p, AL_REVERB_DENSITY, n);
  return v;
}

/*
 * Reverb - Diffusion
 */

/// - AL::Effect#reverb_diffusion : f
static VALUE AL_Effect_get_reverb_diffusion(VALUE self) {
  ALfloat n;
  ALuint* p = NULL;
  Data_Get_Struct(self, ALuint, p);
  alGetEffectf(*p, AL_REVERB_DIFFUSION, &n);
  return rb_float_new(n);
}

/// - AL::Effect#reverb_diffusion=(f)
static VALUE AL_Effect_set_reverb_diffusion(VALUE self, VALUE v) {
  ALuint* p = NULL;
  ALfloat n = (float) NUM2DBL(v);
  Data_Get_Struct(self, ALuint, p);
  alEffectf(*p, AL_REVERB_DIFFUSION, n);
  return v;
}

/*
 * Reverb - Decay HF Ratio
 */

/// - AL::Effect#reverb_decay_hfratio : f
static VALUE AL_Effect_get_reverb_decay_hfratio(VALUE self) {
  ALfloat n;
  ALuint* p = NULL;
  Data_Get_Struct(self, ALuint, p);
  alGetEffectf(*p, AL_REVERB_DECAY_HFRATIO, &n);
  return rb_float_new(n);
}

/// - AL::Effect#reverb_decay_hfratio=(f)
static VALUE AL_Effect_set_reverb_decay_hfratio(VALUE self, VALUE v) {
  ALuint* p = NULL;
  ALfloat n = (float) NUM2DBL(v);
  Data_Get_Struct(self, ALuint, p);
  alEffectf(*p, AL_REVERB_DECAY_HFRATIO, n);
  return v;
}

/*
 * Reverb - Reflections Gain
 */

/// - AL::Effect#reverb_reflections_gain : f
static VALUE AL_Effect_get_reverb_reflections_gain(VALUE self) {
  ALfloat n;
  ALuint* p = NULL;
  Data_Get_Struct(self, ALuint, p);
  alGetEffectf(*p, AL_REVERB_REFLECTIONS_GAIN, &n);
  return rb_float_new(n);
}

/// - AL::Effect#reverb_reflections_gain=(f)
static VALUE AL_Effect_set_reverb_reflections_gain(VALUE self, VALUE v) {
  ALuint* p = NULL;
  ALfloat n = (float) NUM2DBL(v);
  Data_Get_Struct(self, ALuint, p);
  alEffectf(*p, AL_REVERB_REFLECTIONS_GAIN, n);
  return v;
}

/*
 * Reverb - Reflections Delay
 */

/// - AL::Effect#reverb_reflections_delay : f
static VALUE AL_Effect_get_reverb_reflections_delay(VALUE self) {
  ALfloat n;
  ALuint* p = NULL;
  Data_Get_Struct(self, ALuint, p);
  alGetEffectf(*p, AL_REVERB_REFLECTIONS_DELAY, &n);
  return rb_float_new(n);
}

/// - AL::Effect#reverb_reflections_delay=(f)
static VALUE AL_Effect_set_reverb_reflections_delay(VALUE self, VALUE v) {
  ALuint* p = NULL;
  ALfloat n = (float) NUM2DBL(v);
  Data_Get_Struct(self, ALuint, p);
  alEffectf(*p, AL_REVERB_REFLECTIONS_DELAY, n);
  return v;
}

/*
 * Reverb - Late Reverb Gain
 */

/// - AL::Effect#reverb_late_reverb_gain : f
static VALUE AL_Effect_get_reverb_late_reverb_gain(VALUE self) {
  ALfloat n;
  ALuint* p = NULL;
  Data_Get_Struct(self, ALuint, p);
  alGetEffectf(*p, AL_REVERB_LATE_REVERB_GAIN, &n);
  return rb_float_new(n);
}

/// - AL::Effect#reverb_late_reverb_gain=(f)
static VALUE AL_Effect_set_reverb_late_reverb_gain(VALUE self, VALUE v) {
  ALuint* p = NULL;
  ALfloat n = (float) NUM2DBL(v);
  Data_Get_Struct(self, ALuint, p);
  alEffectf(*p, AL_REVERB_LATE_REVERB_GAIN, n);
  return v;
}

/*
 * Reverb - Late Reverb Delay
 */

/// - AL::Effect#reverb_late_reverb_delay : f
static VALUE AL_Effect_get_reverb_late_reverb_delay(VALUE self) {
  ALfloat n;
  ALuint* p = NULL;
  Data_Get_Struct(self, ALuint, p);
  alGetEffectf(*p, AL_REVERB_LATE_REVERB_DELAY, &n);
  return rb_float_new(n);
}

/// - AL::Effect#reverb_late_reverb_delay=(f)
static VALUE AL_Effect_set_reverb_late_reverb_delay(VALUE self, VALUE v) {
  ALuint* p = NULL;
  ALfloat n = (float) NUM2DBL(v);
  Data_Get_Struct(self, ALuint, p);
  alEffectf(*p, AL_REVERB_LATE_REVERB_DELAY, n);
  return v;
}

/*
 * Reverb - Air Absorption GainHF
 */

/// - AL::Effect#reverb_air_absorption_gainhf : f
static VALUE AL_Effect_get_reverb_air_absorption_gainhf(VALUE self) {
  ALfloat n;
  ALuint* p = NULL;
  Data_Get_Struct(self, ALuint, p);
  alGetEffectf(*p, AL_REVERB_AIR_ABSORPTION_GAINHF, &n);
  return rb_float_new(n);
}

/// - AL::Effect#reverb_air_absorption_gainhf=(f)
static VALUE AL_Effect_set_reverb_air_absorption_gainhf(VALUE self, VALUE v) {
  ALuint* p = NULL;
  ALfloat n = (float) NUM2DBL(v);
  Data_Get_Struct(self, ALuint, p);
  alEffectf(*p, AL_REVERB_AIR_ABSORPTION_GAINHF, n);
  return v;
}

/*
 * Reverb - Room Rolloff Factor
 */

/// - AL::Effect#reverb_room_rolloff_factor : f
static VALUE AL_Effect_get_reverb_room_rolloff_factor(VALUE self) {
  ALfloat n;
  ALuint* p = NULL;
  Data_Get_Struct(self, ALuint, p);
  alGetEffectf(*p, AL_REVERB_ROOM_ROLLOFF_FACTOR, &n);
  return rb_float_new(n);
}

/// - AL::Effect#reverb_room_rolloff_factor=(f)
static VALUE AL_Effect_set_reverb_room_rolloff_factor(VALUE self, VALUE v) {
  ALuint* p = NULL;
  ALfloat n = (float) NUM2DBL(v);
  Data_Get_Struct(self, ALuint, p);
  alEffectf(*p, AL_REVERB_ROOM_ROLLOFF_FACTOR, n);
  return v;
}

/*
 * Reverb - Decay HFLimit
 */

/// - AL::Effect#reverb_decay_hflimit : b
static VALUE AL_Effect_get_reverb_decay_hflimit(VALUE self) {
  ALint n;
  ALuint* p = NULL;
  Data_Get_Struct(self, ALuint, p);
  alGetEffecti(*p, AL_REVERB_DECAY_HFLIMIT, &n);
  return ((n == AL_TRUE) ? Qtrue : Qfalse);
}

/// - AL::Effect#reverb_decay_hflimit=(b)
static VALUE AL_Effect_set_reverb_decay_hflimit(VALUE self, VALUE v) {
  ALuint* p = NULL;
  Data_Get_Struct(self, ALuint, p);

  if (Qtrue == v) alEffecti(*p, AL_REVERB_DECAY_HFLIMIT, AL_TRUE);
  if (Qfalse == v) alEffecti(*p, AL_REVERB_DECAY_HFLIMIT, AL_FALSE);

  return v;
}

static void define_AL_Effect_methods() {
  /// + new
  rb_define_singleton_method(vAL_Effect, "new", &AL_Effect_new, 0);

  /// - initialize
  rb_define_method(vAL_Effect, "initialize", &AL_Effect_initialize, 0);

  /// - rw: effect_type(enum)   # AL_EFFECT_TYPE [AL_EFFECT_NULL, AL_EFFECT_REVERB]
  rb_define_method(vAL_Effect, "effect_type", &AL_Effect_get_effect_type, 0);
  rb_define_method(vAL_Effect, "effect_type=", &AL_Effect_set_effect_type, 1);

  rb_define_method(vAL_Effect, "reverb_gain", &AL_Effect_get_reverb_gain, 0);
  rb_define_method(vAL_Effect, "reverb_gain=", &AL_Effect_set_reverb_gain, 1);

  rb_define_method(vAL_Effect, "reverb_gainhf", &AL_Effect_get_reverb_gainhf, 0);
  rb_define_method(vAL_Effect, "reverb_gainhf=", &AL_Effect_set_reverb_gainhf, 1);

  rb_define_method(vAL_Effect, "reverb_density", &AL_Effect_get_reverb_density, 0);
  rb_define_method(vAL_Effect, "reverb_density=", &AL_Effect_set_reverb_density, 1);

  rb_define_method(vAL_Effect, "reverb_diffusion", &AL_Effect_get_reverb_diffusion, 0);
  rb_define_method(vAL_Effect, "reverb_diffusion=", &AL_Effect_set_reverb_diffusion, 1);

  rb_define_method(vAL_Effect, "reverb_decay_time", &AL_Effect_get_reverb_decay_time, 0);
  rb_define_method(vAL_Effect, "reverb_decay_time=", &AL_Effect_set_reverb_decay_time, 1);

  rb_define_method(vAL_Effect, "reverb_decay_hfratio", &AL_Effect_get_reverb_decay_hfratio, 0);
  rb_define_method(vAL_Effect, "reverb_decay_hfratio=", &AL_Effect_set_reverb_decay_hfratio, 1);

  rb_define_method(vAL_Effect, "reverb_reflections_gain", &AL_Effect_get_reverb_reflections_gain, 0);
  rb_define_method(vAL_Effect, "reverb_reflections_gain=", &AL_Effect_set_reverb_reflections_gain, 1);

  rb_define_method(vAL_Effect, "reverb_reflections_delay", &AL_Effect_get_reverb_reflections_delay, 0);
  rb_define_method(vAL_Effect, "reverb_reflections_delay=", &AL_Effect_set_reverb_reflections_delay, 1);

  rb_define_method(vAL_Effect, "reverb_late_reverb_gain", &AL_Effect_get_reverb_late_reverb_gain, 0);
  rb_define_method(vAL_Effect, "reverb_late_reverb_gain=", &AL_Effect_set_reverb_late_reverb_gain, 1);

  rb_define_method(vAL_Effect, "reverb_late_reverb_delay", &AL_Effect_get_reverb_late_reverb_delay, 0);
  rb_define_method(vAL_Effect, "reverb_late_reverb_delay=", &AL_Effect_set_reverb_late_reverb_delay, 1);

  rb_define_method(vAL_Effect, "reverb_air_absorption_gainhf", &AL_Effect_get_reverb_air_absorption_gainhf, 0);
  rb_define_method(vAL_Effect, "reverb_air_absorption_gainhf=", &AL_Effect_set_reverb_air_absorption_gainhf, 1);

  rb_define_method(vAL_Effect, "reverb_room_rolloff_factor", &AL_Effect_get_reverb_room_rolloff_factor, 0);
  rb_define_method(vAL_Effect, "reverb_room_rolloff_factor=", &AL_Effect_set_reverb_room_rolloff_factor, 1);

  rb_define_method(vAL_Effect, "reverb_decay_hflimit", &AL_Effect_get_reverb_decay_hflimit, 0);
  rb_define_method(vAL_Effect, "reverb_decay_hflimit=", &AL_Effect_set_reverb_decay_hflimit, 1);
}

static void setup_class_AL_Effect() {
  vAL_Effect = rb_define_class_under(vAL, "Effect", rb_cObject);
  define_AL_Effect_methods();
}

static void define_AL_Effect_consts() {
  rb_define_const(vAL_Effect, "EFFECT_NULL", vAL_EFFECT_NULL);
  rb_define_const(vAL_Effect, "EFFECT_REVERB", vAL_EFFECT_REVERB);
}

/*
 * put it all together
 */

void setup_module_AL() {
  vAL = rb_define_module("AL");
  // constants: AL
  define_AL_error_consts();
  define_AL_state_consts();
  define_AL_spec_consts();
  define_AL_distance_model_consts();
  define_AL_format_consts();
  define_AL_source_type_consts();

  // module functions: AL
  define_AL_error_funcs();
  define_AL_exts_funcs();
  define_AL_state_funcs();
  // AL::Listener
  setup_class_AL_Listener();
  // AL::SampleData
  setup_class_AL_SampleData();
  // AL::Buffer
  setup_class_AL_Buffer();
  // AL::Source
  setup_class_AL_Source();
  // AL::Filter
  setup_class_AL_Filter();
  define_AL_Filter_consts();
  // AL::AuxiliaryEffectSlot
  setup_class_AL_AuxiliaryEffectSlot();
  define_AL_AuxiliaryEffectSlot_consts();
  // AL::Effect
  setup_class_AL_Effect();
  define_AL_Effect_consts();

  lookup_functions();
}
