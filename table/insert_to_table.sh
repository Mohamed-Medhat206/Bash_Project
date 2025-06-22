is_unique_pk() {
    local value=$1
    local pk_index=$2
    local table_file=$3

    awk -F: -v val="$value" -v idx="$pk_index" 'NR > 1 { if ($idx == val) exit 1 }' "$table_file"
    return $?
}

read_value_for_column() {
    local col_name=$1
    local col_type=$2
    local is_pk=$3
    local pk_index=$4
    local table_file=$5
    local value

    while true; do
        read -p "Enter value for '$col_name' ($col_type): " value

        if [[ "$col_type" == "int" ]]; then
            if ! [[ "$value" =~ ^[0-9]+$ ]]; then
                echo "The value you entered doesn’t match the data type of that column." >&2
                continue
            fi
        elif [[ "$col_type" == "string" ]]; then
            if ! [[ "$value" =~ ^[a-zA-Z0-9_]*$ ]]; then
                echo "The value you entered doesn’t match the data type of that column." >&2
                continue
            fi
        fi

        if [[ "$is_pk" == "pk" ]]; then
            if ! is_unique_pk "$value" "$pk_index" "$table_file"; then
                echo "This primary key value already exists. Please enter a unique value." >&2
                continue
            fi
        fi

        echo "$value"
        return 0
    done
}

while true; do
    read -p "Enter table name: " table_name

    if [[ -f "$table_name" && -f "${table_name}_meta" ]]; then
        break
    else
        echo "Table '$table_name' does not exist. Please enter a valid table name."
    fi
done


IFS=$'\n' read -d '' -r -a meta < "${table_name}_meta"

values=()
pk_index=0

for i in "${!meta[@]}"; do
    IFS=":" read -r col_name col_type is_pk <<< "${meta[$i]}"
    if [[ "$is_pk" == "pk" ]]; then
        pk_index=$((i + 1))  
    fi

    value=$(read_value_for_column "$col_name" "$col_type" "$is_pk" "$pk_index" "$table_name")
    values+=("$value")
done

IFS=":"; echo "${values[*]}" >> "$table_name"
echo "Row inserted successfully into '$table_name'."