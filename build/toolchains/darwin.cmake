# options
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -stdlib=libc++ -std=c++11")
set(CXX_FLAGS_DEBUG "-g -O0")
set(EXECUTABLE_NAME "tangram")

add_definitions(-DPLATFORM_OSX)

# include headers for homebrew-installed libraries
include_directories(/usr/local/include)

# load core library
include_directories(${PROJECT_SOURCE_DIR}/core/include/)
include_directories(${PROJECT_SOURCE_DIR}/core/include/jsoncpp/)
add_subdirectory(${PROJECT_SOURCE_DIR}/core)
include_recursive_dirs(${PROJECT_SOURCE_DIR}/core/src/*.h)

# add sources and include headers
set(OSX_EXTENSIONS_FILES *.mm *.cpp)
foreach(_ext ${OSX_EXTENSIONS_FILES})
    find_sources_and_include_directories(
        ${PROJECT_SOURCE_DIR}/osx/src/*.h 
        ${PROJECT_SOURCE_DIR}/osx/src/${_ext})
endforeach()

# locate resource files to include
file(GLOB_RECURSE RESOURCES ${PROJECT_SOURCE_DIR}/osx/resources/**)
file(GLOB_RECURSE CORE_RESOURCES ${PROJECT_SOURCE_DIR}/core/resources/**)
list(APPEND RESOURCES ${CORE_RESOURCES})

# link and build functions
function(link_libraries)

    find_library(OPENGL_FRAMEWORK OpenGL)
    find_library(COCOA_FRAMEWORK Cocoa)
    find_library(IOKIT_FRAMEWORK IOKit)
    find_library(CORE_FOUNDATION_FRAMEWORK CoreFoundation)
    find_library(CORE_VIDEO_FRAMEWORK CoreVideo)
    find_library(GLFW glfw3)
    
    list(APPEND GLFW_LIBRARIES 
        ${OPENGL_FRAMEWORK} 
        ${COCOA_FRAMEWORK} 
        ${IOKIT_FRAMEWORK} 
        ${CORE_FOUNDATION_FRAMEWORK}   
        ${CORE_VIDEO_FRAMEWORK} 
        ${GLFW})

    target_link_libraries(${EXECUTABLE_NAME} -lcurl) #use system libcurl
    target_link_libraries(${EXECUTABLE_NAME} ${PROJECT_SOURCE_DIR}/osx/precompiled/libtess2/libtess2.a)
    target_link_libraries(${EXECUTABLE_NAME} core ${GLFW_LIBRARIES})

    # add resource files and property list
    set_target_properties(${EXECUTABLE_NAME} PROPERTIES
        MACOSX_BUNDLE_INFO_PLIST ${PROJECT_SOURCE_DIR}/osx/resources/tangram-Info.plist
        RESOURCE "${RESOURCES}")

endfunction()

function(build) 

    add_executable(${EXECUTABLE_NAME} MACOSX_BUNDLE ${SOURCES} ${RESOURCES})

endfunction()