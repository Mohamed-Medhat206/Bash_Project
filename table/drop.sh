#!/usr/bin/bash

validate_table_name() {
    if [[ ! $1 =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
        echo "Invalid table name. Must start with a letter or underscore and contain only letters, numbers, or underscores."
        return 1
    fi
    return 0
}

while true; do
    read -p "Enter the name of the table to drop: " table_name

    if ! validate_table_name "$table_name"; then
        continue
    fi

    if [[ -f "$table_name" ]]; then
        read -p "Are you sure you want to delete the table '$table_name'? This action cannot be undone! (y/n): " confirm
        if [[ $confirm == [Yy] ]]; then
            rm "$table_name"
            if [[ -f "${table_name}_meta" ]]; then
                rm "${table_name}_meta"
            fi
            echo "Table '$table_name' deleted successfully."
        else
            echo "Deletion cancelled."
        fi
        break
    else
        echo "There is no table with this name."
    fi
done