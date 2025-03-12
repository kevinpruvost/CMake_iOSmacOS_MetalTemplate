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

add_executable(${PROJECT_NAME} MACOSX_BUNDLE ${Sample_Srcs})

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
    set(PLIST_FILE "${CMAKE_CURRENT_SOURCE_DIR}/Application/iOS/Info.plist")
elseif (CMAKE_SYSTEM_NAME MATCHES "Darwin")
    set(PLIST_FILE "${CMAKE_CURRENT_SOURCE_DIR}/Application/macOS/Info.plist")
endif ()

set_target_properties(${PROJECT_NAME} PROPERTIES
    MACOSX_BUNDLE YES
    MACOSX_BUNDLE_INFO_PLIST "${PLIST_FILE}"
    RESOURCE "${RESOURCE_FILES}"
)

##
# Asset catalog app icon set
##

# Define the path to the asset catalog
set(ASSET_CATALOG_PATH "${CMAKE_CURRENT_SOURCE_DIR}/Assets.xcassets")

message(STATUS "ASSET_CATALOG_PATH=${ASSET_CATALOG_PATH}")

# Ensure the asset catalog is included in the bundle resources
set_source_files_properties(${ASSET_CATALOG_PATH}
        PROPERTIES
        MACOSX_PACKAGE_LOCATION "Resources"
)

# Asset catalog app icon set
list(APPEND app_icon_set "${ASSET_CATALOG_PATH}/AppIcon.appiconset")
list(APPEND app_icon_set "${ASSET_CATALOG_PATH}/Contents.json")
set_source_files_properties(${app_icon_set} PROPERTIES
        MACOSX_PACKAGE_LOCATION "Resources/Assets.xcassets"
)

# Asset catalog icon files
file(GLOB app_icon_files CONFIGURE_DEPENDS "${ASSET_CATALOG_PATH}/AppIcon.appiconset/*.png")
list(APPEND app_icon_files "${ASSET_CATALOG_PATH}/AppIcon.appiconset/Contents.json")
set_source_files_properties(${app_icon_files} PROPERTIES
        MACOSX_PACKAGE_LOCATION "Resources/Assets.xcassets/AppIcon.appiconset"
)

target_sources(${PROJECT_NAME} PRIVATE
    ${ASSET_CATALOG_PATH}
)

##
# Frameworks
##

get_all_dependencies_xcode(${PROJECT_NAME} EMBEDDED_LIBS)

##
# IF NEEDED, ADD MANUALLY EVERY DYLIB / FRAMEWORK THAT YOU MANUALLY LOAD AT RUNTIME HERE
##
# list(APPEND EMBEDDED_LIBS ${DYLIB_LIBS})

set_target_properties(${PROJECT_NAME} PROPERTIES
    XCODE_EMBED_FRAMEWORKS "${EMBEDDED_LIBS}"
    XCODE_EMBED_FRAMEWORKS_CODE_SIGN_ON_COPY ON
    XCODE_LINK_BUILD_PHASE_MODE BUILT_ONLY
)

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

set_xcode_property (${PROJECT_NAME} ASSETCATALOG_COMPILER_APPICON_NAME "AppIcon" "All")

##
# Copy resources to bundle
##

# If there are storyboards
set(STORYBOARD_FILES "")
if (CMAKE_SYSTEM_NAME MATCHES "iOS")
    set(STORYBOARD_DIR "${CMAKE_CURRENT_SOURCE_DIR}/Application/iOS/Base.lproj/")
    list(APPEND STORYBOARD_FILES "${STORYBOARD_DIR}/Main.storyboard")
    list(APPEND STORYBOARD_FILES "${STORYBOARD_DIR}/LaunchScreen.storyboard")
elseif (CMAKE_SYSTEM_NAME MATCHES "Darwin")
    set(STORYBOARD_DIR "${CMAKE_CURRENT_SOURCE_DIR}/Application/macOS/Base.lproj/")
    list(APPEND STORYBOARD_FILES "${STORYBOARD_DIR}/Main.storyboard")
endif ()

set(RESOURCE_FILES_TOTAL ${RESOURCE_FILES} ${STORYBOARD_FILES})
target_sources(${PROJECT_NAME} PRIVATE
    ${RESOURCE_FILES_TOTAL}
)

set_source_files_properties(${STORYBOARD_FILES} PROPERTIES
    XCODE_FILE_TYPE "file.storyboard"
)

set(BUNDLE_APP_LOCATION "${CMAKE_INSTALL_PREFIX}/${PROJECT_NAME}.app" PARENT_SCOPE)
set(FRAMEWORKS_BUNDLE_LOCATION "${BUNDLE_APP_LOCATION}/Contents/Frameworks" PARENT_SCOPE)
set(RESOURCES_BUNDLE_LOCATION "${BUNDLE_APP_LOCATION}/Contents/Resources" PARENT_SCOPE)

foreach (FILE ${RESOURCE_FILES})
    file(RELATIVE_PATH NEW_FILE "${RESOURCE_DIR}" ${FILE})
    get_filename_component(NEW_FILE_PATH ${NEW_FILE} DIRECTORY)
    message(STATUS "Copying ${FILE} to ${NEW_FILE}")
    set_source_files_properties(${FILE}
            PROPERTIES
            MACOSX_PACKAGE_LOCATION "Resources/${NEW_FILE_PATH}"
            XCODE_FILE_ATTRIBUTES "CodeSignOnCopy"
    )
    set(RESOURCES_BUNDLE_FILES ${RESOURCES_BUNDLE_FILES} ${RESOURCES_BUNDLE_LOCATION}/${NEW_FILE} PARENT_SCOPE)
endforeach()

foreach (FILE ${STORYBOARD_FILES})
    file(RELATIVE_PATH NEW_FILE "${STORYBOARD_DIR}" ${FILE})
    get_filename_component(NEW_FILE_PATH ${NEW_FILE} DIRECTORY)
    message(STATUS "Copying ${FILE} to ${NEW_FILE}")
    set_source_files_properties(${FILE}
            PROPERTIES
            MACOSX_PACKAGE_LOCATION "Resources"
            XCODE_FILE_ATTRIBUTES "CodeSignOnCopy"
    )
    set(RESOURCES_BUNDLE_FILES ${RESOURCES_BUNDLE_FILES} ${RESOURCES_BUNDLE_LOCATION}/${NEW_FILE} PARENT_SCOPE)
endforeach()

# Define the path to the asset catalog (if needed later)
# set(ASSET_CATALOG_PATH "${CMAKE_CURRENT_SOURCE_DIR}/Assets.xcassets")
#set_source_files_properties(${ASSET_CATALOG_PATH}
#        PROPERTIES
#        MACOSX_PACKAGE_LOCATION "Resources"
#        XCODE_FILE_ATTRIBUTES "CodeSignOnCopy"
#        HEADER_FILE_ONLY TRUE
#)