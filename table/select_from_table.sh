#!/usr/bin/bash

select_menu() {
    echo "Select operation:"
    echo "1) Select all"
    echo "2) Filter by column"
    echo "3) Select specific columns"
    echo "4) Exit"
    read -p "#? " choice

    case $choice in
        1)
            select_all
            ;;
        2)
            filter_by_column
            ;;
        3)
            select_specific_columns
            ;;
        4)
            echo "Exiting selection."
            ;;
        *)
            echo "Invalid option"
            ;;
    esac
}

select_all() {
    read -p "Enter table name: " table
    if [[ ! -f "$table" ]]; then
        echo "Table does not exist."
        return
    fi
    cat "$table"
}

filter_by_column() {
    read -p "Enter table name: " table
    if [[ ! -f "$table" || ! -f "${table}_meta" ]]; then
        echo "Table or metadata not found."
        return
    fi

    IFS=':' read -r -a headers < "$table"
    echo "Available columns:"
    for i in "${!headers[@]}"; do
        echo "$((i+1))) ${headers[i]}"
    done

    read -p "Select column number: " col_num
    ((col_num--))

    if [[ $col_num -lt 0 || $col_num -ge ${#headers[@]} ]]; then
        echo "Invalid column number."
        return
    fi

    read -p "Enter value to match: " val
    while IFS= read -r line; do
        IFS=':' read -ra row <<< "$line"
        if [[ "${row[$col_num]}" == "$val" ]]; then
            echo "$line"
        fi
    done < <(tail -n +2 "$table")
}

select_specific_columns() {
    read -p "Enter table name: " table
    if [[ ! -f "$table" ]]; then
        echo "Table not found."
        return
    fi

    IFS=':' read -r -a headers < "$table"
    echo "Available columns:"
    for i in "${!headers[@]}"; do
        echo "$((i+1))) ${headers[i]}"
    done

    read -p "Enter column numbers to select (e.g. 1 3): " -a cols
    echo "Selected columns: ${cols[@]}"

    echo "--------------------------------"
    for col in "${cols[@]}"; do
        ((col--))
        printf "%s\t" "${headers[$col]}"
    done
    echo -e "\n--------------------------------"

    tail -n +2 "$table" | while IFS=':' read -ra row; do
        for col in "${cols[@]}"; do
            ((col--))
            printf "%s\t" "${row[$col]}"
        done
        echo
    done
}

select_menu