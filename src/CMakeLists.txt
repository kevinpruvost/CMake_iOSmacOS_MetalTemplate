cmake_minimum_required(VERSION 3.20)

project("MetalSampleApplication")

##
# Compile Flags
##

if (CMAKE_SYSTEM_NAME MATCHES "iOS")
    set(PLATFORM_FLAG "TARGET_IOS")
elseif (CMAKE_SYSTEM_NAME MATCHES "Darwin")
    set(PLATFORM_FLAG "TARGET_MACOS")
endif ()

add_compile_definitions(
    ${PLATFORM_FLAG}
)

##
# Source files
##
file(GLOB_RECURSE Sample_Srcs
    "./*.m"
    "./*.mm"
    "./*.h"

    "**/*.m"
    "**/*.mm"
    "**/*.h"
)

add_executable(${PROJECT_NAME} ${Sample_Srcs})

# Specifying MACOSX_BUNDLE in add_executable will not work for some reason
set_target_properties(${PROJECT_NAME} PROPERTIES
    MACOSX_BUNDLE YES
)

##
# Include directories
##

target_include_directories(${PROJECT_NAME} PRIVATE
    "${CMAKE_CURRENT_SOURCE_DIR}/Application"
    "${CMAKE_CURRENT_SOURCE_DIR}/Renderer"
)

##
# Link libraries & Frameworks
##

target_link_libraries(${PROJECT_NAME} PRIVATE
    "-framework Metal"
    "-framework MetalKit"
    "-framework QuartzCore"
    "-framework Foundation"
)

if (CMAKE_SYSTEM_NAME MATCHES "iOS")
    target_link_libraries(${PROJECT_NAME} PRIVATE
        "-framework UIKit"
    )
elseif (CMAKE_SYSTEM_NAME MATCHES "Darwin")
    target_link_libraries(${PROJECT_NAME} PRIVATE
        "-framework AppKit"
        "-framework Cocoa"
    )
endif ()

##
# PLists
##

# if iOS change Info.pList to another file
if (CMAKE_SYSTEM_NAME MATCHES "iOS")
    include_p_list(${PROJECT_NAME} "${CMAKE_CURRENT_SOURCE_DIR}/Application/iOS/Info.plist")
elseif (CMAKE_SYSTEM_NAME MATCHES "Darwin")
    include_p_list(${PROJECT_NAME} "${CMAKE_CURRENT_SOURCE_DIR}/Application/macOS/Info.plist")
endif ()

##
# Asset catalog app icon set
##

include_asset_catalog(${PROJECT_NAME} "${CMAKE_CURRENT_SOURCE_DIR}/Assets.xcassets")

##
# Frameworks
##

##
# IF NEEDED, ADD MANUALLY EVERY DYLIB / FRAMEWORK THAT YOU MANUALLY LOAD AT RUNTIME HERE
# THIS MACRO ONLY DETECTS REAL DEPENDENCIES
##
get_all_dependencies_from_xcode_target(${PROJECT_NAME} EMBEDDED_LIBS)

##
# IF NEEDED, ADD MANUALLY EVERY DYLIB / FRAMEWORK THAT YOU MANUALLY LOAD AT RUNTIME HERE
##
# list(APPEND EMBEDDED_LIBS ${DYLIB_LIBS})
include_frameworks(${PROJECT_NAME} "${EMBEDDED_LIBS}")

##
# Bundle properties
##

set_target_properties(${PROJECT_NAME} PROPERTIES
    MACOSX_BUNDLE YES
    MACOSX_BUNDLE_INFO_PLIST "${PLIST_FILE}"
    MACOSX_BUNDLE_BUNDLE_NAME "GigaProject"
    MACOSX_BUNDLE_BUNDLE_VERSION "1.0.0"
    MACOSX_BUNDLE_INFO_STRING "GigaProject"
    MACOSX_BUNDLE_LONG_VERSION_STRING "1.0.0"
    MACOSX_BUNDLE_SHORT_VERSION_STRING "1.0.0"
    MACOSX_BUNDLE_GUI_IDENTIFIER "com.giga.project"
    XCODE_ATTRIBUTE_PRODUCT_BUNDLE_IDENTIFIER "com.giga.project"

    INSTALL_RPATH "@executable_path/../Frameworks"

    XCODE_LINK_BUILD_PHASE_MODE BUILT_ONLY
)

##
# Icon
##

# Icon contained in the asset catalog
set_xcode_property(${PROJECT_NAME} ASSETCATALOG_COMPILER_APPICON_NAME "AppIcon" "All")

##
# Copy resources to bundle
##

# If there are storyboards
if (CMAKE_SYSTEM_NAME MATCHES "iOS")
    include_storyboards(${PROJECT_NAME} "${CMAKE_CURRENT_SOURCE_DIR}/Application/iOS/Base.lproj/")
elseif (CMAKE_SYSTEM_NAME MATCHES "Darwin")
    include_storyboards(${PROJECT_NAME} "${CMAKE_CURRENT_SOURCE_DIR}/Application/macOS/Base.lproj/")
endif ()

include_xcode_resource_files(${PROJECT_NAME} "${RESOURCE_FILES}" "${RESOURCE_DIR}")

#target_sources(${PROJECT_NAME} PRIVATE
#    ${RESOURCE_FILES}
#)
#
#set_target_properties(${PROJECT_NAME} PROPERTIES
#    RESOURCE "${RESOURCE_FILES}"
#)
#
#foreach (FILE ${RESOURCE_FILES})
#    file(RELATIVE_PATH NEW_FILE "${RESOURCE_DIR}" ${FILE})
#    get_filename_component(NEW_FILE_PATH ${NEW_FILE} DIRECTORY)
#    message(STATUS "Copying ${FILE} to ${NEW_FILE}")
#    set_source_files_properties(${FILE}
#            PROPERTIES
#            MACOSX_PACKAGE_LOCATION "Resources/${NEW_FILE_PATH}"
#            XCODE_FILE_ATTRIBUTES "CodeSignOnCopy"
#    )
#endforeach()

# Define the path to the asset catalog (if needed later)
# set(ASSET_CATALOG_PATH "${CMAKE_CURRENT_SOURCE_DIR}/Assets.xcassets")
#set_source_files_properties(${ASSET_CATALOG_PATH}
#        PROPERTIES
#        MACOSX_PACKAGE_LOCATION "Resources"
#        XCODE_FILE_ATTRIBUTES "CodeSignOnCopy"
#        HEADER_FILE_ONLY TRUE
#)