#!/usr/bin/bash

databases_dir="$PWD/databases"
databases=()

if [[ ! -d "$databases_dir" ]]
then
    echo "No databases found."
    exit 1
fi

for database in "$databases_dir"/*
do
    [[ -d "$database" ]] && databases+=("$(basename "$database")")
done

if [[ ${#databases[@]} -eq 0 ]]
then
    echo "No databases found."
    exit 1
fi

echo "Select a database to connect to:"

select dataBaseName in "${databases[@]}"
do
    if [[ -n "$dataBaseName" ]]; then
        cd "$databases_dir/$dataBaseName"
        break
    else
        echo "Invalid selection!"
    fi
done

source "$scriptLocation/menu.sh"

