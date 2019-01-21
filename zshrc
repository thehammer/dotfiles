[[ -s ~/.aliases ]] && source ~/.aliases

eval `ssh-agent -s` > /dev/null
ssh-add ~/.ssh/id_rsa &> /dev/null

. $HOME/.asdf/asdf.sh
. $HOME/.asdf/completions/asdf.bash

asdf_update_java_home() {
    local current
    if current=$(asdf current java); then
        local version=$(echo $current | sed -e 's|\(.*\) \?(.*|\1|g')
        export JAVA_HOME=$(asdf where java $version)
    else
        echo "No java version set. Type `asdf list-all java` for all versions."
    fi
}
asdf_update_java_home
