table_names=()

for file in *; do
    [[ -f "$file" && "$file" != *_meta ]] || continue

    if [[ -f "${file}_meta" ]]; then
        table_names+=("$file")
    fi
done

if [[ ${#table_names[@]} -eq 0 ]]; then
    echo "No tables found."
else
    for table in "${table_names[@]}"; do
        echo "- $table"
    done
fi