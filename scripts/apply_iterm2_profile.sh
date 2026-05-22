#!/usr/bin/env bash

set -euo pipefail

PROFILE_DIR="$HOME/Library/Application Support/iTerm2/DynamicProfiles"
PROFILE_FILE="$PROFILE_DIR/pixegami-terminal-profile.json"

mkdir -p "$PROFILE_DIR"

cat > "$PROFILE_FILE" <<'JSON'
{
  "Profiles": [
    {
      "Guid": "F3D54120-1DA8-4A2A-A7E9-71872A5796C1",
      "Name": "Pixegami",
      "Dynamic Profile Parent Name": "Default",
      "Normal Font": "RobotoMonoForPowerline 14",
      "Use Bright Bold": true,
      "Foreground Color": {
        "Red Component": 0.525,
        "Green Component": 1.0,
        "Blue Component": 0.686
      },
      "Background Color": {
        "Red Component": 0.047,
        "Green Component": 0.11,
        "Blue Component": 0.145
      },
      "Ansi 0 Color": {
        "Red Component": 0.082,
        "Green Component": 0.145,
        "Blue Component": 0.208
      },
      "Ansi 1 Color": {
        "Red Component": 1.0,
        "Green Component": 0.235,
        "Blue Component": 0.235
      },
      "Ansi 2 Color": {
        "Red Component": 0.286,
        "Green Component": 1.0,
        "Blue Component": 0.427
      },
      "Ansi 3 Color": {
        "Red Component": 1.0,
        "Green Component": 0.737,
        "Blue Component": 0.318
      },
      "Ansi 4 Color": {
        "Red Component": 0.239,
        "Green Component": 0.714,
        "Blue Component": 0.976
      },
      "Ansi 5 Color": {
        "Red Component": 0.557,
        "Green Component": 0.267,
        "Blue Component": 0.678
      },
      "Ansi 6 Color": {
        "Red Component": 0.086,
        "Green Component": 0.627,
        "Blue Component": 0.522
      },
      "Ansi 7 Color": {
        "Red Component": 0.741,
        "Green Component": 0.765,
        "Blue Component": 0.78
      },
      "Ansi 8 Color": {
        "Red Component": 0.149,
        "Green Component": 0.219,
        "Blue Component": 0.294
      },
      "Ansi 9 Color": {
        "Red Component": 1.0,
        "Green Component": 0.235,
        "Blue Component": 0.298
      },
      "Ansi 10 Color": {
        "Red Component": 0.576,
        "Green Component": 1.0,
        "Blue Component": 0.569
      },
      "Ansi 11 Color": {
        "Red Component": 1.0,
        "Green Component": 0.816,
        "Blue Component": 0.341
      },
      "Ansi 12 Color": {
        "Red Component": 0.357,
        "Green Component": 0.843,
        "Blue Component": 1.0
      },
      "Ansi 13 Color": {
        "Red Component": 0.608,
        "Green Component": 0.349,
        "Blue Component": 0.714
      },
      "Ansi 14 Color": {
        "Red Component": 0.125,
        "Green Component": 0.361,
        "Blue Component": 0.341
      },
      "Ansi 15 Color": {
        "Red Component": 1.0,
        "Green Component": 1.0,
        "Blue Component": 1.0
      }
    }
  ]
}
JSON

echo "iTerm2 dynamic profile written to: $PROFILE_FILE"
echo "Open iTerm2 and select profile: Pixegami"
