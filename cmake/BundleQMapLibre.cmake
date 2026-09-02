# Runs POST_BUILD on the Felgo bundle. Usage:
#   cmake -DBUNDLE=<app dir> -DQL_DIR=<QMapLibre_DIR> -P BundleQMapLibre.cmake
#
# Two inconsistencies make the default Felgo deployment unshippable with a
# replaced map stack: PlugIns keeps the SDK's v3 geoservices plugin while the
# binary's rpath resolves our v4 frameworks, and that rpath is an absolute
# path into the build host's home directory. Both are fixed here; everything
# touched is re-signed ad hoc, as arm64 macOS requires.

set(_QL_BUNDLE "${BUNDLE}")
set(_QL_FWDIR "${_QL_BUNDLE}/Contents/Frameworks")
set(_QL_PLUGINDIR "${_QL_BUNDLE}/Contents/PlugIns/geoservices")
set(_QL_SRC_LIB "${QL_DIR}/../..")
# install_name_tool compares rpath strings literally; it does not normalise
# "..", so every delete must use the resolved absolute form.
get_filename_component(_QL_LIB_NORM "${QL_DIR}/../.." ABSOLUTE)
set(_QL_SRC_PLUGIN "${QL_DIR}/../../../plugins/geoservices/libqtgeoservices_maplibre.dylib")
set(_QL_BIN "${_QL_BUNDLE}/Contents/MacOS/harbour-berlin-vegan")

function(_ql_run)
    execute_process(COMMAND ${ARGV} ERROR_QUIET OUTPUT_QUIET RESULT_VARIABLE _rc)
    if(NOT _rc EQUAL 0)
        message(WARNING "BundleQMapLibre step failed: ${ARGV} -> ${_rc}")
    endif()
endfunction()

_ql_run(${CMAKE_COMMAND} -E make_directory "${_QL_FWDIR}")

foreach(fw QMapLibre QMapLibreLocation QMapLibreWidgets QMapLibreQuickPrivate)
    if(NOT EXISTS "${_QL_SRC_LIB}/${fw}.framework")
        continue()
    endif()
    # cp -R, not cmake -E copy_directory: a .framework is a symlink bundle and
    # CMake's copier trips over Versions/Current.
    _ql_run(/bin/cp -R
        "${_QL_SRC_LIB}/${fw}.framework" "${_QL_FWDIR}/")
    _ql_run(codesign --force --deep --sign - "${_QL_FWDIR}/${fw}.framework")
endforeach()

# The SDK's v3 plugin resolving against our v4 frameworks: same soname,
# different ABI. There is no version of that which ships.
_ql_run(${CMAKE_COMMAND} -E remove "${_QL_PLUGINDIR}/libqtgeoservices_maplibre.dylib")
_ql_run(${CMAKE_COMMAND} -E copy_if_different
    "${_QL_SRC_PLUGIN}" "${_QL_PLUGINDIR}/libqtgeoservices_maplibre.dylib")
_ql_run(install_name_tool -add_rpath @executable_path/../Frameworks
    "${_QL_PLUGINDIR}/libqtgeoservices_maplibre.dylib")
_ql_run(codesign --force --sign - "${_QL_PLUGINDIR}/libqtgeoservices_maplibre.dylib")

# Order is load-bearing: the binary links QMapLibre directly, and both the
# link line and Felgo's deploy add rpaths that resolve a QMapLibre.framework
# (v3) elsewhere. Ours must be searched first, and each stale rpath can occur
# more than once, so deletions repeat until exhausted.
foreach(_i 1 2 3)
    _ql_run(install_name_tool -delete_rpath "${_QL_LIB_NORM}" "${_QL_BIN}")
    if(FELGO_LIB)
        _ql_run(install_name_tool -delete_rpath "${FELGO_LIB}" "${_QL_BIN}")
    endif()
    _ql_run(install_name_tool -delete_rpath @executable_path/../Frameworks "${_QL_BIN}")
endforeach()
_ql_run(install_name_tool -add_rpath @executable_path/../Frameworks "${_QL_BIN}")
if(FELGO_LIB)
    _ql_run(install_name_tool -add_rpath "${FELGO_LIB}" "${_QL_BIN}")
endif()
_ql_run(codesign --force --sign - "${_QL_BIN}")

message(STATUS "BundleQMapLibre: v4 frameworks + plugin bundled into ${_QL_BUNDLE}")
