@echo off

setlocal enabledelayedexpansion

set sources=log app gfx glue time audio debugtext shape gl

REM Check for IMGUI
IF DEFINED IMGUI_PATH (
    set "missing="
    REM List of files to check
    for %%f in (c_imgui.h c_imgui.obj imgui.obj imgui_demo.obj imgui_draw.obj imgui_widgets.obj imgui_tables.obj) do (
        if not exist "%IMGUI_PATH%\%%f" (
            set "missing=!missing!%%f "
        )
    )

    REM Check if any files are missing
    if defined missing (
        echo IMGUI_PATH is missing files !missing! 1>&2
        EXIT /b 1
    )

    set sources=!sources! imgui
    set "extra_imgui=/DImTextureID=uint64_t /DSOKOL_IMGUI_CPREFIX=ImGui_ /DCIMGUI_HEADER_PATH=\"%IMGUI_PATH%\c_imgui.h\""
    set "dep_imgui=%IMGUI_PATH%\c_imgui.obj %IMGUI_PATH%\imgui.obj %IMGUI_PATH%\imgui_demo.obj %IMGUI_PATH%\imgui_draw.obj %IMGUI_PATH%\imgui_widgets.obj %IMGUI_PATH%\imgui_tables.obj"
)

echo building libs (%sources%)

for %%s in (%sources%) do (
    set "extra="
    set "dep="

    if %%s == imgui (
        set "extra=!extra_imgui!"
        set "dep=!dep_imgui!"
    )

    REM D3D11 Static Debug
    cl /c /D_DEBUG /DIMPL /DSOKOL_D3D11 c\sokol_%%s.c /Z7 !extra!
    lib /OUT:%%s\sokol_%%s_windows_x64_d3d11_debug.lib sokol_%%s.obj !dep!
    del sokol_%%s.obj

    REM D3D11 Static Release
    cl /c /O2 /DNDEBUG /DIMPL /DSOKOL_D3D11 c\sokol_%%s.c !extra!
    lib /OUT:%%s\sokol_%%s_windows_x64_d3d11_release.lib sokol_%%s.obj !dep!
    del sokol_%%s.obj

    REM GL Static Debug
    cl /c /D_DEBUG /DIMPL /DSOKOL_GLCORE c\sokol_%%s.c /Z7 !extra!
    lib /OUT:%%s\sokol_%%s_windows_x64_gl_debug.lib sokol_%%s.obj !dep!
    del sokol_%%s.obj

    REM GL Static Release
    cl /c /O2 /DNDEBUG /DIMPL /DSOKOL_GLCORE c\sokol_%%s.c !extra!
    lib /OUT:%%s\sokol_%%s_windows_x64_gl_release.lib sokol_%%s.obj !dep!
    del sokol_%%s.obj
)

if defined IMGUI_PATH (
    set "extra=!extra_imgui! /DSOKOL_INCLUDE_IMGUI"
    set "dep=!dep_imgui!"
)

REM D3D11 Debug DLL
cl /D_DEBUG /DIMPL /DSOKOL_DLL /DSOKOL_D3D11 !extra! c\sokol.c !dep! /Z7 /LDd /MDd /DLL /Fe:sokol_dll_windows_x64_d3d11_debug.dll /link /INCREMENTAL:NO

REM D3D11 Release DLL
cl /D_DEBUG /DIMPL /DSOKOL_DLL /DSOKOL_D3D11 !extra! c\sokol.c !dep! /LD /MD /DLL /Fe:sokol_dll_windows_x64_d3d11_release.dll /link /INCREMENTAL:NO

REM GL Debug DLL
cl /D_DEBUG /DIMPL /DSOKOL_DLL /DSOKOL_GLCORE !extra! c\sokol.c !dep! /Z7 /LDd /MDd /DLL /Fe:sokol_dll_windows_x64_gl_debug.dll /link /INCREMENTAL:NO

REM GL Release DLL
cl /D_DEBUG /DIMPL /DSOKOL_DLL /DSOKOL_GLCORE !extra! c\sokol.c !dep! /LD /MD /DLL /Fe:sokol_dll_windows_x64_gl_release.dll /link /INCREMENTAL:NO

ENDLOCAL

del *.obj
