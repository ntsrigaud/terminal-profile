# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

if [[ "$OSTYPE" == msys* || "$OSTYPE" == cygwin* ]]; then
  if command -v cygpath >/dev/null 2>&1; then
    if [[ -z "${USERPROFILE:-}" && -n "${HOME:-}" ]]; then
      export USERPROFILE="$(cygpath -w "$HOME")"
    fi

    if [[ -z "${LOCALAPPDATA:-}" && -n "${USERPROFILE:-}" ]]; then
      export LOCALAPPDATA="${USERPROFILE}\\AppData\\Local"
    fi

    if [[ -z "${TEMP:-}" && -n "${LOCALAPPDATA:-}" ]]; then
      export TEMP="${LOCALAPPDATA}\\Temp"
    fi

    if [[ -z "${TMP:-}" && -n "${TEMP:-}" ]]; then
      export TMP="$TEMP"
    fi

    if [[ -z "${TMPDIR:-}" && -n "${TEMP:-}" ]]; then
      export TMPDIR="$(cygpath -u "$TEMP")"
    fi
  fi
fi

# Path to your oh-my-zsh installation.
  export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="pixegami-agnoster"

# Set list of themes to load
# Setting this variable when ZSH_THEME=random
# cause zsh load theme from this variable instead of
# looking in ~/.oh-my-zsh/themes/
# An empty array have no effect
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git
  zsh-syntax-highlighting
  zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh

for pixegami_conda_root in \
  /c/tools/miniconda3 \
  /c/tools/miniforge3 \
  /c/tools/anaconda3 \
  "$HOME/miniconda3" \
  "$HOME/miniforge3" \
  "$HOME/anaconda3"
do
  if [[ -x "$pixegami_conda_root/Scripts/conda.exe" ]]; then
    export CONDA_EXE="$pixegami_conda_root/Scripts/conda.exe"
    if [[ -f "$pixegami_conda_root/etc/profile.d/conda.sh" ]]; then
      . "$pixegami_conda_root/etc/profile.d/conda.sh"
      if typeset -f __conda_exe >/dev/null 2>&1; then
        __pixegami_conda_eval() {
          local ask_conda
          ask_conda="$(__conda_exe shell.posix "$@")" || return
          ask_conda="${ask_conda//$'\r'/}"
          eval "$ask_conda"
          __conda_hashr
        }

        __conda_activate() {
          if [ -n "${CONDA_PS1_BACKUP:+x}" ]; then
            PS1="$CONDA_PS1_BACKUP"
            unset CONDA_PS1_BACKUP
          fi
          __pixegami_conda_eval "$@"
        }

        __conda_reactivate() {
          __pixegami_conda_eval reactivate
        }
      fi
    elif ! command -v conda >/dev/null 2>&1; then
      export PATH="$pixegami_conda_root/Scripts:$pixegami_conda_root/condabin:$PATH"
    fi
    break
  fi
done
unset pixegami_conda_root

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias nvim='/c/nvim-win64/bin/nvim.exe'
export PATH=$PATH:/c/node
