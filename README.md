[![Odin](https://github.com/floooh/sokol-odin/actions/workflows/main.yml/badge.svg)](https://github.com/floooh/sokol-odin/actions/workflows/main.yml)

Auto-generated [Odin](https://github.com/odin-lang/odin) bindings for the [sokol headers](https://github.com/floooh/sokol).

To include sokol in your project you can copy the [sokol](sokol/) directory.

## BUILD

Supported platforms are: Windows, macOS, Linux (with X11)

On Linux install the following packages: libglu1-mesa-dev, mesa-common-dev, xorg-dev, libasound-dev
(or generally: the dev packages required for X11, GL and ALSA development)

1. First build the required static link libraries:

    ```
    cd sokol
    # on macOS:
    ./build_clibs_macos.sh
    # on Linux:
    ./build_clibs_linux.sh
    # on Windows with MSVC (from a 'Visual Studio Developer Command Prompt')
    build_clibs_windows.cmd
    cd ..
    ```

2. Create a build directory and cd into it:
    ```
    mkdir build
    cd build
    ```

3. Build and run the samples:
    ```
    odin run ../examples/clear -debug
    odin run ../examples/triangle -debug
    odin run ../examples/quad -debug
    odin run ../examples/bufferoffsets -debug
    odin run ../examples/cube -debug
    odin run ../examples/noninterleaved -debug
    odin run ../examples/texcube -debug
    odin run ../examples/shapes -debug
    odin run ../examples/offscreen -debug
    odin run ../examples/instancing -debug
    odin run ../examples/mrt -debug
    odin run ../examples/blend -debug
    odin run ../examples/debugtext -debug
    odin run ../examples/debugtext-print -debug
    odin run ../examples/debugtext-userfont -debug
    odin run ../examples/saudio -debug
    odin run ../examples/sgl -debug
    odin run ../examples/sgl-points -debug
    odin run ../examples/sgl-context -debug
    odin run ../examples/vertexpull -debug
    ```

    By default, the backend 3D API will be selected based on the target platform:

    - macOS: Metal
    - Windows: D3D11
    - Linux: GL

    To force the GL backend on macOS or Windows, build with ```-define:SOKOL_USE_GL=true```:

    ```
    odin run ../examples/clear -debug -define:SOKOL_USE_GL=true
    ```

    The ```clear``` sample prints the selected backend to the terminal:

    ```
    odin run ../examples/clear -debug -define:SOKOL_USE_GL=true
    >> using GL backend
    ```

    On Windows, you can get rid of the automatically opened terminal window
    by building with the ```-subsystem:windows``` option:

    ```
    odin build ../examples/clear -subsystem:windows
    ```

## Dear ImGui support

The sokol-odin bindings come with sokol_imgui.h (exposed as the Odin package
`sokol/imgui`), but integration into a project requires some extra
steps, mainly because I didn't want to add a
[cimgui](https://github.com/cimgui/cimgui) dependency to the sokol-odin package.

The main steps to create Dear ImGui apps with sokol-odin are:

1. 'bring your own cimgui and imgui', you need a folder with `c_imgui.h c_imgui.o imgui.o imgui_demo.o imgui_draw.o imgui_widgets.o imgui_tables.o` files.
2. compile the sokol imgui library by setting the `IMGUI_PATH` environment variable (must be an absolute path):
   ```bash
   IMGUI_PATH=/path/to/imgui ./build_clibs_PLATFORM.sh
   ```
   where `PLATFORM` is your platform of choice.
    
   The easiest way to get started is to use [`odin-imgui`](https://gitlab.com/L-4/odin-imgui) because it places all built files in its `temp` folder.
   Build it according to its instructions, and then run:
   ```bash
   IMGUI_PATH=/path/to/odin-imgui/temp ./build_clibs_PLATFORM.sh
   ```

Here's a sample setup:
```
project/
- vendor/
  - imgui/ (from odin-imgui)
    - ...
    - temp/ (generated)
  - sokol/
    - ...
    - build_clibs_platform.sh
```

1. Follow the [`odin-imgui`](https://gitlab.com/L-4/odin-imgui) instructions to get the necessary files for sokol imgui.
2. Then from within `project/vendor/sokol/` folder, run:
   ```bash
   IMGUI_PATH=$(realpath ../imgui/temp) ./build_clibs_PLATFORM.sh
   ```
3. To import and use in your project:
    ```odin
    import ig "../vendor/imgui"
    import simgui "../vendor/sokol/imgui"
    ```

Check the usage example in `examples/imgui/imgui.odin`, which requires `odin-imgui` as an `imgui/` folder next to `sokol/` in the root, follow the above instructions to try it.

### A note about texture IDs
Right now, as sokol imgui treats `ImTextureID` as `uint64_t`, but imgui treats it as `void *` (any), it must be transmuted to a `rawptr`.
See the [imgui FAQ](https://github.com/ocornut/imgui/blob/master/docs/FAQ.md#q-how-can-i-display-an-image-what-is-imtextureid-how-does-it-work) for more on why this is. In the future, this library could also treat `ImTextureID` as a `rawptr` to help with interopability with imgui bindings.

If your chosen library for imgui bindings can be configured to use `uint64_t`, then transmuting might not be necessary.
