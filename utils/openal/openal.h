#ifndef RUBY_OPENAL_H
#define RUBY_OPENAL_H

#ifdef __cplusplus
extern "C" {
#endif

#include "AL/al.h"

#include "openal_al.h"
#include "openal_alc.h"
#include "openal_alut.h"

/// data types
typedef struct {
  void* buf;
  ALsizei bufsize;
  ALenum fmt;
  ALuint freq;
} al_sample_data_t;


/// function prototypes
extern void Init_openal();

/// AL::SampleData internal object interface
extern al_sample_data_t* AL_SampleData_new();
extern void AL_SampleData_free(al_sample_data_t* p);


/// helper macros
#define albool2rbbool(b) ((b)?(Qtrue):(Qfalse))

#define RARRAY2ARRAY(rbary, ary, n, convf) \
VALUE ___v; int ___c;\
for(___c=0;___c<n;___c++){\
 ___v=rb_ary_entry(rbary,___c);\
 ary[___c]=convf(___v);}

#define ARRAY2RARRAY(ary, rbary, n, convf) \
int ___c; \
for(___c=0;___c<n;___c++){\
 rb_ary_push(rbary, convf(ary[___c]));}\


#ifdef __cplusplus
}
#endif

#endif
