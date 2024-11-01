#!/bin/zsh

# Set http proxy server.
local HTTP_PROXY_ADDR="127.0.0.1"
# Set http proxy port.
local HTTP_PROXY_PORT="8808"
# Set zsh plugin path.
local ZSH_PLUGIN_PATH=""
# Set GPG tty device
local CUSTOM_GPG_TTY=""

# Fix bug of new tab always starts shell with ~.
# https://bugs.launchpad.net/ubuntu-gnome/+bug/1193993
if [[ -f  "/etc/profile.d/vte.sh" ]]; then
    source /etc/profile.d/vte.sh
fi

# Load zsh profile.
if [[ -f "${HOME}/.zprofile" ]]; then
    source "${HOME}/.zprofile"
fi

# Emacs keymap.
bindkey -e
# By default `Alt-h` is help.
# Use `Alt-h` to backward delete word.
bindkey "\eh" backward-delete-word
# `Up` / `Down` for searching history.
bindkey "\e[A" up-line-or-search
bindkey "\e[B" down-line-or-search
# `Left` / `Right`.
bindkey "\e[C" forward-char
bindkey "\e[D" backward-char
# `Alt-Left` / `Alt-Right`.
bindkey "\e[1;3C" forward-word
bindkey "\e[1;3D" backward-word
# `Home` / `End`.
bindkey "\e[H" beginning-of-line
bindkey "\e[F" end-of-line
bindkey "\eOH" beginning-of-line
bindkey "\eOF" end-of-line
# `PageUp` / `PageDown`.
bindkey "\e[5~" up-line-or-history
bindkey "\e[6~" down-line-or-history

# Fix return key shows ^M
stty sane

# Add `proxychains -q` via hit `Esc` three times.
if [[ -f "/usr/bin/proxychains" || -f "/usr/bin/proxychains4" || -f "/opt/homebrew/bin/proxychains4" ]]; then
    function add_proxychains() {
        [[ -z ${BUFFER} ]] && zle up-history
        [[ ${BUFFER} != "proxychains "* ]] && BUFFER="proxychains -q ${BUFFER}"
        zle end-of-line
    }
    zle -N add_proxychains
    bindkey "\e\e\e" add_proxychains
fi

# Set `.zhistory` to history file.
HISTFILE="${HOME}/.zhistory"
# Max file size to 100K.
HISTSIZE=102400
# Max record numbers.
SAVEHIST=10000

# Enable autocurrect.
setopt correct
# Share history between different zsh instances.
setopt append_history
setopt share_history
# Only keep one record for continuous same record.
setopt hist_save_no_dups
setopt hist_ignore_dups
# Ignore record starting with space.
setopt hist_ignore_space
# Add timestamp for history.
setopt extended_history
# Use `cd -TAB` to enter history path.
setopt auto_pushd
# Enter directory without `cd`.
# setopt autocd
# Only keep one record for continuous same history path.
setopt pushd_ignore_dups
# Support `cd -NUM`.
setopt pushd_minus
# Use enhanced glob.
setopt extended_glob
# Don't change priority for background commands.
setopt no_bg_nice
# Pass `*` to program when no file matches it.
setopt no_nomatch
# Disable beep.
unsetopt beep
# Complete full path by alpha. `/v/c/p/p` => `/var/cache/pacman/pkg`.
setopt complete_in_word
# Complete parameter like `identifier=path`.
setopt magic_equal_subst
# Allow to use functions in prompt.
setopt prompt_subst
# Allow comments in interactive mode.
setopt interactive_comments
# Treat them as a part of word.
WORDCHARS="*?_-[]~=&;!#$%^(){}<>"
setopt auto_list
setopt auto_menu
# Disable selecting menu item while completing.
# setopt menu_complete
# Allow different column weight.
setopt listpacked
# Continue job after disown.
setopt auto_continue
# Treat `#`, `~` and `^` characters as patterns for filename generation.
setopt extended_glob
# Only display newest RPROMPT, which makes copy easier.
setopt transient_rprompt
# Display all options with status when call `setopt`.
setopt ksh_option_print

# Set color as environment variables.
export ZLSCOLORS=${LS_COLORS}
autoload -U colors && colors

# Autocomplete.
zstyle :compinstall filename "${HOME}/.zshrc"
autoload -Uz compinit && compinit

