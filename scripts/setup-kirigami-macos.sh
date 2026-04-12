#!/usr/bin/env bash
# scripts/setup-kirigami-macos.sh
#
# One-time setup for the Berlin-Vegan Kirigami macOS development environment.
# Checks prerequisites, installs KF6 Kirigami via Homebrew (KDE tap), builds
# QMapLibre from source and installs it into the Homebrew Qt prefix so that
# CMake's find_package(QMapLibre) works without extra paths.
#
# Usage:
#   bash scripts/setup-kirigami-macos.sh [OPTIONS]
#
# Options:
#   --skip-maplibre    Skip the QMapLibre clone/build step
#   --update-maplibre  Force a git pull + rebuild even if already built
#   -h, --help         Show this help
#
# After running, copy (or let the script create) CMakeUserPresets.json from
# CMakeUserPresets.json.example and set BV_QT_DIR / BV_KF6_DIR in your shell.

set -euo pipefail

# ─── paths ────────────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
EXTERN_DIR="${PROJECT_ROOT}/extern"
QMAPLIBRE_SRC="${EXTERN_DIR}/qmaplibre"

# ─── flags ────────────────────────────────────────────────────────────────────
SKIP_MAPLIBRE=false
UPDATE_MAPLIBRE=false

for arg in "$@"; do
    case "$arg" in
        --skip-maplibre)   SKIP_MAPLIBRE=true ;;
        --update-maplibre) UPDATE_MAPLIBRE=true ;;
        -h|--help)
            sed -n '2,/^[^#]/{ /^#/{ s/^# \?//; p }; /^[^#]/q }' "$0"
            exit 0
            ;;
        *) echo "Unknown option: $arg" >&2; exit 1 ;;
    esac
done

# ─── colours ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

info()    { echo -e "${BLUE}==>${NC} ${BOLD}$*${NC}"; }
success() { echo -e "  ${GREEN}✓${NC} $*"; }
warn()    { echo -e "  ${YELLOW}!${NC} $*"; }
die()     { echo -e "\n${RED}Error:${NC} $*\n" >&2; exit 1; }

echo -e "\n${BOLD}Berlin-Vegan – Kirigami macOS setup${NC}\n"

# ─────────────────────────────────────────────────────────────────────────────
# 1. Homebrew
# ─────────────────────────────────────────────────────────────────────────────
info "Checking Homebrew..."
command -v brew >/dev/null 2>&1 \
    || die "Homebrew not found. Install it from https://brew.sh then re-run."
BREW_PREFIX="$(brew --prefix)"
success "Homebrew at ${BREW_PREFIX}"

# ─────────────────────────────────────────────────────────────────────────────
# 2. Ninja
# ─────────────────────────────────────────────────────────────────────────────
info "Checking Ninja..."
if ! command -v ninja >/dev/null 2>&1; then
    info "Installing Ninja..."
    brew install ninja
fi
success "ninja $(ninja --version)"

# ─────────────────────────────────────────────────────────────────────────────
# 3. Qt (Homebrew)
# ─────────────────────────────────────────────────────────────────────────────
info "Detecting Qt (Homebrew)..."
QT_BREW_PREFIX="$(brew --prefix qt 2>/dev/null || true)"
if [[ -z "$QT_BREW_PREFIX" || ! -d "$QT_BREW_PREFIX" ]]; then
    info "Qt not found – installing via Homebrew (this may take a while)..."
    brew install qt
    QT_BREW_PREFIX="$(brew --prefix qt)"
fi

QT_VERSION="$("${QT_BREW_PREFIX}/bin/qmake" -query QT_VERSION 2>/dev/null || echo "unknown")"
[[ "$QT_VERSION" == unknown ]] && die "qmake found at ${QT_BREW_PREFIX}/bin/qmake but failed to report version."
success "Qt ${QT_VERSION} at ${QT_BREW_PREFIX}"

