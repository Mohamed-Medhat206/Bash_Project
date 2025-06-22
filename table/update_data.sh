is_valid_int() {
    [[ "$1" =~ ^[0-9]+$ ]]
}

is_valid_string() {
    [[ "$1" =~ ^[a-zA-Z0-9_]+$ ]]
}

while true; do
    read -p "Enter the table name: " table_name
    if [[ ! -f "$table_name" || ! -f "${table_name}_meta" ]]; then
        echo "Table '$table_name' does not exist. Please try again."
        continue
    fi

    IFS=":" read -r -a columns < "$table_name"
    mapfile -t meta_lines < "${table_name}_meta"

    col_types=()
    pk_col=""
    pk_index=-1

    for i in "${!meta_lines[@]}"; do
        IFS=":" read -r col type pk <<< "${meta_lines[i]}"
        col_types[i]="$type"
        if [[ "$pk" == "pk" ]]; then
            pk_col="$col"
            pk_index=$i
        fi
    done

    echo "Available columns to search with:"
    for i in "${!columns[@]}"; do
        echo "$((i+1))) ${columns[i]}"
    done

    while true; do
        read -p "Choose the column number to update by: " col_choice
        if ! [[ "$col_choice" =~ ^[0-9]+$ ]] || (( col_choice < 1 || col_choice > ${#columns[@]} )); then
            echo "Invalid choice, please enter a valid column number."
            continue
        fi
        search_col_index=$((col_choice - 1))
        search_col_name="${columns[search_col_index]}"
        search_col_type="${col_types[search_col_index]}"
        break
    done

    while true; do
        read -p "Enter the value to match in column '$search_col_name': " search_value
        if [[ "$search_col_type" == "int" ]]; then
            if ! is_valid_int "$search_value"; then
                echo "Invalid input. Column '$search_col_name' expects an integer."
                continue
            fi
        elif [[ "$search_col_type" == "string" ]]; then
            if ! is_valid_string "$search_value"; then
                echo "Invalid input. Column '$search_col_name' expects an alphanumeric string (letters, digits, space, underscore)."
                continue
            fi
        fi
        break
    done

    awk_field=$((search_col_index + 1))
    row_to_update=$(awk -F: -v field="$awk_field" -v val="$search_value" '
        $field == val { print; found=1; exit }
        END { if (!found) exit 1 }
    ' "$table_name")

    if [[ $? -ne 0 ]]; then
        echo "No row found with '$search_col_name' = '$search_value'. Try again."
        continue
    fi

    echo "Current row: $row_to_update"

    IFS=":" read -r -a old_values <<< "$row_to_update"
    new_values=()

    for i in "${!columns[@]}"; do
        col="${columns[i]}"
        type="${col_types[i]}"
        old_val="${old_values[i]}"

        while true; do
            read -p "Enter new value for '$col' (leave blank to keep '$old_val'): " input

            if [[ -z "$input" ]]; then
                new_values[i]="$old_val"
                break
            fi

            if [[ "$type" == "int" ]]; then
                if ! is_valid_int "$input"; then
                    echo "Invalid input. '$col' expects an integer."
                    continue
                fi
            elif [[ "$type" == "string" ]]; then
                if ! is_valid_string "$input"; then
                    echo "Invalid input. '$col' expects an alphanumeric string (letters, digits, space, underscore)."
                    continue
                fi
            fi

            if [[ "$col" == "$pk_col" && "$input" != "$old_val" ]]; then
                awk -F: -v pk_idx=$((pk_index + 1)) -v val="$input" '
                    $pk_idx == val { found=1; exit }
                    END { exit !found }
                ' "$table_name"
                if [[ $? -eq 0 ]]; then
                    echo "Primary key value '$input' already exists. Please enter a unique value."
                    continue
                fi
            fi

            new_values[i]="$input"
            break
        done
    done

    new_row=$(IFS=:; echo "${new_values[*]}")

    awk -F: -v pk_idx=$((search_col_index + 1)) -v pk_val="$search_value" -v new_line="$new_row" '
        BEGIN { OFS=":" }
        $pk_idx == pk_val { print new_line; next }
        { print }
    ' "$table_name" > "$table_name.tmp" && mv "$table_name.tmp" "$table_name"

    echo "Row updated successfully."
    break
done