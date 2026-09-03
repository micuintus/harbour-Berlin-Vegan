#!/usr/bin/env bash
# Build the Kirigami Android APK (arm64-v8a).
#
# Prerequisites, all verified paths overridable via env:
#   Felgo Android Qt kit with qtdeclarative        (BV_ANDROID_QT)
#   Felgo desktop Qt kit (host tools, QmlTools)    (BV_FELGO_DIR)
#   ECM v6.18 + Kirigami v6.18 cross-built into a  (KF6_ANDROID_PREFIX)
#     prefix; lib/libKF6Kirigami.so symlink expected
#   QMapLibre 4 Android arm64 prefix               (QMLLIBRE_ANDROID_PREFIX)
#
# The dual prefixes in CMAKE_PREFIX_PATH/CMAKE_FIND_ROOT_PATH are load-bearing:
# the Android kit lacks host-tools packages (Qt6QmlTools, Qt6CoreTools) which
# the desktop kit carries, and Qt's Android toolchain only searches paths
# registered as FIND_ROOT_PATHs.
#
# Usage: scripts/build-kirigami-android.sh

set -euo pipefail
cd "$(dirname "$0")/.."

ANDROID_QT="${BV_ANDROID_QT:-$HOME/Felgo/Felgo/android_arm64_v8a}"
HOST_QT="${BV_FELGO_DIR:-$HOME/Felgo/Felgo/macos}"
KF6_PREFIX="${KF6_ANDROID_PREFIX:-$HOME/devel/BVApp/kf6-android/kf6-prefix}"
QL_PREFIX="${QMLLIBRE_ANDROID_PREFIX:-$HOME/qmaplibre-android-gl}"
: "${ANDROID_SDK_ROOT:?set ANDROID_SDK_ROOT}"
: "${ANDROID_NDK_ROOT:?set ANDROID_NDK_ROOT}"
export ANDROID_HOME="${ANDROID_HOME:-$ANDROID_SDK_ROOT}"

BUILD=build-kirigami-android

cmake -B "$BUILD" -S . -GNinja \
    -DBV_PLATFORM=kirigami \
    -DCMAKE_TOOLCHAIN_FILE="$ANDROID_QT/lib/cmake/Qt6/qt.toolchain.cmake" \
    -DCMAKE_PREFIX_PATH="$ANDROID_QT;$HOST_QT;$KF6_PREFIX;$QL_PREFIX" \
    -DCMAKE_FIND_ROOT_PATH="$ANDROID_QT;$HOST_QT;$KF6_PREFIX;$QL_PREFIX" \
    -DQT_HOST_PATH="$HOST_QT" \
    -DQMapLibre_DIR="$QL_PREFIX/lib/cmake/QMapLibre" \
    -DKF6_ANDROID_PREFIX="$KF6_PREFIX" \
    -DANDROID_ABI=arm64-v8a \
    -DANDROID_PLATFORM=android-28 \
    -DCMAKE_BUILD_TYPE=Release

cmake --build "$BUILD" --target harbour-berlin-vegan
cmake --build "$BUILD" --target harbour-berlin-vegan_prepare_apk_dir

"$HOST_QT/bin/androiddeployqt" \
    --input "$BUILD/android-harbour-berlin-vegan-deployment-settings.json" \
    --output "$BUILD/android-build" \
    --android-platform android-35 \
    --gradle

find "$BUILD/android-build/build/outputs/apk" -name '*.apk' -exec ls -la {} +
