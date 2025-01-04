set -e

build_lib_x64() {
    local src=$1
    local dst=$2
    local backend=$3
    local dep=$4
    local extra=$5
    echo $dst

    # static
    cc -pthread -c -DIMPL -D$backend c/$src.c $extra
    ar rcs $dst.a $src.o $dep

    # shared
    echo "cc -pthread -shared -fPIC -DIMPL -D$backend -o $dst.so c/$src.c $dep $extra"
    cc -pthread -shared -fPIC -DIMPL -D$backend -o $dst.so c/$src.c $dep $extra
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
        dep="$IMGUI_PATH/c_imgui.o $IMGUI_PATH/imgui.o $IMGUI_PATH/imgui_demo.o $IMGUI_PATH/imgui_draw.o $IMGUI_PATH/imgui_widgets.o $IMGUI_PATH/imgui_tables.o"
        extra="-DImTextureID=uint64_t -DSOKOL_IMGUI_CPREFIX=ImGui_ -DCIMGUI_HEADER_PATH=\"$IMGUI_PATH/c_imgui.h\" -lstdc++"
    fi

    # x64 + GL + Release
    build_lib_x64 "sokol_$lib" "$lib/sokol_${lib}_linux_x64_gl_release" SOKOL_GLCORE "${dep[@]}" "${extra[@]} -O2 -DNDEBUG"

    # x64 + GL + Debug
    build_lib_x64 "sokol_$lib" "$lib/sokol_${lib}_linux_x64_gl_debug" SOKOL_GLCORE "${dep[@]}" "${extra[@]} -g"
done

rm *.o