# Autocomplete settings.
# Set complete colors.
zstyle ":completion:*" rehash true
zstyle ":completion:*" verbose yes
zstyle ":completion:*" menu select
zstyle ":completion:*:*:default" force-list always
zstyle ":completion:*" select-prompt "%SSelect:  lines: %L  matches: %M  [%p]"
zstyle ":completion:*:match:*" original only
zstyle ":completion::prefix-1:*" completer _complete
zstyle ":completion:predict:*" completer _complete
zstyle ":completion:incremental:*" completer _complete _correct
zstyle ":completion:*" completer _complete _prefix _correct _prefix _match _approximate
# Path autocomplete.
zstyle ":completion:*" expand "yes"
zstyle ":completion:*" squeeze-slashes "yes"
zstyle ":completion::complete:*" "\\"
# Set complete colors.
zmodload zsh/complist
zstyle ":completion:*" list-colors ${(s.:.)LS_COLORS}
# Cap correct.
zstyle ":completion:*" matcher-list "" "m:{a-zA-Z}={A-Za-z}"
# Mistake correct.
zstyle ":completion:*" completer _complete _match _approximate
zstyle ":completion:*:match:*" original only
zstyle ":completion:*:approximate:*" max-errors 1 numeric
# Group complete items.
zstyle ":completion:*:matches" group "yes"
zstyle ":completion:*" group-name ""
zstyle ":completion:*:options" description "yes"
zstyle ":completion:*:options" auto-description "%d"
zstyle ":completion:*:descriptions" format "%F{cyan}%B-- %d --%b%f"
zstyle ":completion:*:messages" format "%F{purple}%B-- %d --%b%f"
zstyle ":completion:*:warnings" format "%F{red}%B-- No Matches Found --%b%f"
zstyle ":completion:*:corrections" format "%F{green}%B-- %d (errors: %e) --%b%f"
# kill complete.
zstyle ":completion:*:*:kill:*:processes" list-colors "=(#b) #([0-9]#)*=0=01;31"
zstyle ":completion:*:*:kill:*" menu yes select
zstyle ":completion:*:*:*:*:processes" force-list always
zstyle ":completion:*:processes" command "ps -au${USER}"
# cd ~ complete sequence.
zstyle ":completion:*:-tilde-:*" group-order "named-directories" "path-directories" "users" "expand"

# Restore tty status.
# ttyctl -f

# Prompt settings.
# Last command result.
# Zero prints nothing. Non-zero prints red number.
local result_status=%(?::":%F{red}%?%f")

# OS detection.
function os_status() {
    if [[ -n "${SSH_CONNECTION}" ]]; then
        print -n "%F{blue}(ssh)%f%F{yellow}$(command uname)%f:"
    else
        print -n "%F{yellow}$(command uname)%f:"
    fi
    return 0
}

# Battery.
# Warning: For the prompt will only refresh by pressing <ENTER>, the battery showing maybe not right.
function battery_status() {
    if [[ -f "/sys/class/power_supply/BAT0/capacity" ]]; then
        local BATTERY=$(command cat /sys/class/power_supply/BAT0/capacity 2> /dev/null)
        print -n "%F{green}${BATTERY}%%%f:"
        return ${BATTERY}
    elif [[ "$(command uname)" == "Darwin" ]]; then
        local BATTERY=$(command pmset -g batt | grep -Eo "\d+%;" | cut -d% -f1)
        print -n "%F{green}${BATTERY}%%%f:"
        return ${BATTERY}
    fi
    return 0
}

# Git status.
function git_status() {
    # Check for git repo.
    if [[ -n "$(command git rev-parse --short HEAD 2> /dev/null)" ]]; then
        # Check for dirty or not.
        if [[ -n "$(command git status --porcelain --ignore-submodules=dirty 2> /dev/null | command tail -n1)" ]]; then
            print -n ":%F{blue}$(command git symbolic-ref --short HEAD 2> /dev/null)%f%F{yellow}*%f"
            return 1
        else
            print -n ":%F{blue}$(command git symbolic-ref --short HEAD 2> /dev/null)%f"
            return 0
        fi
    fi
    return -1
}

## Background jobs.
function jobs_status() {
    local JOBS=$(jobs -l | command wc -l)
    if [[ ${JOBS} -ne 0 ]]; then
        print -n ":%F{green}${JOBS}&%f"
        return ${JOBS}
    fi
    return 0
}

## Left prompt data.
function left_prompt_data() {
    local DATA=""
    if [[ "${UID}" == "0" ]]; then
        # Set hostname to red for root.
        DATA="%F{red}%n%f@%F{red}%m%f"
    else
        # Set hostname to cyan for common user.
        DATA="%F{red}%n%f@%F{cyan}%m%f"
    fi

    if [[ -n "${SSH_TTY}" || -n "${SSH_CLIENT}" ]]; then
        # Set color to green for SSH connected mode.
        DATA="%F{green}%n%f@%F{green}%m%f"
    fi
    print -n "${DATA}"
    return 0
}


