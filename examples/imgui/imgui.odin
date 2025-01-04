//------------------------------------------------------------------------------
//  imgui/imgui.odin
//  Test sokol-imgui. 
//  NOTE: this example needs imgui to be set up in order to run.
//------------------------------------------------------------------------------
package main

import "base:runtime"
import "core:math/linalg"
import slog "../../sokol/log"
import sg "../../sokol/gfx"
import sapp "../../sokol/app"
import sglue "../../sokol/glue"
import simgui "../../sokol/imgui"
import ig "../../imgui"

state: struct {
    pass_action: sg.Pass_Action,
    color: linalg.Vector3f32,
} = {
    pass_action = {
        colors = { 0 = { load_action = .CLEAR, clear_value = { 1.0, 0.5, 0.0, 1.0 }, } },
    },
}

init :: proc "c" () {
    context = runtime.default_context()
    sg.setup({
        environment = sglue.environment(),
        logger = { func = slog.func },
     })
    simgui.setup({
        logger = { func = slog.func },
    })
}

event :: proc(ev: ^sapp.Event) {
    // If ImGui handled the event, we should stop our own handling
    if handled := simgui.handle_event(ev^); handled {return}
}

frame :: proc "c" () {
    context = runtime.default_context()

    // call simgui.newFrame() before any ImGui calls
    simgui.new_frame(
        {
            width = sapp.width(),
            height = sapp.height(),
            delta_time = sapp.frame_duration(),
            dpi_scale = sapp.dpi_scale(),
        },
    )

    //=== UI CODE STARTS HERE
    ig.SetNextWindowPos(ig.Vec2{10, 10}, .Once)
    ig.SetNextWindowSize(ig.Vec2{400, 400}, .Once)
    ig.Begin("Hello Dear ImGui!")
    ig.ColorEdit3("Background", &state.color)
    // If you have an image you must transmute the tex id to a rawptr, not cast it.
	  // tex_id = simgui.imtextureid(state.img)
    // ig.Image(transmute(rawptr)(tex), ig.Vec2{vw / 4, vh / 4})
    ig.End()
    //=== UI CODE ENDS HERE

    sg.begin_pass({ action = state.pass_action, swapchain = sglue.swapchain() })
    simgui.render()
    sg.end_pass()
    sg.commit()
}

cleanup :: proc "c" () {
    context = runtime.default_context()
    simgui.shutdown()
    sg.shutdown()
}

main :: proc () {
    sapp.run({
        init_cb = init,
        frame_cb = frame,
        cleanup_cb = cleanup,
        width = 400,
        height = 300,
        window_title = "saudio",
        icon = { sokol_default = true },
        logger = { func = slog.func },
    })
}
