cmake_minimum_required(VERSION 3.19)
project(Head_U LANGUAGES CXX)

# ----------------- Qt -----------------
find_package(Qt6 REQUIRED COMPONENTS Core Widgets Gui)

# Qt helper (있으면 사용)
if(COMMAND qt_standard_project_setup)
    qt_standard_project_setup()
endif()

# ----------------- Resources -----------------
qt6_add_resources(GENERATED_RESOURCES images.qrc)

# ----------------- Target -----------------
qt_add_executable(Head_U
    WIN32 MACOSX_BUNDLE
    main.cpp
    mainwindow.cpp
    mainwindow.h
    mainwindow.ui
    ${GENERATED_RESOURCES}
)

target_link_libraries(Head_U
    PRIVATE
        Qt6::Core
        Qt6::Widgets
        Qt6::Gui
)

# ----------------- Install -----------------
include(GNUInstallDirs)

install(TARGETS Head_U
    BUNDLE  DESTINATION .
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
)

# ----------------- Deploy script (Qt version portable) -----------------
set(_deploy_script "")
set(_qt_deploy_cmd "")

if(COMMAND qt_generate_deploy_app_script)
    set(_qt_deploy_cmd qt_generate_deploy_app_script)
elseif(COMMAND qt6_generate_deploy_app_script)
    set(_qt_deploy_cmd qt6_generate_deploy_app_script)
endif()

if(_qt_deploy_cmd)
    if(Qt6Core_VERSION VERSION_LESS 6.5.0)
        # Old signature requires FILENAME_VARIABLE
        cmake_language(CALL ${_qt_deploy_cmd}
            TARGET Head_U
            NO_UNSUPPORTED_PLATFORM_ERROR
            FILENAME_VARIABLE _deploy_script
        )
    else()
        # Newer signature supports OUTPUT_SCRIPT
        cmake_language(CALL ${_qt_deploy_cmd}
            TARGET Head_U
            NO_UNSUPPORTED_PLATFORM_ERROR
            OUTPUT_SCRIPT _deploy_script
        )
    endif()
endif()

if(_deploy_script)
    install(SCRIPT "${_deploy_script}")
else()
    message(STATUS "Qt deploy script not generated (missing command or unsupported signature). Skipping.")
endif()