# Prompt.
# LEFT PROMPT containing username `%n`, hostname `%m`, directory `%~`, git `$(git_status)`, jobs `$(jobs_status)`, result `${result_status}` and the `%#`.
PROMPT='[$(left_prompt_data)%f:%F{yellow}%~%f$(git_status)$(jobs_status)${result_status}] %# '
# RIGHT PROMPT containing battery `$(battery_status)`, os `$(os_status)`, date `%D{%Y-%m-%d}` and time `%D{%H:%M:%S}`.
RPROMPT='[$(battery_status)$(os_status)%F{cyan}%D{%Y-%m-%d} %D{%H:%M:%S}%f]'

# Terminal title.
# Because terminal don't know what `%n@%m:%~` is, we need to use `print -P`, it will parse them then pass result to title.
case "${TERM}" in
    xterm*|rxvt*|(dt|k|E)term|termite|gnome*|alacritty)
        function precmd() {
            # vcs_info
            print -Pn "\e]0;%n@%M:%~\a"
        }
        function preexec() {
            print -Pn "\e]0;${1}\a"
        }
    ;;
    screen*)
        function precmd() {
            # vcs_info
            print -Pn "\e]83;title \"${1}\"\a"
            print -Pn "\e]0;$TERM - (%L) %n@%M:%~\a"
        }
        function preexec() {
            print -Pn "\e]83;title \"${1}\"\a"
            print -Pn "\e]0;$TERM - (%L) %n@%M:%~\a"
        }
    ;;
esac

# Alias.
# Colorize ls command.
if [[ "$(command uname)" != "Darwin" && -f "/bin/ls" ]]; then
    alias ls="ls --color=auto -h"
else
    alias ls="ls -G -h"
fi

# Colorize grep command.
if [[ -f "/usr/bin/grep" ]]; then
    alias grep="grep --color=auto"
fi

# Colorize ip command.
if [[ -f "/usr/bin/ip" ]]; then
    alias ip='ip --color=auto'
fi

# Use nvim as vim if neovim installed.
if command -v nvim &> /dev/null; then
    alias vi="nvim"
    alias vim="nvim"
elif [[ -f "/bin/vim" ]]; then
    alias vi="vim"
fi

alias ll='ls -al'
alias dfh='df -h'
alias duh='du -h'

# HTTP_PROXY variable short name.
if [[ -n "${HTTP_PROXY_ADDR}" && -n "${HTTP_PROXY_PORT}" ]]; then
    alias proxyenv="http_proxy=\"http://${HTTP_PROXY_ADDR}:${HTTP_PROXY_PORT}\" https_proxy=\"http://${HTTP_PROXY_ADDR}:${HTTP_PROXY_PORT}\" ftp_proxy=\"http://${HTTP_PROXY_ADDR}:${HTTP_PROXY_PORT}\" rsync_proxy=\"http://${HTTP_PROXY_ADDR}:${HTTP_PROXY_PORT}\" no_proxy=\"localhost,127.0.0.1,10.1.1.1,localaddress,.localdomain\""

    # Add `proxyenv` via hit `Esc` twice.
    function add_proxyenv() {
        [[ -z ${BUFFER} ]] && zle up-history
        [[ ${BUFFER} != "proxyenv "* ]] && BUFFER="proxyenv ${BUFFER}"
        zle end-of-line
    }
    zle -N add_proxyenv
    bindkey "\e\e" add_proxyenv
fi

# A beautiful git log.
if command -v git &> /dev/null; then
    git config --global alias.graph "log --graph --abbrev-commit --decorate --date=iso8601 --format=format:'%C(bold blue)%h%C(reset) %C(white)%s%C(reset) %C(dim white)<%ae>%C(reset) %C(bold green)(%ad)%C(reset) %C(auto)%d%C(reset)'"
fi

# Systemd.
if command -v systemctl &> /dev/null; then
    # Let the pager away.
    alias systemctl="systemctl --no-pager --full"
    alias journalctl="journalctl --no-pager --full"

    alias sctl="systemctl"
    alias sctle="systemctl enable"
    alias sctlen="systemctl enable --now"
    alias sctls="systemctl status"
    alias sctlr="systemctl restart"
fi

# Set proxychains.
if [[ -f "/usr/bin/proxychains4" || -f "/opt/homebrew/bin/proxychains4" ]]; then
    alias proxychains="proxychains4"
fi

# Find zsh plugin path.
if [[ -z ${ZSH_PLUGIN_PATH} ]]; then
    if [[ "$(command uname)" == "Linux" ]]; then
        if [[ -d "/usr/share/zsh/plugins" ]]; then
            # ArchLinux.
            ZSH_PLUGIN_PATH="/usr/share/zsh/plugins"
        else
            # openSUSE, ubuntu, etc...
            ZSH_PLUGIN_PATH="/usr/share"
        fi
    elif [[ "$(command uname)" == "Darwin" ]]; then
        # macOS.
        ZSH_PLUGIN_PATH="/opt/homebrew/share"
    fi
fi

