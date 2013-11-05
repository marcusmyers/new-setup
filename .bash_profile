# Paths
export PATH="/usr/local/mysql/bin:$PATH"
export PATH=/usr/local/php5/bin:$PATH

# use homebrew to install bash_completion
if [ -f $(brew --prefix)/etc/bash_completion ]; then
  . $(brew --prefix)/etc/bash_completion
fi


#### Aliases ####

# Common
alias c='clear'

# Git
alias g='git status'
alias gca='git commit -am'
alias gco='git checkout'
alias gp='git pull'
alias gpu='git push'

# PHP Artisan
alias pa='php artisan'
alias pagm='php artisan generate:model'
alias pagr='php artisan generate:resource'
alias pagc='php artisan generate:controller'
alias pagmi='php artisan generate:migration'
alias pags='php artisan generate:seed'

#### End Aliases ####



## CDPATH is one of bashs best "secret" features. eg. "cd projects" will drop
## me into "~/Dropbox/projects" from anywhere in the filesystem (unless the PWD
## has "projects" subdir).
CDPATH=.:~:~/Documents:~/Documents/Projects:~/Dropbox:/Volumes


## Add .bash_ps1 to profile
if [ -f "$HOME/.bash_ps1" ]; then
. "$HOME/.bash_ps1"
fi
