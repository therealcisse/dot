# Set TERM to xterm-ghostty if available, otherwise fall back to xterm-256color
if infocmp xterm-ghostty &>/dev/null; then
  export TERM=xterm-ghostty
else
  export TERM=xterm-256color
fi

# # Create a hash table for globally stashing variables without polluting main
# scope with a bunch of identifiers.
typeset -A __TRC

__TRC[ITALIC_ON]=$'\e[3m'
__TRC[ITALIC_OFF]=$'\e[23m'

#
# Completion
#

fpath=($HOME/.zsh/completions $fpath)

setopt prompt_subst
autoload -U compinit
compinit -u

# Make completion:
# - Try exact (case-sensitive) match first.
# - Then fall back to case-insensitive.
# - Accept abbreviations after . or _ or - (ie. f.b -> foo.bar).
# - Substring complete (ie. bar -> foobar).
zstyle ':completion:*' matcher-list '' '+m:{[:lower:]}={[:upper:]}' '+m:{[:upper:]}={[:lower:]}' '+m:{_-}={-_}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# Colorize completions using default `ls` colors.
zstyle ':completion:*' list-colors ''

# Allow completion of ..<Tab> to ../ and beyond.
zstyle -e ':completion:*' special-dirs '[[ $PREFIX = (../)#(..) ]] && reply=(..)'

# $CDPATH is overpowered (can allow us to jump to 100s of directories) so tends
# to dominate completion; exclude path-directories from the tag-order so that
# they will only be used as a fallback if no completions are found.
zstyle ':completion:*:complete:(cd|pushd):*' tag-order 'local-directories named-directories'

# Categorize completion suggestions with headings:
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format %F{default}%B%{$__TRC[ITALIC_ON]%}--- %d ---%{$__TRC[ITALIC_OFF]%}%b%f

# Enable keyboard navigation of completions in menu
# (not just tab/shift-tab but cursor keys as well):
zstyle ':completion:*' menu select

export DISABLE_AUTO_TITLE='true'

#
# Bindings
#

autoload -U select-word-style
select-word-style bash # only alphanumeric chars are considered WORDCHARS

autoload -U edit-command-line
zle -N edit-command-line
bindkey '^x^e' edit-command-line

bindkey ' ' magic-space # do history expansion on space

bindkey "\e[1;5D" backward-word # Ctrl + <letf>
bindkey "\e[1;5C" forward-word  # Ctrl + <right>

bindkey \^u backward-kill-line

# VI Mode!!!
bindkey jj vi-cmd-mode

# Switch back and forward between program faster

