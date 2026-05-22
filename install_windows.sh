#!/usr/bin/env bash

set -euo pipefail

TARGET_OS=windows bash "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/install.sh"
