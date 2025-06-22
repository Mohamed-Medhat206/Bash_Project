#!/usr/bin/bash

delete_all_data() {
    read -p "Enter table name to delete all data: " table_name
    if [[ ! -f "$table_name" ]]; then
        echo "Table '$table_name' does not exist."
        return
    fi
    head -n 1 "$table_name" > temp && mv temp "$table_name"
    echo "All data deleted from table '$table_name'."
}

delete_by_filter() {
    read -p "Enter table name to delete from: " table_name
    if [[ ! -f "$table_name" ]]; then
        echo "Table '$table_name' does not exist."
        return
    fi

    IFS=':' read -r -a columns < "$table_name"
    echo "Available columns:"
    for i in "${!columns[@]}"; do
        echo "$((i+1))) ${columns[$i]}"
    done

    read -p "Enter column number to filter by: " col_index
    ((col_index--))
    if [[ $col_index -lt 0 || $col_index -ge ${#columns[@]} ]]; then
        echo "Invalid column selection."
        return
    fi

    read -p "Enter value to match for deletion: " value

    awk -F: -v col=$((col_index+1)) -v val="$value" 'NR==1 || $col != val' "$table_name" > temp && mv temp "$table_name"
    echo "Rows where '${columns[$col_index]}' = '$value' have been deleted."
}

while true; do
    echo "Choose delete option:"
    echo "1) Delete all data"
    echo "2) Filter by column (delete rows that match)"
    echo "3) Exit"
    read -p "#? " choice
    case $choice in
        1) delete_all_data ;;
        2) delete_by_filter ;;
        3) break ;;
        *) echo "Invalid option. Please try again." ;;
    esac
done