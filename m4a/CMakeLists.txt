cmake_minimum_required(VERSION 2.6)
project(m4atags)

SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -Werror -fstack-protector-all")
#SET(CMAKE_C_FLAGS_DEBUG "-DDEBUG -g3 -ggdb3")
SET(APO ${m4atags_SOURCE_DIR}/../deps/wez-atomicparsley/src)

IF(APPLE)
#IF(APPLE AND ${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
  SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -framework IOKit -framework Cocoa -framework Foundation")
  SET(LINK_FLAGS "${LINK_FLAGS} -framework IOKit -framework Cocoa -framework Foundation")
  add_definitions(-DDARWIN)

#install(FILES Packages/FindIOKit.cmake DESTINATiON )

  include(Packages/FindIOKit.cmake)
  include(Packages/FindCocoa.cmake)
  include(Packages/FindFoundation.cmake)

  INCLUDE_DIRECTORIES(/System/Library/Frameworks/Cocoa.framework)
  INCLUDE_DIRECTORIES(/System/Library/Frameworks/Cocoa.framework/Versions/A/Headers)
  INCLUDE_DIRECTORIES(/System/Library/Frameworks/Foundation.framework)
  INCLUDE_DIRECTORIES(/System/Library/Frameworks/Foundation.framework/Versions/A/Headers)
  INCLUDE_DIRECTORIES(/System/Library/Frameworks/IOKit.framework)
  INCLUDE_DIRECTORIES(/System/Library/Frameworks/IOKit.framework/Versions/A/Headers)
  #INCLUDE_DIRECTORIES(/Developer/SDKs/MacOSX10.7.sdk/System/Library/Frameworks/IOKit.framework/Versions/A/Headers)

  FIND_LIBRARY(IOKit_LIBRARY IOKit)
  FIND_LIBRARY(Cocoa_LIBRARY Cocoa)
  FIND_LIBRARY(Foundation_LIBRARY Foundation)

  MARK_AS_ADVANCED (IOKit_LIBRARY)
  MARK_AS_ADVANCED (Cocoa_LIBRARY)
  MARK_AS_ADVANCED (Foundation_LIBRARY)

ENDIF()

# TODO change for mac automatically
SET(OE .o)

include_directories(${m4atags_SOURCE_DIR}/../deps/libb64-1.2/include)
link_directories(${m4atags_SOURCE_DIR}/../deps/libb64-1.2/src)
include_directories(${APO})
include_directories(${m4atags_SOURCE_DIR}/include ${APO}/)

IF(APPLE)
  add_executable(m4atags 
    m4a_json
    m4atags
    ${APO}/nsimage.mm
    ${APO}/nsfile.mm
    ${APO}/CDtoc${OE}
    ${APO}/sha1${OE}
    ${APO}/arrays${OE}
    ${APO}/compress${OE}
    ${APO}/id3v2${OE}
    ${APO}/iconv${OE}
    ${APO}/uuid${OE}
    ${APO}/util${OE}
    ${APO}/metalist${OE}
    ${APO}/parsley${OE}
  )
  target_link_libraries(m4atags
    ${Foundation_LIBRARY}
    ${Cocoa_LIBRARY}
    ${IOKit_LIBRARY}
    mhash
    b64
    z
  )
ELSE()
  add_executable(m4atags 
    m4a_json
    m4atags
    ${APO}/CDtoc${OE}
    ${APO}/sha1${OE}
    ${APO}/arrays${OE}
    ${APO}/compress${OE}
    ${APO}/id3v2${OE}
    ${APO}/iconv${OE}
    ${APO}/uuid${OE}
    ${APO}/util${OE}
    ${APO}/metalist${OE}
    ${APO}/parsley${OE}
  )
  target_link_libraries(m4atags
    mhash
    b64
    z
  )
ENDIF()

INSTALL(TARGETS m4atags
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)