# ─────────────────────────────────────────────────────────────────────────────
# 4. KF6 Kirigami  (KDE Homebrew tap)
# ─────────────────────────────────────────────────────────────────────────────
info "Detecting KF6 Kirigami..."

KDE_TAP="kde-mac/kde"
KDE_TAP_URL="https://invent.kde.org/packaging/homebrew-kde.git"

# Ensure the KDE tap is available so kf6-kirigami can be found/installed.
if ! brew tap | grep -q "^${KDE_TAP}$"; then
    info "Adding KDE Homebrew tap (${KDE_TAP})..."
    brew tap "${KDE_TAP}" "${KDE_TAP_URL}"
fi

KF6_DIR=""
if brew list kf6-kirigami >/dev/null 2>&1; then
    KF6_DIR="${BREW_PREFIX}"
    KF6_VER="$(brew info kf6-kirigami --json=v1 \
               | python3 -c 'import sys,json; print(json.load(sys.stdin)[0]["versions"]["stable"])' \
               2>/dev/null || echo "installed")"
    success "KF6 Kirigami ${KF6_VER} (Homebrew prefix: ${KF6_DIR})"
else
    # Allow the caller to provide a custom prefix via env var.
    if [[ -n "${KF6_DIR:-}" ]]; then
        success "Using KF6_DIR from environment: ${KF6_DIR}"
    else
        info "Installing kf6-kirigami via Homebrew (pulls in KF6 deps)..."
        brew install kf6-kirigami
        KF6_DIR="${BREW_PREFIX}"
        success "KF6 Kirigami installed (prefix: ${KF6_DIR})"
    fi
fi

# Sanity-check: CMake config must be reachable.
KIRIGAMI_CMAKE="${KF6_DIR}/lib/cmake/KF6Kirigami"
if [[ ! -d "${KIRIGAMI_CMAKE}" ]]; then
    warn "CMake config not found at expected path:"
    warn "  ${KIRIGAMI_CMAKE}"
    warn "Set KF6_DIR to the prefix that contains lib/cmake/KF6Kirigami/ and re-run."
fi

# ─────────────────────────────────────────────────────────────────────────────
# 5. QMapLibre  (maplibre-native-qt)
# ─────────────────────────────────────────────────────────────────────────────
if [[ "$SKIP_MAPLIBRE" == "true" ]]; then
    warn "Skipping QMapLibre build (--skip-maplibre)."
