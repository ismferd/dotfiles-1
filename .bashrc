## if not running interactively, don't do anything ##
[[ -z "$PS1" ]] && return

## Bash programmable completion ##
if ! shopt -oq posix; then
  if [[ -f /usr/share/bash-completion/bash_completion ]]; then
    source /usr/share/bash-completion/bash_completion
  elif [[ -f /etc/bash_completion ]]; then
    source /etc/bash_completion
  fi
fi

## VTE script ##
if [[ "${TILIX_ID}" ]]; then
  source /etc/profile.d/vte-2.91.sh
fi

## Bash-it ##
export BASH_IT="${HOME}/.bash_it"

if [[ -d "${BASH_IT}" ]]; then
  export BASH_IT_THEME='powerline-multiline'
  export BATTERY_AC_CHAR=''
  export SCM_GIT_SHOW_REMOTE_INFO='true'
  export POWERLINE_SCM_GIT_CHAR=' '
  export POWERLINE_LEFT_SEPARATOR=''
  export POWERLINE_RIGHT_SEPARATOR=''
  export POWERLINE_PROMPT_USER_INFO_MODE='sudo'
  export POWERLINE_LEFT_PROMPT='cwd scm python_venv'
  export POWERLINE_RIGHT_PROMPT='clock battery user_info'

  source "${BASH_IT}/bash_it.sh"
fi

## Bash options ##
shopt -s autocd
shopt -s cdspell
shopt -s checkjobs
shopt -s checkwinsize
shopt -s cmdhist
shopt -s direxpand
shopt -s dirspell
shopt -s globstar
shopt -s histappend
shopt -s hostcomplete
shopt -s lithist

## Bash history ##
HISTCONTROL='ignoreboth:erasedups'
HISTSIZE=1000
HISTFILESIZE=3000
HISTTIMEFORMAT='%F %T  '

## edit & view ##
export EDITOR=nvim
export PAGER="less"
export LESS="-F -X -R"

## disable flow control key binding ##
stty -ixon

## tabs expanded to 4 spaces ##
tabs -4

## colors for less, man, etc. ##
[[ -f "${HOME}/.LESS_TERMCAP" ]] && source "${HOME}/.LESS_TERMCAP"

## make less more friendly for non-text input files ##
[[ -x /usr/bin/lesspipe ]] && eval "$(SHELL="/bin/sh" lesspipe)"

## enable ls color support ##
if [[ -x /usr/bin/dircolors ]]; then
  test -r "${HOME}/.dircolors" && eval "$(dircolors -b ${HOME}/.dircolors)" || eval "$(dircolors -b)"
fi

## host-dependent config ##
[[ -f "${HOME}/.bashrc_$(hostname -s)" ]] && source "${HOME}/.bashrc_$(hostname -s)"

## aliases ##
[[ -f "${HOME}/.bash_aliases" ]] && source "${HOME}/.bash_aliases"

## fzf ##
if [[ -f "${HOME}/.fzf.bash" ]]; then
  source "${HOME}/.fzf.bash"
  export FZF_DEFAULT_OPTS="--reverse --border --inline-info --tabstop=4 --prompt='❯ '"
  export FZF_DEFAULT_COMMAND='ag -g ""'
  export FZF_ALT_C_COMMAND="bfs -type d -nohidden"
  export FZF_CTRL_T_COMMAND="${FZF_DEFAULT_COMMAND}"
fi
