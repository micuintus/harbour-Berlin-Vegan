find_package(Qt6 COMPONENTS Test REQUIRED)

enable_testing()

# --- Opening Hours Parser Tests ---

qt_add_executable(tst_osm_opening_hours
    tst_osm_opening_hours.cpp
    ${CMAKE_SOURCE_DIR}/src/OsmOpeningHoursParser.cpp
    ${CMAKE_SOURCE_DIR}/src/OsmOpeningHoursParser.h
)

target_include_directories(tst_osm_opening_hours PRIVATE ${CMAKE_SOURCE_DIR}/src)
target_link_libraries(tst_osm_opening_hours PRIVATE Qt6::Core Qt6::Test)
add_test(NAME tst_osm_opening_hours COMMAND tst_osm_opening_hours)

# --- Opening Hours Algorithms Tests ---

qt_add_executable(tst_opening_hours_algorithms
    tst_opening_hours_algorithms.cpp
    ${CMAKE_SOURCE_DIR}/src/OpeningHoursAlgorithms.cpp
    ${CMAKE_SOURCE_DIR}/src/OpeningHoursAlgorithms.h
    ${CMAKE_SOURCE_DIR}/src/OsmOpeningHoursParser.cpp
    ${CMAKE_SOURCE_DIR}/src/OsmOpeningHoursParser.h
    ${CMAKE_SOURCE_DIR}/src/VenueModel.cpp
    ${CMAKE_SOURCE_DIR}/src/VenueModel.h
    ${CMAKE_SOURCE_DIR}/src/VenueSortFilterProxyModel.cpp
    ${CMAKE_SOURCE_DIR}/src/VenueSortFilterProxyModel.h
    ${CMAKE_SOURCE_DIR}/src/VenueHandle.h
)

target_include_directories(tst_opening_hours_algorithms PRIVATE ${CMAKE_SOURCE_DIR}/src)
target_link_libraries(tst_opening_hours_algorithms PRIVATE
    Qt6::Core Qt6::Qml Qt6::Quick Qt6::Test Qt6::Positioning Qt6::Network
)
add_test(NAME tst_opening_hours_algorithms COMMAND tst_opening_hours_algorithms)
