function fpaste {
  gpaste-client history --zero |
  grep -v -z "\[Image, .*\]" |
  fzf --border --height 14 --no-hscroll --read0 -d ' ' -n 2.. \
      --preview-window right:50%:wrap --preview 'echo {2..}' \
      --bind 'ctrl-x:execute-silent(gpaste-client delete {1})' |
  cut -d ' ' -f 2-
}

function fco {
  local tags local_branches remote_branches target
  git rev-parse HEAD &> /dev/null || return
  tags=$(git tag --sort=-v:refname | sed 's/^/ /') || return
  remote_branches=$(git branch -r | sed -nE '/HEAD/!s|.* ([^/]+)/(.+)| \\e[3m\1\\e[0m \2|p') || return
  local_branches=$(git branch | sed -E 's/.* (.+)/ \1/') || return
  [[ -n "${remote_branches}" ]] && remote_branches="\n${remote_branches}"
  [[ -n "${tags}" ]] && tags="\n${tags}"
  target=$((echo -e "${local_branches}${remote_branches}${tags}") |
            fzf --border --height 35% --no-hscroll --tabstop=1 -d ' ' -n 2.. --ansi \
                --preview-window right:70% \
                --preview 'git log --oneline --graph --color=always --date=short \
                               --pretty="format:%C(auto)%cd %h%d %s" \
                           $(tr " " "/" <<< {2..}) -- | head -'$LINES \
                +m -q "$*" | sed -E "s/(.+ )?(.+)/\2/") || return
  git checkout "${target}"
}

function fak {
    local target
    target=$(__awskeys_list | grep "^ " | tr -d ' ' |
             fzf --min-height 10 --height 15 -q "$*") || return
    __awskeys_export "${target}"
}

function __awless_show {
  local lock_file
  lock_file="/tmp/awless-show.lock"
  [[ -f "${lock_file}" ]] && return
  awless show -p $1 --silent --local --siblings --color=always $2 2> /dev/null
  if [[ "$?" -ne 0 ]]; then
    touch "${lock_file}" &> /dev/null
    awless sync -p $1 --silent --infra 2> /dev/null
    rm -f "${lock_file}" &> /dev/null
    awless sync -p $1 --silent --local --siblings --color=always $2 2> /dev/null
  fi
}
typeset -fx __awless_show

function ec2sh {
  local profile

  if [[ -n "$1" ]]; then
    profile="$1"
  elif [[ -n "${AWS_DEFAULT_PROFILE}" ]]; then
    profile="${AWS_DEFAULT_PROFILE}"
  else
    echo 'No AWS credentials found in the environment!'
    return
  fi

  shift

  local target
  local host
  local instance
  local msg
  local address_idx=2

  _IFS="${IFS}"
  IFS=$'\n'
  target=( $(awless ls instances -p "${profile}" --silent --format tsv --no-headers \
                    --sort name,uptime --filter state=running |
            fzf --sync --no-hscroll --tabstop=1 -d $'\t' --multi \
                --with-nth=1,3,6,7 --nth 1,2 \
                --expect=enter --expect=alt-enter \
                --bind 'ctrl-t:toggle-all' \
                --preview-window right:60%:wrap \
                --preview "__awless_show ${profile} {1}" \
                --prompt " ${profile} ❯ " --ansi -q "$*" | cut -f 6,7) ) || return
  IFS="${_IFS}"

  [[ ${target[0]} = 'alt-enter' ]] && address_idx=1
  for instance in "${target[@]:2}"; do
    tilix -a session-add-down -e "ssh $(cut -f ${address_idx} <<< ${instance})"
  done
  ssh $(cut -f ${address_idx} <<< ${target[1]})
}

function __ec2sh_comp {
    local cur prev
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"

    [[ "${COMP_CWORD}" -eq 2 ]] && return 0

    local profile_list="$(__awskeys_list | grep "    ")"
    COMPREPLY=( $(compgen -W "${profile_list}" -- ${cur}) )

    return 0
}
complete -F __ec2sh_comp ec2sh
