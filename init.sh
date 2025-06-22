#!/usr/bin/bash
location=$PWD
scriptLocation="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -d "$location/databases" ]]
then
    cd "$location/databases"
else
    mkdir "$location/databases"
    cd "$location/databases"
fi

source "$scriptLocation/main.sh"
