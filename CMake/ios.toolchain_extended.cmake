cmake_minimum_required(VERSION 3.20)

##
## CODESIGN_IDENTITY_FILE
##
## DO NOT FORGET TO CONFIGURE THE APPROPRIATE FILES
## CMake/codesign_identity.txt.in -> CMake/codesign_identity.txt
## Replace the variables with the appropriate values depending on your Apple Dev account
##

set(CODESIGN_IDENTITY_FILE "${PROJECT_SOURCE_DIR}/CMake/codesign_identity.txt")

# Configure the code signing identity file from a template only if it does not exist
if (NOT EXISTS ${CODESIGN_IDENTITY_FILE})
    # If the user has not given the variables CMAKE_XCODE_ATTRIBUTE_DEVELOPMENT_TEAM and CODE_SIGN_IDENTITY then error
    if (NOT DEFINED CMAKE_XCODE_ATTRIBUTE_DEVELOPMENT_TEAM OR CODE_SIGN_IDENTITY STREQUAL "")
        message(FATAL_ERROR "CMAKE_XCODE_ATTRIBUTE_DEVELOPMENT_TEAM & CODE_SIGN_IDENTITY not specified. Please give them as arguments to CMake with 'cmake -DCODE_SIGN_IDENTITY=? -DCMAKE_XCODE_ATTRIBUTE_DEVELOPMENT_TEAM=?
            or update Apple/codesign_identity.txt
            It should look like this: CODESIGN_IDENTITY=\"Apple Development: Your Name (TEAM_ID)\"
                                      CMAKE_XCODE_ATTRIBUTE_DEVELOPMENT_TEAM=8ZAWEASDZQC")
    endif ()
    configure_file(${CODESIGN_IDENTITY_FILE}.in ${CODESIGN_IDENTITY_FILE} @ONLY)
endif()

# Read the contents of the file
file(READ ${CODESIGN_IDENTITY_FILE} CODESIGN_IDENTITY_CONTENTS)

# Extract CODE_SIGN_IDENTITY
string(REGEX MATCH "CODE_SIGN_IDENTITY=\"?([^\"]+)\"?" _unused "${CODESIGN_IDENTITY_CONTENTS}")
set(CODESIGN_IDENTITY "${CMAKE_MATCH_1}")

# Extract CMAKE_XCODE_ATTRIBUTE_DEVELOPMENT_TEAM
string(REGEX MATCH "CMAKE_XCODE_ATTRIBUTE_DEVELOPMENT_TEAM=\"?([^\"]+)\"?" _unused "${CODESIGN_IDENTITY_CONTENTS}")
set(CMAKE_XCODE_ATTRIBUTE_DEVELOPMENT_TEAM "${CMAKE_MATCH_1}")

message(STATUS "Code signing identity: [${CODESIGN_IDENTITY}]")
message(STATUS "Development team: ${CMAKE_XCODE_ATTRIBUTE_DEVELOPMENT_TEAM}")

# Macro to set XCode properties
macro(set_xcode_property TARGET XCODE_PROPERTY XCODE_VALUE XCODE_RELVERSION)
    set(XCODE_RELVERSION_I "${XCODE_RELVERSION}")
    if(XCODE_RELVERSION_I STREQUAL "All")
        set_property(TARGET ${TARGET} PROPERTY XCODE_ATTRIBUTE_${XCODE_PROPERTY} "${XCODE_VALUE}")
    else()
        set_property(TARGET ${TARGET} PROPERTY XCODE_ATTRIBUTE_${XCODE_PROPERTY}[variant=${XCODE_RELVERSION_I}] "${XCODE_VALUE}")
    endif()
endmacro()

# Function to get all dependencies of a target
function(get_all_dependencies_xcode target out_var)
    get_target_property(deps ${target} LINK_LIBRARIES)
    if (deps)
        foreach(dep ${deps})
            if (TARGET ${dep})
                # Check if the target produces a binary file
                get_target_property(TYPE ${dep} TYPE)
                if (TYPE STREQUAL "SHARED_LIBRARY" OR TYPE STREQUAL "MODULE_LIBRARY")
                    list(APPEND result "${dep}")
                endif()

                # Recursively collect dependencies
                get_all_dependencies(${dep} result)
            endif()
        endforeach()
        set(${out_var} ${result} PARENT_SCOPE)
    endif()
endfunction()