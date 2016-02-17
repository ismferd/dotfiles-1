## Some alias to avoid making mistakes ##
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'

## Better integration with GUI tools ##
alias open='xdg-open'

## ag colors ##
alias ag="ag --color-line-number '38;5;238' --color-match '38;5;11' --color-path '38;5;246'"

## AWS aliases ##
alias lsec2='jungle ec2 ls | grep running | cut -f1,3,4-6 | sort'
