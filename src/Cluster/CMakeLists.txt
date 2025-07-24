cmake_minimum_required(VERSION 3.19)
project(appCluster VERSION 0.1 LANGUAGES CXX)

find_package(Qt6 REQUIRED COMPONENTS Core Quick Gui Qml)

set(CMAKE_AUTORCC ON)

qt_add_executable(appCluster
    WIN32 MACOSX_BUNDLE
    main.cpp
    qml.qrc
)

target_link_libraries(appCluster
    PRIVATE Qt6::Core Qt6::Quick Qt6::Gui Qt6::Qml
)

# … (install 타겟 등 생략) …

# deploy 스크립트 생성
if(COMMAND qt6_generate_deploy_app_script)
    if(Qt6Core_VERSION VERSION_LESS 6.5.0)
        # Qt6 < 6.5: 옛날 시그니처
        qt6_generate_deploy_app_script(
            TARGET     appCluster
            NO_UNSUPPORTED_PLATFORM_ERROR
            FILENAME_VARIABLE _deploy_script
        )
    else()
        # Qt6 >= 6.5: 최신 시그니처
        qt6_generate_deploy_app_script(
            TARGET       appCluster
            NO_UNSUPPORTED_PLATFORM_ERROR
            OUTPUT_SCRIPT _deploy_script.cmake
        )
        # FILENAME_VARIABLE 대신 OUTPUT_SCRIPT 쓸 경우 변수에 확장자 포함
        set(_deploy_script "${CMAKE_CURRENT_BINARY_DIR}/_deploy_script.cmake")
    endif()

    if(_deploy_script)
        message(STATUS "Using deploy script: ${_deploy_script}")
        install(SCRIPT "${_deploy_script}")
    endif()
else()
    message(STATUS "qt6_generate_deploy_app_script() not found; skipping deploy script.")
endif()