fancy-ctrl-z () {
  if [[ $#BUFFER -eq 0 ]]; then
    BUFFER="fg"
    zle accept-line
  else
    zle push-input
    zle clear-screen
  fi
}
zle -N fancy-ctrl-z
bindkey '^Z' fancy-ctrl-z

if [ "$(uname)" = "Darwin" ]; then
  # Suppress unwanted Homebrew-installed stuff.
  if [ -e /usr/local/share/zsh/site-functions/_git ]; then
    mv -f /usr/local/share/zsh/site-functions/{,disabled.}_git
  fi
fi

#
# Correction
#

# exceptions to auto-correction
alias bundle='nocorrect bundle'
alias cabal='nocorrect cabal'
alias man='nocorrect man'
alias mkdir='nocorrect mkdir'
alias mv='nocorrect mv'
alias stack='nocorrect stack'
alias sudo='nocorrect sudo'

#
# Prompt
#

autoload -U colors
colors

# History

export HISTSIZE=100000
export HISTFILE="$HOME/.history"
export SAVEHIST=$HISTSIZE

#
# Options
#

setopt AUTO_CD                 # [default] .. is shortcut for cd .. (etc)
setopt AUTO_PARAM_SLASH        # tab completing directory appends a slash
setopt AUTO_PUSHD              # [default] cd automatically pushes old dir onto dir stack
setopt AUTO_RESUME             # allow simple commands to resume backgrounded jobs
setopt CLOBBER                 # allow clobbering with >, no need to use >!
setopt CORRECT                 # [default] command auto-correction
setopt CORRECT_ALL             # [default] argument auto-correction
setopt NO_FLOW_CONTROL         # disable start (C-s) and stop (C-q) characters
setopt NO_HIST_IGNORE_ALL_DUPS # don't filter non-contiguous duplicates from history
setopt HIST_FIND_NO_DUPS       # don't show dupes when searching
setopt HIST_IGNORE_DUPS        # do filter contiguous duplicates from history
setopt HIST_IGNORE_SPACE       # [default] don't record commands starting with a space
setopt HIST_VERIFY             # confirm history expansion (!$, !!, !foo)
setopt IGNORE_EOF              # [default] prevent accidental C-d from exiting shell
setopt INTERACTIVE_COMMENTS    # [default] allow comments, even in interactive shells
setopt LIST_PACKED             # make completion lists more densely packed
setopt MENU_COMPLETE           # auto-insert first possible ambiguous completion
setopt NO_NOMATCH              # [default] unmatched patterns are left unchanged
setopt PRINT_EXIT_VALUE        # [default] for non-zero exit status
setopt PUSHD_IGNORE_DUPS       # don't push multiple copies of same dir onto stack
setopt PUSHD_SILENT            # [default] don't print dir stack after pushing/popping
setopt SHARE_HISTORY           # share history across shells


#
# Plug-ins
#

# NOTE: must come before zsh-history-substring-search & zsh-syntax-highlighting.
autoload -U select-word-style
select-word-style bash # only alphanumeric chars are considered WORDCHARS

#
# Bindings
#

bindkey -e # emacs bindings, set to -v for vi bindings

autoload -U edit-command-line
zle -N edit-command-line
bindkey '^x^x' edit-command-line

bindkey ' ' magic-space # do history expansion on space

# Replace standard history-incremental-search-{backward,forward} bindings.
# These are the same but permit patterns (eg. a*b) to be used.
bindkey "^r" history-incremental-pattern-search-backward
bindkey "^s" history-incremental-pattern-search-forward

# Make CTRL-Z background things and unbackground them.
function fg-bg() {
  if [[ $#BUFFER -eq 0 ]]; then
    fg
  else
    zle push-input
  fi
}
zle -N fg-bg
bindkey '^Z' fg-bg

# Mac-like wordwise movement (Opt/Super plus left/right) in Kitty.
bindkey "^[[1;3C" forward-word # For macOS.
bindkey "^[[1;3D" backward-word # For macOS.
bindkey "^[[1;5C" forward-word # For Arch.
bindkey "^[[1;5D" backward-word # For Arch.

#
# Other prerequisites before we set up `$PATH`.
#

#
# Other
#

source $HOME/.zsh/path # Must come first! (Others depend on it.)

source $HOME/.zsh/aliases
source $HOME/.zsh/common
source $HOME/.zsh/exports
source $HOME/.zsh/functions
source $HOME/.zsh/vars

test -e $HOME/.zsh/common.private && source $HOME/.zsh/common.private
test -e $HOME/.zsh/functions.private && source $HOME/.zsh/functions.private

if command -v kubectl >/dev/null 2>&1; then
  source <(kubectl completion zsh)
fi
# complete -C '/usr/local/bin/aws_completer' aws

source $(brew --prefix)/share/zsh-autopair/autopair.zsh

source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
bindkey '^i' autosuggest-accept
bindkey '^u' autosuggest-toggle
bindkey '^k' up-line-or-search
bindkey '^j' down-line-or-search

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=59'
ZSH_AUTOSUGGEST_STRATEGY=(match_prev_cmd completion)

source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Disable underline
(( ${+ZSH_HIGHLIGHT_STYLES} )) || typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[path]=none
ZSH_HIGHLIGHT_STYLES[path_prefix]=none

autoload -U select-word-style
select-word-style bash # only alphanumeric chars are considered WORDCHARS

HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1

source $(brew --prefix)/share/zsh-history-substring-search/zsh-history-substring-search.zsh

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^P' history-substring-search-up
bindkey '^N' history-substring-search-down
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

# tmux unsets this and then xclip gets confused
if [ -n "$DISPLAY" ]; then
  export DISPLAY=:0
fi

# Local and host-specific overrides.

LOCAL_RC=$HOME/.zshrc.local
test -f $LOCAL_RC && source $LOCAL_RC

HOST_RC=$HOME/.zsh/host/$(hostname -s)
test -f $HOST_RC && source $HOST_RC

export DISABLE_UPDATE_PROMPT=false

setopt inc_append_history
setopt share_history

export LOCAL_METRICS_ENABLED=true

if [ -e /etc/motd ]; then
  if ! cmp -s $HOME/.hushlogin /etc/motd; then
    tee $HOME/.hushlogin < /etc/motd
  fi
fi

export XDG_CONFIG_HOME=$HOME/.config

alias java21="export JAVA_HOME=`/usr/libexec/java_home -v 21`"
alias java11="export JAVA_HOME=`/usr/libexec/java_home -v 11`"
alias java17="export JAVA_HOME=`/usr/libexec/java_home -v 17`"
alias java8="export JAVA_HOME=`/usr/libexec/java_home -v 1.8`"

# export NODE_OPTIONS=--openssl-legacy-provider

 # Nix
 if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
	 . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
 fi
 # End Nix

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

eval "$(zoxide init zsh)"
eval "$(direnv hook zsh)"

if [ -d "$HOME/.zshenv.d" ]; then
  for EXTENSION_FILE in $(find $HOME/.zshenv.d/ -name '*.zsh'); do
    source "$EXTENSION_FILE"
  done
fi

eval "$(starship init zsh)"


# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/therealcisse/.lmstudio/bin"
