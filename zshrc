[[ -s ~/.aliases ]] && source ~/.aliases

eval `ssh-agent -s` > /dev/null
ssh-add ~/.ssh/id_rsa &> /dev/null

. $HOME/.asdf/asdf.sh
. $HOME/.asdf/completions/asdf.bash

. ~/.asdf/plugins/java/asdf-java-wrapper.zsh
