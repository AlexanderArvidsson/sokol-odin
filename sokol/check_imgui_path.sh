# If IMGUI_PATH is set, check if it has the required files, then only compile imgui lib
if [[ ! -z "$IMGUI_PATH" ]]; then
    if [ ! "${IMGUI_PATH:0:1}" = "/" ]; then
        >&2 echo "IMGUI_PATH must be an absolute path"
        exit 1
    fi

    missing=""
    for file in c_imgui.h c_imgui.o imgui.o imgui_demo.o imgui_draw.o imgui_widgets.o imgui_tables.o; do
        if [ ! -f "$IMGUI_PATH/$file" ]; then
            missing+="$file "
        fi
    done

    if [ -n "$missing" ]; then
        >&2 echo "IMGUI_PATH is missing files $missing"
        exit 1
    fi

    echo "$IMGUI_PATH"
fi
