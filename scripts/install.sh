#!/usr/bin/env bash
#
# Hochfrequenz Software Factory Installer
# Downloads and installs the latest pre-built binary
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/hochfrequenz/software-factory-releases/main/scripts/install.sh | bash
#
# Or with a specific version:
#   curl -fsSL https://raw.githubusercontent.com/hochfrequenz/software-factory-releases/main/scripts/install.sh | bash -s -- v1.0.0
#

set -euo pipefail

REPO="hochfrequenz/software-factory-releases"
BINARIES=("hsf" "hsf-mcp" "hsf-runner")
INSTALL_DIR="${INSTALL_DIR:-$HOME/.local/bin}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info() { echo -e "${BLUE}==>${NC} $1"; }
success() { echo -e "${GREEN}==>${NC} $1"; }
warn() { echo -e "${YELLOW}==>${NC} $1"; }
error() { echo -e "${RED}Error:${NC} $1" >&2; exit 1; }

sha256_verify() {  # $1 = asset filename located in $tmp_dir
    local line
    line=$(grep "  $1\$" "${tmp_dir}/checksums.txt") || error "No checksum entry for $1 — refusing unverified install."
    if command -v sha256sum >/dev/null 2>&1; then
        (cd "$tmp_dir" && echo "$line" | sha256sum -c - >/dev/null) || error "Checksum mismatch for $1"
    else  # macOS ships shasum, not sha256sum
        (cd "$tmp_dir" && echo "$line" | shasum -a 256 -c - >/dev/null) || error "Checksum mismatch for $1"
    fi
}

# Detect OS and architecture
detect_platform() {
    local os arch

    case "$(uname -s)" in
        Linux*)  os="linux" ;;
        Darwin*) os="darwin" ;;
        MINGW*|MSYS*|CYGWIN*) os="windows" ;;
        *) error "Unsupported operating system: $(uname -s)" ;;
    esac

    case "$(uname -m)" in
        x86_64|amd64) arch="amd64" ;;
        arm64|aarch64) arch="arm64" ;;
        armv7l) arch="arm" ;;
        *) error "Unsupported architecture: $(uname -m)" ;;
    esac

    echo "${os}_${arch}"
}

# Get latest version from GitHub
get_latest_version() {
    curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" |
        grep '"tag_name":' |
        sed -E 's/.*"([^"]+)".*/\1/'
}

# Download and install
install() {
    local version="${1:-}"
    local platform
    platform=$(detect_platform)

    [[ "$platform" == windows_* ]] && error "Windows installs aren't supported by this script — download the hsf release archive from https://github.com/${REPO}/releases and extract hsf.exe manually."

    info "Detected platform: $platform"

    # Get version
    if [[ -z "$version" ]]; then
        info "Fetching latest version..."
        version=$(get_latest_version)
        if [[ -z "$version" ]]; then
            error "Could not determine latest version. Please specify a version."
        fi
    fi

    info "Installing hsf, hsf-mcp, and hsf-runner ${version}..."

    # Create temp directory
    local tmp_dir
    tmp_dir=$(mktemp -d)
    trap "rm -rf $tmp_dir" EXIT

    # Create install directory
    mkdir -p "$INSTALL_DIR"

    # Download release checksums for verification
    info "Downloading checksums.txt..."
    if ! curl -fsSL "https://github.com/${REPO}/releases/download/${version}/checksums.txt" -o "${tmp_dir}/checksums.txt"; then
        error "Failed to download checksums.txt — refusing unverified install."
    fi

    # Download and install each binary
    for binary_name in "${BINARIES[@]}"; do
        # Construct download URL
        local filename="${binary_name}_${version#v}_${platform}"
        local url="https://github.com/${REPO}/releases/download/${version}/${filename}.tar.gz"

        # Download
        info "Downloading ${binary_name}..."
        if ! curl -fsSL "$url" -o "${tmp_dir}/${filename}.tar.gz"; then
            error "Failed to download ${binary_name}. Check if version ${version} exists."
        fi

        # Verify checksum before extracting
        sha256_verify "${filename}.tar.gz"

        # Extract
        tar -xzf "${tmp_dir}/${filename}.tar.gz" -C "$tmp_dir"

        # Find and install binary
        local binary="${tmp_dir}/${binary_name}"

        if [[ ! -f "$binary" ]]; then
            # Try finding binary in extracted directory
            binary=$(find "$tmp_dir" -name "${binary_name}" -type f | head -1)
        fi

        if [[ -f "$binary" ]]; then
            mv "$binary" "${INSTALL_DIR}/${binary_name}"
            chmod +x "${INSTALL_DIR}/${binary_name}"
            success "Installed ${binary_name} to ${INSTALL_DIR}/${binary_name}"
        else
            warn "Could not find ${binary_name} in archive"
        fi
    done

    # Check if in PATH
    if ! command -v "hsf" &> /dev/null; then
        warn "${INSTALL_DIR} is not in your PATH"
        echo ""
        echo "Add it to your shell profile:"
        echo ""
        echo "  # For bash (~/.bashrc)"
        echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
        echo ""
        echo "  # For zsh (~/.zshrc)"
        echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
        echo ""
    else
        success "Run 'hsf --help' to get started"
    fi

    echo ""
    info "Next steps:"
    echo "  1. Run 'hsf onboard' to set up a new project"
    echo "  2. Or run 'hsf --help' to see all commands"
}

# Main
main() {
    echo ""
    echo "  Hochfrequenz Software Factory Installer"
    echo "  ========================================"
    echo ""

    install "$@"
}

main "$@"
