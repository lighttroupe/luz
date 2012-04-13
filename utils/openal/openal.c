#include "ruby.h"
#include "openal.h"
#include "AL/al.h"
#include "AL/alc.h"

/// initialize 'openal' extension
void Init_openal() {
  setup_module_AL();
  setup_module_ALC();
  setup_module_ALUT();

  //
  return;
}

