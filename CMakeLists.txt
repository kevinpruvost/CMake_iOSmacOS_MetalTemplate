# CMakeList.txt : CMake project for VenomEngine, include source and define
# project specific logic here.
#
cmake_minimum_required (VERSION 3.25)

project("MetalSample")

set(CMAKE_CXX_STANDARD 20)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")

set(CMAKE_DEBUG_POSTFIX "")

set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})

set(CMAKE_SHARED_LIBRARY_VERSION_STRING "")
set(CMAKE_SHARED_LIBRARY_SOVERSION "")

set(CMAKE_INSTALL_PREFIX ${CMAKE_BINARY_DIR})

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake/")
# XCode chqnges binary dir depending on the configuration
set(CMAKE_INSTALL_RPATH "${CMAKE_BINARY_DIR}/${CMAKE_BUILD_TYPE}" "${CMAKE_BINARY_DIR}/Debug")

set(RESOURCE_DIR "${CMAKE_SOURCE_DIR}/Assets")
message(STATUS "Resource dir: ${RESOURCE_DIR}")

# Only with .hlsl, .glsl, .metal, .metallib, .exr, .hdri, .ttf, .otf, .spv, .icns, .png, .jpg, .jpeg, .fbx, .obj, .mtl, .tiff
file(GLOB_RECURSE RESOURCE_FILES
    "${RESOURCE_DIR}/**/*.hlsl"
    "${RESOURCE_DIR}/**/*.glsl"
    "${RESOURCE_DIR}/**/*.metal"
    "${RESOURCE_DIR}/**/*.metallib"
    "${RESOURCE_DIR}/**/*.exr"
    "${RESOURCE_DIR}/**/*.hdri"
    "${RESOURCE_DIR}/**/*.ttf"
    "${RESOURCE_DIR}/**/*.otf"
    "${RESOURCE_DIR}/**/*.spv"
    "${RESOURCE_DIR}/**/*.png"
    "${RESOURCE_DIR}/**/*.jpg"
    "${RESOURCE_DIR}/**/*.jpeg"
    "${RESOURCE_DIR}/**/*.fbx"
    "${RESOURCE_DIR}/**/*.obj"
    "${RESOURCE_DIR}/**/*.mtl"
    "${RESOURCE_DIR}/**/*.tiff"
    "${RESOURCE_DIR}/*.hlsl"
    "${RESOURCE_DIR}/*.glsl"
    "${RESOURCE_DIR}/*.metal"
    "${RESOURCE_DIR}/*.metallib"
    "${RESOURCE_DIR}/*.exr"
    "${RESOURCE_DIR}/*.hdri"
    "${RESOURCE_DIR}/*.ttf"
    "${RESOURCE_DIR}/*.otf"
    "${RESOURCE_DIR}/*.spv"
    "${RESOURCE_DIR}/*.png"
    "${RESOURCE_DIR}/*.jpg"
    "${RESOURCE_DIR}/*.jpeg"
    "${RESOURCE_DIR}/*.fbx"
    "${RESOURCE_DIR}/*.obj"
    "${RESOURCE_DIR}/*.mtl"
    "${RESOURCE_DIR}/*.tiff"
)
message(STATUS "Resource files: ${RESOURCE_FILES}")

if (APPLE)
    enable_language(OBJC OBJCXX)

    set(CMAKE_XCODE_ATTRIBUTE_CLANG_ENABLE_MODULES YES)  # Enables Clang modules

    set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)
    if (NOT CMAKE_SYSTEM_NAME MATCHES "iOS")
        set(CMAKE_XCODE_ATTRIBUTE_LD_RUNPATH_SEARCH_PATHS "@executable_path/../Frameworks @rpath")
    else ()
        set(CMAKE_XCODE_ATTRIBUTE_LD_RUNPATH_SEARCH_PATHS "@executable_path/Frameworks @rpath")
    endif ()

    # Needed because the CMake Toolchain sets these vars to "NO", which causes packaging for iOS or other devices to fail
    # because they need to be signed
    set(CMAKE_XCODE_ATTRIBUTE_CODE_SIGNING_REQUIRED "YES")
    set(CMAKE_XCODE_ATTRIBUTE_CODE_SIGNING_ALLOWED "YES")
    # Needed to make CMake able to find the dependencies to link and bundle
    set(CMAKE_XCODE_GENERATE_TOP_LEVEL_PROJECT_ONLY TRUE)

    set(APP_BUNDLE_CONTENTS_DIR "${CMAKE_BINARY_DIR}/${PROJECT_NAME}.app/Contents")
    set(APP_BUNDLE_FRAMEWORKS_DIR "${APP_BUNDLE_CONTENTS_DIR}/Frameworks")

    # Add Compile definitions to recognize ios or macos
    if (CMAKE_SYSTEM_NAME MATCHES "iOS")
        add_compile_definitions(TARGET_OS_IOS)
        set(CMAKE_XCODE_ATTRIBUTE_TARGETED_DEVICE_FAMILY "1,2") # 1 = iPhone, 2 = iPad
    else()
        add_compile_definitions(TARGET_OS_OSX)
    endif ()

    set(CMAKE_OSX_DEPLOYMENT_TARGET "15")
    set(XCODE_VERSION "16.0")

    include(./CMake/ios.toolchain_extended.cmake)
endif()

# Only apply this for macOS and Linux platforms
if(APPLE OR UNIX)
    set(CMAKE_SHARED_LIBRARY_PREFIX "")
    set(CMAKE_STATIC_LIBRARY_PREFIX "")
endif()

# Application
add_subdirectory(src)