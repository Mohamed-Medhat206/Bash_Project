operations=("Create database" "Drop database" "List databases" "Connect to database" "Exit")
select var in "${operations[@]}"
do
    case $var in
	"Connect to the database")
	    source $scriptLocation/operations/connect.sh
	    ;;
	"Create the database")
	    source $scriptLocation/operations/create.sh
	    ;;
	"Drop the database")
	    source $scriptLocation/operations/drop.sh
	    ;;
	"List the databases")
	    source $scriptLocation/operations/list.sh
	    ;;
	"Exit from the program")
	    echo "Closing the app..."
	    break
	    ;;
	*)
	    echo "Invalid choice!"
	    ;;
    esac
done
