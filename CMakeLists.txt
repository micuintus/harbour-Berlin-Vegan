cmake_minimum_required(VERSION 3.21)
project(felgo-cloud-probe LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)

# --- Probe 1: direct HTTPS egress during the build -------------------------
set(PROBE_URL "https://www.felgo.com/robots.txt")
set(PROBE_FILE "${CMAKE_BINARY_DIR}/probe_egress.txt")
set(DL_START_TS "${CMAKE_BINARY_DIR}/dl_start")
execute_process(COMMAND ${CMAKE_COMMAND} -E sleep 0)
file(DOWNLOAD ${PROBE_URL} ${PROBE_FILE}
     STATUS DL_STATUS
     TIMEOUT 60
     LOG DL_LOG)
list(GET DL_STATUS 0 DL_CODE)
list(GET DL_STATUS 1 DL_MSG)
if(DL_CODE EQUAL 0)
    file(SIZE ${PROBE_FILE} DL_SIZE)
    message(STATUS "PROBE-EGRESS: OK (${DL_SIZE} bytes from ${PROBE_URL})")
else()
    message(STATUS "PROBE-EGRESS: FAILED code=${DL_CODE} msg=${DL_MSG}")
endif()

# --- Probe 2: git-over-HTTPS fetch (FetchContent) --------------------------
include(FetchContent)
set(FETCH_START "${CMAKE_BINARY_DIR}/fc_start")
FetchContent_Declare(tinyrepo
    GIT_REPOSITORY https://github.com/fmtlib/fmt.git
    GIT_TAG 11.1.4
    GIT_SHALLOW TRUE)
block()
    set(FETCHCONTENT_QUIET OFF)
    FetchContent_MakeAvailable(tinyrepo)
endblock()
message(STATUS "PROBE-GITFETCH: OK (fmt fetched, source dir ${fmt_SOURCE_DIR})")

# --- Probe 3: C++ toolchain actually compiles ------------------------------
file(WRITE "${CMAKE_BINARY_DIR}/probe.cpp"
    "int main(){return 0;}\n")
try_compile(TOOLCHAIN_OK
    "${CMAKE_BINARY_DIR}/try"
    SOURCES "${CMAKE_BINARY_DIR}/probe.cpp")
message(STATUS "PROBE-TOOLCHAIN: ${TOOLCHAIN_OK}")

# --- The app itself: minimal Felgo target so the pipeline has an artefact ---
find_package(Felgo REQUIRED)
find_package(Qt6 COMPONENTS Core REQUIRED)
qt_add_executable(felgo-cloud-probe main.cpp)
target_link_libraries(felgo-cloud-probe PRIVATE Qt6::Core)
felgo_configure_executable(felgo-cloud-probe)

message(STATUS "PROBE-DONE")
