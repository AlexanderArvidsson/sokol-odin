set -e

FRAMEWORKS_METAL="-framework Metal -framework MetalKit"
FRAMEWORKS_OPENGL="-framework OpenGL"
FRAMEWORKS_CORE="-framework Foundation -framework CoreGraphics -framework Cocoa -framework QuartzCore -framework CoreAudio -framework AudioToolbox"

build_lib() {
    src=$1
    dst=$2
    backend=$3
    arch=$4
    dep=$5
    extra=$6
    echo $dst

    # static
    MACOSX_DEPLOYMENT_TARGET=10.13 cc -c -x objective-c -arch $arch -DIMPL -D$backend c/$src.c $dep $extra
    ar rcs $dst.a $src.o $dep

    # shared
    if [ $backend = "SOKOL_METAL" ]; then
        frameworks="${frameworks} ${FRAMEWORKS_METAL}"
    else
        frameworks="${frameworks} ${FRAMEWORKS_OPENGL}"
    fi
    MACOSX_DEPLOYMENT_TARGET=10.13 cc -c -O2 -x objective-c -arch $arch -DNDEBUG -DIMPL -D$backend c/$src.c
    cc -dynamiclib -arch $arch $FRAMEWORKS_CORE $frameworks -o $dst.dylib $src.o $dep

}

libs=(log gfx app glue time audio debugtext shape gl)

imgui_path=$(./check_imgui_path.sh)
if [[ $? -eq 0 && -n "$imgui_path" ]]; then
    libs=(imgui)
fi

echo "building libs (${libs[@]})"

for lib in "${libs[@]}"; do
    dep=""
    extra=""

    if [[ $lib == imgui ]]; then
        dep="$imgui_path/c_imgui.o $imgui_path/imgui.o $imgui_path/imgui_demo.o $imgui_path/imgui_draw.o $imgui_path/imgui_widgets.o $imgui_path/imgui_tables.o"
        extra="-DImTextureID=uint64_t -DSOKOL_IMGUI_CPREFIX=ImGui_ -DCIMGUI_HEADER_PATH=\"$imgui_path/c_imgui.h\" -lstdc++"
    fi

    # ARM + Metal + Release
    build_lib sokol_$lib $lib/sokol_log_macos_arm64_metal_release SOKOL_METAL arm64 "${dep[@]}" "${extra[@]} -O2 -DNDEBUG"

    # ARM + Metal + Debug
    build_lib sokol_$lib $lib/sokol_log_macos_arm64_metal_debug SOKOL_METAL arm64 "${dep[@]}" "${extra[@]} -g"

    # x64 + Metal + Release
    build_lib sokol_$lib $lib/sokol_log_macos_x64_metal_release SOKOL_METAL x86_64 "${dep[@]}" "${extra[@]} -O2 -DNDEBUG"

    # x64 + Metal + Debug
    build_lib sokol_$lib $lib/sokol_log_macos_x64_metal_debug SOKOL_METAL x86_64 "${dep[@]}" "${extra[@]} -g"

    # ARM + GL + Release
    build_lib sokol_$lib $lib/sokol_log_macos_arm64_gl_release SOKOL_GLCORE arm64 "${dep[@]}" "${extra[@]} -O2 -DNDEBUG"

    # ARM + GL + Debug
    build_lib sokol_$lib $lib/sokol_log_macos_arm64_gl_debug SOKOL_GLCORE arm64 "${dep[@]}" "${extra[@]} -g"

    # x64 + GL + Release
    build_lib sokol_$lib $lib/sokol_log_macos_x64_gl_release SOKOL_GLCORE x86_64 "${dep[@]}" "${extra[@]} -O2 -DNDEBUG"

    # x64 + GL + Debug
    build_lib sokol_$lib $lib/sokol_log_macos_x64_gl_debug SOKOL_GLCORE x86_64 "${dep[@]}" "${extra[@]} -g"
done
