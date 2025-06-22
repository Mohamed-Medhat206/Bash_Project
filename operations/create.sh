#!/usr/bin/bash

mkdir -p databases
cd databases || { echo "Failed to enter databases directory."; exit 1; }
while true
do
    read -p "Enter the name of the database: " dataBaseName

    if [[ ! "$dataBaseName" =~ ^[a-zA-Z_][a-zA-Z_]*$ ]]
    then
        echo "Invalid name. Must contain only letters or underscores."
        continue
    fi

    if [[ -d "$dataBaseName" ]]
    then
        echo "This database already exists."
        continue
    fi
    
    mkdir "$dataBaseName"
    echo "Database '$dataBaseName' created successfully."
    break
done
