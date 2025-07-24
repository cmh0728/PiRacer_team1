cmake_minimum_required(VERSION 3.19)

project(appCluster
    VERSION 0.1
    LANGUAGES CXX
)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

# ─── Qt 설정 ────────────────────────────────────────────────────────────────
find_package(Qt6 REQUIRED COMPONENTS Core Quick Gui Qml)

# qt_standard_project_setup (Qt 6.5 이상 권장)
if(COMMAND qt_standard_project_setup)
    qt_standard_project_setup(REQUIRES 6.5)
endif()

# ─── 실행 파일 및 QML 모듈 ────────────────────────────────────────────────────
qt_add_executable(appCluster
    WIN32
    MACOSX_BUNDLE
    main.cpp
)

qt_add_qml_module(appCluster
    URI Cluster
    VERSION 1.0
    QML_FILES
        Main.qml
        RESOURCES qml.qrc
)

qt6_add_resources(QML_RESOURCES qml.qrc)
target_sources(appCluster PRIVATE ${QML_RESOURCES})

# macOS/iOS 번들 설정
set_target_properties(appCluster PROPERTIES
    MACOSX_BUNDLE TRUE
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appCluster
    PRIVATE Qt6::Core Qt6::Quick Qt6::Gui Qt6::Qml
)

# ─── 리소스 (필요 시) ────────────────────────────────────────────────────────
# qt6_add_resources(APP_RESOURCES qml/images.qrc)
# target_sources(appCluster PRIVATE ${APP_RESOURCES})

# ─── 설치 / 배포 스크립트 ─────────────────────────────────────────────────────
include(GNUInstallDirs)

install(TARGETS appCluster
    BUNDLE     DESTINATION .
    RUNTIME    DESTINATION ${CMAKE_INSTALL_BINDIR}
    LIBRARY    DESTINATION ${CMAKE_INSTALL_LIBDIR}
)

# Qt deploy script 생성 (Qt 6.5+)
if(COMMAND qt6_generate_deploy_app_script)
    qt6_generate_deploy_app_script(
        TARGET     appCluster
        NO_UNSUPPORTED_PLATFORM_ERROR
        OUTPUT_SCRIPT _deploy_script.cmake
    )
    install(SCRIPT "${CMAKE_CURRENT_BINARY_DIR}/_deploy_script.cmake")
else()
    message(STATUS "Qt deploy script not generated (missing command or unsupported signature).")
endif()
