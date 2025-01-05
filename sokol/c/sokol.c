#if defined(IMPL)
#define SOKOL_IMPL
#endif

#include "sokol_defines.h"

#include "sokol_audio.h"
#include "sokol_app.h"
#include "sokol_gfx.h"
#include "sokol_log.h"
#include "sokol_time.h"
#include "sokol_glue.h"

#include "sokol_gl.h"
#include "sokol_shape.h"
#include "sokol_debugtext.h"

#if defined(SOKOL_INCLUDE_IMGUI)
#if defined(IMPL)
#ifndef CIMGUI_HEADER_PATH
#define CIMGUI_HEADER_PATH "cimgui.h"
#endif
// NOTE: this is only needed for the old cimgui.h bindings
#define CIMGUI_DEFINE_ENUMS_AND_STRUCTS
#include CIMGUI_HEADER_PATH
#endif

#include "sokol_imgui.h"
#endif
