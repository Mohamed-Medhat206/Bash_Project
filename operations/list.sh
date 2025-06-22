directory="$PWD/databases"

if [[ ! -d "$directory" ]]
then
    echo "Databases directory does not exist."
    exit 1
fi

databases=()

for item in "$directory"/*
do
    [[ -d "$item" ]] && databases+=("$(basename "$item")")
done

if [[ ${#databases[@]} -eq 0 ]]
then
    echo "No databases found."
else
    echo "Found databases:"
    for db in "${databases[@]}"
    do
        echo "$db"
    done
fi

