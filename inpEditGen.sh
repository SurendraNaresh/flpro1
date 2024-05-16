#!/bin/bash
#@check if atleast 3 argument are  provided
if [ $# -le 1 ]; then
	echo "Usage: $0 <filename> dbtable -a <appname>" 1>&2
    exit 1
fi
# //Default values
rep1="Application_Name"
rep2="Application_home"
rep3="Application_state"
# // process options
while getopts "a:r:x" opt; do
  case $opt in
    a) appname="$OPTARG";;
    r) repname="$OPTARG";;
    x) echo -e "Usage: $0 [-a appName] [-r repName]" >&2; exit 1;;
    \?) echo "Invalid option: -$OPTARG" >&2; exit 1;;
  esac
done

shift $((OPTIND-1))
# //process the remanings filename, tablename and appno
filename="$1"
table_name="$2"
app_no=$3;   
if [ -z "filename" ] || [ -z "$table_name" ] ; 
then
    echo "Missing filename or table name!" >&2
    exit 1
fi
echo "parameters used:"
echo "... \$table_name=$table_name"
echo "... \$appname=$appname"  # Assuming widget name was set using -a
echo "... \$repname=$repname"
#// InitDbTable ::Creates the table if it does_not exists.
sqlite3 ddir/camp.db <<SqEndLine
        CREATE TABLE IF NOT EXISTS records (
            fld1 INT AUTO_INCREMENT PRIMARY KEY/* AppNo */
            ,fld2 varchar(30)               /* AppName */ 
            ,fld3 varchar(30)               /* AppShow */
            ,fld4 varchar(30)               /* AppHome */ 
            ,fld5 varchar(30)               /* AppState */
        );
SqEndLine
# Get last app number (if no appno provided)
last_app_no=$(sqlite3 ddir/camp.db <<< "SELECT MAX(fld1) FROM $table_name;" | cut -d'|' -f2)
if [ $? -ne 0 ]; then
    echo "Error accessing db !" >&2
    exit 1
fi
# Calculate the next application number
let "next_app_no = last_app_no + 1"
#echo "parameters used:... \$table=$table_name; \$appname=$appname; \$repname=$repname"
# Check if the -r (new) application name already exists
app_no=$(sqlite3 ddir/camp.db <<<"SELECT fld1 FROM $table_name WHERE fld2 like '%$repname%';")
if [[ ! -z "$app_no" ]]; then
    echo "Error in data: $repname already exists!" >&2
    exit 1
fi
#If no records found, $last_app_no=="0"
# if [ "$(sqlite3 ddir/camp.db <<<'SELECT count() FROM $table_name;')" -le "0" ]; then
#      echo "Table contains no applications... adding default "
# fi
# Generate replacements with appname
rep1="${appname}_show"
rep2="${appname}_home"
rep3="${appname}_state"

# Perform replacements using a single sed command with multiple substitutions:
sed -E "s/\"(${rep1}|${rep2}|${rep3})_(show|home|state)\"/\"\\${repname}_\1\"/g" "$filename" > "$filename.replaced"
#cp "$filename.replaced" "$filename"
echo -e "Replacements made and backuped to $filename.replaced"
# Update the database (if appname provided)
if [ -n "$appname" ]; then
    # Escape special characters for safe SQL insertions
    escaped_app=$(echo "$appname" | sed 's/\\/\\\\/g; s/"/\\\"/g')
    echo -e "\$escaped_app = $escaped_app\n"
    sql_insert="INSERT INTO $table_name (fld1, fld2, fld3, fld4, fld5) VALUES ($next_app_no, '${escaped_app}_name', '${escaped_app}_show', '${escaped_app}_home', '${escaped_app}_state');"
    echo "$sql_insert"
    # Execute the SQL statement using the opened connection
    sqlite3 ddir/camp.db <<<"$sql_insert"
    if [ $? -ne 0 ]; then
        echo "Error updating the database:~ $2" >&2
        exit 1
    fi
fi