# Enviroments.
# Settings for Linux.
if [[ "$(command uname)" == "Linux" ]]; then
    # Settings for golang.
    if command -v go &> /dev/null; then
        if [[ -d "/usr/local/go" ]]; then
            export PATH="$PATH:/usr/local/go/bin"
        fi
        if [[ -d "${HOME}/go" ]]; then
            export GOPATH="${HOME}/go"
            export PATH="${PATH}:${GOPATH}/bin"
        fi
    fi

    # Set neovim to default editor.
    if command -v nvim &> /dev/null; then
        export EDITOR="nvim"
    else
        export EDITOR="vim"
    fi

    # Kubernetes.
    if [[ -f "/usr/bin/kubectl" || -f "/usr/local/bin/kubectl" || -f "/var/lib/rancher/rke2/bin/kubectl" ]]; then
        if [[ -f "/var/lib/rancher/rke2/bin/kubectl" ]]; then
            export PATH="$PATH:/var/lib/rancher/rke2/bin"
        fi
        source <(kubectl completion zsh)
    fi

    # sbin.
    if [[ -d "/sbin" ]]; then
        export PATH="$PATH:/sbin"
    fi

    # Libraries
    if [[ -z "${LD_LIBRARY_PATH}" ]]; then
        export LD_LIBRARY_PATH=/lib:/usr/lib:/usr/local/lib
    else
        export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/lib:/usr/lib:/usr/local/lib
    fi
fi

# Settings for macOS.
if [[ "$(command uname)" == "Darwin" ]]; then
    # Add homebrew bin folder to path.
    if [[ -d "/opt/homebrew/bin" ]]; then
        export PATH="${PATH}:/opt/homebrew/bin"
    fi

    #  Settings for golang.
    if [[ -f "/opt/homebrew/bin/go" && -d "${HOME}/go" ]]; then
        export GOPATH="${HOME}/go"
        export PATH="${PATH}:${GOPATH}/bin"
    fi

    # Set neovim to default editor.
    if [[ -f "/opt/homebrew/bin/nvim" ]]; then
        export EDITOR="nvim"
    else
        export EDITOR="vim"
    fi

    # Kubernetes.
    if [[ -f "/opt/homebrew/bin/kubectl" || -f "/usr/local/bin/kubectl" ]]; then
        source <(kubectl completion zsh)
    fi

    # Add VSCode bin folder to PATH.
    if [[ -d "/Applications/Visual Studio Code.app/Contents/Resources/app/bin" ]]; then
        export PATH="${PATH}:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
    fi
fi

# Add `bin` folder in HOME to path.
if [[ -d "${HOME}/bin" ]]; then
    export PATH="${HOME}/bin:${PATH}"
fi

# Load GPG_TTY
if [[ -f "/usr/bin/gpg" || -f "/opt/homebrew/bin/gpg" ]]; then
    if [[ -n "${CUSTOM_GPG_TTY}" ]]; then
        export GPG_TTY=${CUSTOM_GPG_TTY}
    fi
fi

# Auto create `.zcustom` files and load it.
if [[ -f "${HOME}/.zcustom" ]]; then
    source "${HOME}/.zcustom"
else
    echo "#!/bin/zsh" > "${HOME}/.zcustom"
    echo >> "${HOME}/.zcustom"
fi

if [[ -f "${HOME}/.alias" ]]; then
    source "${HOME}/.zcustom"
fi

# kubectl command aliases
if type kubectl &> /dev/null; then
    alias k="kubectl"
    alias kn="kubectl --namespace"
    alias kncs="kubectl --namespace=cattle-system"
    alias knfd="kubectl --namespace=fleet-default"
    alias knks="kubectl --namespace=kube-system"
    alias kncds="kubectl --namespace=cattle-data-system"
    alias kncfn="kubectl --namespace=cattle-flat-network"
fi

# docker command aliases
if type docker &> /dev/null; then
    alias d="docker"
    alias dps="docker ps"
    alias dpsa="docker ps -a"
    alias dk="docker kill"
    alias drm="docker rm"
fi

# podman command aliases
if type podman &> /dev/null; then
    alias p="podman"
    alias pp="podman pod"
    alias pps="podman ps"
    alias ppsa="podman ps -a"
    alias pk="podman kill"
    alias prm="podman rm"
fi

################################################################################
# Load zsh plugins in the end.
if [[ -n "${ZSH_PLUGIN_PATH}" ]]; then
    # Syntax highlight.
    if [[ -f "${ZSH_PLUGIN_PATH}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
        source ${ZSH_PLUGIN_PATH}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    fi
    # Autosuggestions.
    if [[ -f "${ZSH_PLUGIN_PATH}/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
        source ${ZSH_PLUGIN_PATH}/zsh-autosuggestions/zsh-autosuggestions.zsh
    fi
fi
