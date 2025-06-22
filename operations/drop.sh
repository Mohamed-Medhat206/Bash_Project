#!/usr/bin/bash

databases_dir="$PWD/databases"
valid_name() {
    if [[ ! $1 =~ ^[a-zA-Z_][a-zA-Z_]*$ ]]
    then
        echo "Invalid name. Must contain only letters or underscores."
        return 1
    fi
    return 0
}

if [[ ! -d "$databases_dir" ]]
then
    echo "No databases directory found."
    exit 1
fi

while true
do
    read -p "Enter the name of the database to drop: " dataBaseName

    if ! valid_name "$dataBaseName"
    then
        continue
    fi

    target_db="$databases_dir/$dataBaseName"

    if [[ -d "$target_db" ]]
    then
        read -p "Are you sure you want to delete the database '$dataBaseName'? (y/n): " confirmed
        if [[ $confirmed == [Yy] ]]
        then
            rm -r "$target_db"
            echo "Database '$dataBaseName' deleted successfully."
        else
            echo "Canceled."
        fi
        break
    else
        echo "No database with this name in '$databases_dir'!"
    fi
done

