#!/usr/bin/env bash

set -euo pipefail

TARGET_OS=ubuntu bash "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/install.sh"
