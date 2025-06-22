#!/usr/bin/bash

validate_table_name() {
    if [[ ! $1 =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
        echo "Invalid table name. Must start with a letter or underscore and contain only letters, numbers, or underscores."
        return 1
    fi
    return 0
}

while true; do
    read -p "Enter table name: " table_name

    if ! validate_table_name "$table_name"; then
        continue
    fi

    if [[ -f "$table_name" || -f "${table_name}_meta" ]]; then
        echo "Table '$table_name' already exists."
        continue
    fi

    while true; do
        read -p "Enter number of fields: " num_fields
        if ! [[ "$num_fields" =~ ^[1-9][0-9]*$ ]]; then
            echo "Invalid number, please enter a positive integer."
            continue
        fi
        break
    done

    declare -a fields=()
    declare -a types=()
    pk_set=0
    pk_field=""

    for (( i=1; i<=num_fields; i++ )); do
        while true; do
            read -p "Enter name of field #$i: " field_name
            if [[ ! $field_name =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
                echo "Invalid field name. Must start with a letter or underscore and contain only letters, numbers, or underscores."
                continue
            fi

            duplicate=0
            for f in "${fields[@]}"; do
                if [[ "$f" == "$field_name" ]]; then
                    duplicate=1
                    break
                fi
            done
            if [[ $duplicate -eq 1 ]]; then
                echo "Field name '$field_name' already used, please enter a unique name."
                continue
            fi
            break
        done

        if [[ $pk_set -eq 0 ]]; then
            read -p "Is this field the primary key? (yes/no): " pk_answer
            case "$pk_answer" in
                y|Y|yes|YES|Yes)
                    pk_set=1
                    pk_field="$field_name"
                    ;;
                *)
                    ;;
            esac
        fi

        while true; do
            echo "Select data type for field '$field_name':"
            echo "1) string"
            echo "2) int"
            read -p "Enter choice (1 or 2): " dtype_choice
            case "$dtype_choice" in
                1)
                    dtype="string"
                    break
                    ;;
                2)
                    dtype="int"
                    break
                    ;;
                *)
                    echo "Invalid choice, please enter 1 or 2."
                    ;;
            esac
        done

        fields+=("$field_name")
        types+=("$dtype")
    done

    > "$table_name"

    IFS=":"; echo "${fields[*]}" > "$table_name"

    > "${table_name}_meta"
    for idx in "${!fields[@]}"; do
        field="${fields[$idx]}"
        type="${types[$idx]}"
        if [[ "$field" == "$pk_field" ]]; then
            echo "$field:$type:pk" >> "${table_name}_meta"
        else
            echo "$field:$type" >> "${table_name}_meta"
        fi
    done

    echo "Table '$table_name' created successfully with $num_fields fields."
    break
done