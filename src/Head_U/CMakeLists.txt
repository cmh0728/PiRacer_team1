cmake_minimum_required(VERSION 3.19)
project(Head_U LANGUAGES CXX)

find_package(Qt6  REQUIRED COMPONENTS Core Widgets)

qt_standard_project_setup()
qt6_add_resources(GENERATED_RESOURCES images.qrc)

qt_add_executable(Head_U
    WIN32 MACOSX_BUNDLE
    main.cpp
    mainwindow.cpp
    mainwindow.h
    mainwindow.ui
    #images.qrc
    ${GENERATED_RESOURCES}
    rpm_calculate.h rpm_calculate.cpp
)

target_link_libraries(Head_U
    PRIVATE
        Qt::Core
        Qt::Widgets
        Qt6::Gui
)

include(GNUInstallDirs)

install(TARGETS Head_U
    BUNDLE  DESTINATION .
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
)

qt_generate_deploy_app_script(
    TARGET Head_U
    OUTPUT_SCRIPT deploy_script
    NO_UNSUPPORTED_PLATFORM_ERROR
)
install(SCRIPT ${deploy_script})