else
    # Check if already installed and up-to-date.
    QMAPLIBRE_CMAKE="${QT_BREW_PREFIX}/lib/cmake/QMapLibre"
    if [[ -d "${QMAPLIBRE_CMAKE}" && "$UPDATE_MAPLIBRE" == "false" ]]; then
        INSTALLED_VER="$(grep -m1 'PACKAGE_VERSION' \
            "${QMAPLIBRE_CMAKE}/QMapLibreConfigVersion.cmake" 2>/dev/null \
            | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")"
        success "QMapLibre ${INSTALLED_VER} already installed – skipping build."
        success "  (Re-run with --update-maplibre to force a rebuild.)"
    else
        info "Setting up QMapLibre (maplibre-native-qt)..."
        echo
        echo -e "  ${YELLOW}Note:${NC} The first clone downloads maplibre-native (~1 GB of submodules)."
        echo -e "  ${YELLOW}Note:${NC} The first build takes 10–20 minutes depending on your machine."
        echo

        mkdir -p "${EXTERN_DIR}"

        if [[ ! -d "${QMAPLIBRE_SRC}/.git" ]]; then
            info "Cloning maplibre-native-qt with submodules..."
            git clone --recurse-submodules \
                https://github.com/maplibre/maplibre-native-qt.git \
                "${QMAPLIBRE_SRC}"
        else
            info "Updating maplibre-native-qt..."
            git -C "${QMAPLIBRE_SRC}" fetch --quiet
            git -C "${QMAPLIBRE_SRC}" pull --ff-only --quiet \
                || warn "Could not fast-forward – working tree may be dirty. Continuing."
            git -C "${QMAPLIBRE_SRC}" submodule update --init --recursive --quiet
        fi

        QMAPLIBRE_TAG="$(git -C "${QMAPLIBRE_SRC}" describe --tags --abbrev=0 2>/dev/null || echo "HEAD")"
        success "maplibre-native-qt ${QMAPLIBRE_TAG} at ${QMAPLIBRE_SRC}"

        QMAPLIBRE_BUILD="${QMAPLIBRE_SRC}/build-macos"

        info "Configuring QMapLibre..."
        cmake -S "${QMAPLIBRE_SRC}" \
              -B "${QMAPLIBRE_BUILD}" \
              -G Ninja \
              -DCMAKE_BUILD_TYPE=Release \
              -DCMAKE_PREFIX_PATH="${QT_BREW_PREFIX}" \
              -DCMAKE_INSTALL_PREFIX="${QT_BREW_PREFIX}" \
              -DQMAPLIBRE_WITH_LOCATION=ON \
              -DCMAKE_OSX_ARCHITECTURES="$(uname -m)"

        info "Building QMapLibre..."
        cmake --build "${QMAPLIBRE_BUILD}" \
              --parallel "$(sysctl -n hw.logicalcpu)"

        info "Installing QMapLibre into Qt prefix (may need sudo)..."
        # Try without sudo first; fall back if the prefix is not user-writable.
        if [[ -w "${QT_BREW_PREFIX}/lib" ]]; then
            cmake --install "${QMAPLIBRE_BUILD}"
        else
            sudo cmake --install "${QMAPLIBRE_BUILD}"
        fi

        success "QMapLibre installed into ${QT_BREW_PREFIX}"
    fi
fi

# ─────────────────────────────────────────────────────────────────────────────
# 6. CMakeUserPresets.json  (create from example if absent)
# ─────────────────────────────────────────────────────────────────────────────
USER_PRESETS="${PROJECT_ROOT}/CMakeUserPresets.json"
EXAMPLE_PRESETS="${PROJECT_ROOT}/CMakeUserPresets.json.example"

if [[ ! -f "${USER_PRESETS}" && -f "${EXAMPLE_PRESETS}" ]]; then
    info "Creating CMakeUserPresets.json from example..."
    sed \
        -e "s|/opt/homebrew/opt/qt|${QT_BREW_PREFIX}|g" \
        -e "s|/Users/yourname/KF6|${KF6_DIR}|g" \
        -e "s|/Users/yourname|${HOME}|g" \
        "${EXAMPLE_PRESETS}" \
        > "${USER_PRESETS}"
    success "Created CMakeUserPresets.json – review and adjust the Android paths."
elif [[ -f "${USER_PRESETS}" ]]; then
    success "CMakeUserPresets.json already exists (not overwritten)."
else
    warn "CMakeUserPresets.json.example not found; skipping preset generation."
fi

# ─────────────────────────────────────────────────────────────────────────────
# 7. Summary
# ─────────────────────────────────────────────────────────────────────────────
echo
echo -e "${BOLD}Setup complete!${NC}"
echo
echo "Add the following exports to your shell profile (~/.zshrc or ~/.zprofile)"
echo "so that Qt Creator and cmake --preset pick up the correct paths:"
echo
echo -e "  ${GREEN}export BV_QT_DIR=\"${QT_BREW_PREFIX}\"${NC}"
echo -e "  ${GREEN}export BV_KF6_DIR=\"${KF6_DIR}\"${NC}"
echo
echo "Then build and run the app:"
echo "  cmake --preset  kirigami-macos"
echo "  cmake --build   --preset kirigami-macos"
echo "  open build-kirigami/harbour-Berlin-Vegan.app"
echo
echo "Or open the project in Qt Creator – it will detect CMakePresets.json"
echo "and offer the 'Kirigami (macOS)' kit automatically."
echo
