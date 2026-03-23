find_package(Qt6 COMPONENTS Test Gui REQUIRED)

enable_testing()

# Shared sources for tests that need VenueModel
set(VENUE_MODEL_SOURCES
    ${CMAKE_SOURCE_DIR}/src/VenueModel.cpp
    ${CMAKE_SOURCE_DIR}/src/VenueModel.h
    ${CMAKE_SOURCE_DIR}/src/VenueHandle.h
    ${CMAKE_SOURCE_DIR}/src/OpeningHoursAlgorithms.cpp
    ${CMAKE_SOURCE_DIR}/src/OpeningHoursAlgorithms.h
    ${CMAKE_SOURCE_DIR}/src/OsmOpeningHoursParser.cpp
    ${CMAKE_SOURCE_DIR}/src/OsmOpeningHoursParser.h
    ${CMAKE_SOURCE_DIR}/src/VenueSortFilterProxyModel.cpp
    ${CMAKE_SOURCE_DIR}/src/VenueSortFilterProxyModel.h
)

set(VENUE_MODEL_LIBS Qt6::Core Qt6::Gui Qt6::Qml Qt6::Quick Qt6::Test Qt6::Positioning Qt6::Network)

# --- Opening Hours Parser Tests (standalone, no VenueModel) ---

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
    ${VENUE_MODEL_SOURCES}
)

target_include_directories(tst_opening_hours_algorithms PRIVATE ${CMAKE_SOURCE_DIR}/src)
target_link_libraries(tst_opening_hours_algorithms PRIVATE ${VENUE_MODEL_LIBS})
add_test(NAME tst_opening_hours_algorithms COMMAND tst_opening_hours_algorithms)

# --- Deduplication Tests ---

qt_add_executable(tst_deduplication
    tst_deduplication.cpp
    ${VENUE_MODEL_SOURCES}
)

target_include_directories(tst_deduplication PRIVATE ${CMAKE_SOURCE_DIR}/src)
target_link_libraries(tst_deduplication PRIVATE ${VENUE_MODEL_LIBS})
add_test(NAME tst_deduplication COMMAND tst_deduplication)
