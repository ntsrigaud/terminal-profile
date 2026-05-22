#!/usr/bin/env bash

set -euo pipefail

TARGET_OS=macos bash "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/install.sh"
