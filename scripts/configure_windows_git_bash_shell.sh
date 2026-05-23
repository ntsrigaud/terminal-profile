#!/usr/bin/env bash

set -euo pipefail

BEGIN_MARKER="# PIXEGAMI_GIT_BASH_TO_ZSH_BEGIN"
END_MARKER="# PIXEGAMI_GIT_BASH_TO_ZSH_END"

ensure_zsh_in_path() {
  local candidate
  for candidate in \
    /usr/bin \
    /c/Program\ Files/Git/usr/bin \
    /c/tools/msys64/usr/bin \
    /c/msys64/usr/bin
  do
    if [ -x "$candidate/zsh.exe" ] || [ -x "$candidate/zsh" ]; then
      case ":$PATH:" in
        *":$candidate:"*) ;;
        *) PATH="$candidate:$PATH" ;;
      esac
    fi
  done
  export PATH
}

detect_zsh_binary() {
  local candidate
  for candidate in \
    /usr/bin/zsh \
    /usr/bin/zsh.exe \
    /c/Program\ Files/Git/usr/bin/zsh \
    /c/Program\ Files/Git/usr/bin/zsh.exe \
    /c/tools/msys64/usr/bin/zsh \
    /c/tools/msys64/usr/bin/zsh.exe \
    /c/msys64/usr/bin/zsh \
    /c/msys64/usr/bin/zsh.exe
  do
    if [ -x "$candidate" ]; then
      echo "$candidate"
      return 0
    fi
  done

  return 1
}

write_zsh_shim() {
  local zsh_binary="$1"
  local zsh_dir
  zsh_dir="$(dirname "$zsh_binary")"
  mkdir -p "$HOME/bin"

  cat > "$HOME/bin/zsh" <<EOF
#!/usr/bin/env bash
case ":\$PATH:" in
  *":$zsh_dir:"*) ;;
  *) export PATH="$zsh_dir:\$PATH" ;;
esac
exec "$zsh_binary" "\$@"
EOF
  chmod +x "$HOME/bin/zsh"
}

remove_old_marker_block() {
  local bashrc_path="$1"
  if ! grep -q "PIXEGAMI_GIT_BASH_TO_ZSH" "$bashrc_path"; then
    return
  fi

  local tmp_file
  tmp_file="$(mktemp)"
  awk '
    BEGIN {skip=0}
    /# PIXEGAMI_GIT_BASH_TO_ZSH$/ {skip=1; next}
    skip==1 {
      if ($0 ~ /^fi$/) {skip=0; next}
      next
    }
    {print}
  ' "$bashrc_path" > "$tmp_file"
  mv "$tmp_file" "$bashrc_path"
}

remove_managed_block() {
  local bashrc_path="$1"
  local tmp_file
  tmp_file="$(mktemp)"

  awk -v begin="$BEGIN_MARKER" -v end="$END_MARKER" '
    $0 == begin {skip=1; next}
    $0 == end {skip=0; next}
    skip != 1 {print}
  ' "$bashrc_path" > "$tmp_file"
  mv "$tmp_file" "$bashrc_path"
}

ensure_zsh_in_path

if ! zsh_binary="$(detect_zsh_binary)"; then
  echo "zsh not found. Skipping Git Bash default shell bridge."
  exit 0
fi

zsh_dir="$(dirname "$zsh_binary")"
write_zsh_shim "$zsh_binary"

bashrc_path="$HOME/.bashrc"
if [ ! -f "$bashrc_path" ]; then
  touch "$bashrc_path"
fi

remove_old_marker_block "$bashrc_path"
remove_managed_block "$bashrc_path"

cat >> "$bashrc_path" <<EOF

$BEGIN_MARKER
# Make zsh the interactive shell when launching Git Bash on Windows.
PIXEGAMI_ZSH_BIN_DIR="$zsh_dir"
PIXEGAMI_WINDOWS_HOME="${HOME}"
if [ -n "\${USERPROFILE:-}" ] && command -v cygpath >/dev/null 2>&1; then
  PIXEGAMI_WINDOWS_HOME="\$(cygpath -u "\$USERPROFILE")"
fi

if [ -d "\$PIXEGAMI_WINDOWS_HOME" ]; then
  export HOME="\$PIXEGAMI_WINDOWS_HOME"
  export ZDOTDIR="\$PIXEGAMI_WINDOWS_HOME"
fi

if [ -d "\$PIXEGAMI_ZSH_BIN_DIR" ]; then
  case ":\$PATH:" in
    *":\$PIXEGAMI_ZSH_BIN_DIR:"*) ;;
    *) export PATH="\$PIXEGAMI_ZSH_BIN_DIR:\$PATH" ;;
  esac
fi

if [ -z "\${ZSH_VERSION:-}" ] \
  && [ -z "\${PIXEGAMI_SKIP_AUTO_ZSH:-}" ] \
  && [ -z "\${BASH_EXECUTION_STRING:-}" ] \
  && [ -z "\${PIXEGAMI_AUTO_ZSH_ACTIVE:-}" ] \
  && [ -t 0 ] && [ -t 1 ]; then
  case "\$-" in
    *i*)
      export PIXEGAMI_AUTO_ZSH_ACTIVE=1
      if command -v zsh >/dev/null 2>&1; then
        export SHELL="\$(command -v zsh)"
        exec zsh
      elif command -v zsh.exe >/dev/null 2>&1; then
        export SHELL="\$(command -v zsh.exe)"
        exec zsh.exe
      fi
      ;;
  esac
fi

$END_MARKER
EOF

echo "Configured Git Bash zsh bridge using $zsh_binary (auto-start enabled)."