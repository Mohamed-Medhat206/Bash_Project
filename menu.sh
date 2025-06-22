#!/usr/bin/bash


scriptDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
tableMenu=("Create table" "List tables" "Drop table" "Insert to table" "Select from table" "Delete from table" "Update table" "Exit")

while true 
do
    echo "Choose a table operation:"
    select option in "${tableMenu[@]}"
    do
        case $option in
            "Create one table")
                source "$scriptDir/table/create.sh"
                ;;
            "List all tables")
                source "$scriptDir/table/list.sh"
                ;;
            "Drop one table")
                source "$scriptDir/table/drop.sh"
                ;;
            "Insert to one table")
                source "$scriptDir/table/insert_to_table.sh"
                ;;
            "Select from table")
                source "$scriptDir/table/select_from_table.sh"
                ;;
            "Delete from table")
                source "$scriptDir/table/delete_from_table.sh"
                ;;
            "Update one table")
                source "$scriptDir/table/update_data.sh"
                ;;
            "Exit")
                echo "Exiting..."
                exit 0
                ;;
            *)
                echo "Invalid option. Try again."
                ;;
        esac
    done
done

