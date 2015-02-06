# Paths
export PATH="/usr/local/mysql/bin:$PATH"
export PATH=/usr/local/php5/bin:$PATH

# some settings to be more colorful
export GREP_OPTIONS='--color=auto' GREP_COLOR='1;32'
export CLICOLOR=true
export LSCOLORS=ExGxFxdxCxDxDxBxBxExEx

# use homebrew to install bash_completion
if [ -f $(brew --prefix)/etc/bash_completion ]; then
  . $(brew --prefix)/etc/bash_completion
fi

eval "$(rbenv init -)"

## Add .aliases to profile
if [ -f "$HOME/.aliases" ]; then
  . "$HOME/.aliases"
fi


## CDPATH is one of bashs best "secret" features. eg. "cd projects" will drop
## me into "~/Dropbox/projects" from anywhere in the filesystem (unless the PWD
## has "projects" subdir).
CDPATH=.:~:~/Documents:~/Documents/Projects:~/Dropbox:/Volumes


## Add .bash_ps1 to profile
if [ -f "$HOME/.bash_ps1" ]; then
. "$HOME/.bash_ps1"
fi


################################################
# bash functions
################################################
function myip {
  res=$(curl -s checkip.dyndns.org | grep -Eo '[0-9\.]+')
  echo "$res"
}

function git_stats {
# awesome work from https://github.com/esc/git-stats
# including some modifications
if [ -n "$(git symbolic-ref HEAD 2> /dev/null)" ]; then
    echo "Number of commits per author:"
    git --no-pager shortlog -sn --all
    AUTHORS=$( git shortlog -sn --all | cut -f2 | cut -f1 -d' ')
    LOGOPTS=""
    if [ "$1" == '-w' ]; then
        LOGOPTS="$LOGOPTS -w"
        shift
    fi
    if [ "$1" == '-M' ]; then
        LOGOPTS="$LOGOPTS -M"
        shift
    fi
    if [ "$1" == '-C' ]; then
        LOGOPTS="$LOGOPTS -C --find-copies-harder"
        shift
    fi
    for a in $AUTHORS
    do
        echo '-------------------'
        echo "Statistics for: $a"
        echo -n "Number of files changed: "
        git log $LOGOPTS --all --numstat --format="%n" --author=$a | cut -f3 | sort -iu | wc -l
        echo -n "Number of lines added: "
        git log $LOGOPTS --all --numstat --format="%n" --author=$a | cut -f1 | awk '{s+=$1} END {print s}'
        echo -n "Number of lines deleted: "
        git log $LOGOPTS --all --numstat --format="%n" --author=$a | cut -f2 | awk '{s+=$1} END {print s}'
        echo -n "Number of merges: "
        git log $LOGOPTS --all --merges --author=$a | grep -c '^commit'
    done
else
    echo "you're currently not in a git repository"
fi
}
