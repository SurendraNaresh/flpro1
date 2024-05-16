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
while getopts"a:r:s:t:x" opt, do
    case $opt in 
	a) appname="$OPTARG";;
 	r) rep1="$OPTARG";;
 	a) rep2="$OPTARG";;
 	a) rep3="$OPTARG";;
 	x) echo -e "Usage:app_name=$0 [-a appName] [-r\-s\-t rep1\2\3]" >&2; exit1  ;;
	\?) echo "Invalid option: -$OPTARG" >&2 ; exit 1;;
    esac
done3
shift $((OPTIND-1))
# //process the remanings filename, tablename and appno
 	
filename="$1"
table_name="$2"
app_no=$3;   

if [-z "filename" ] || [-z "$table_name"] ; 
then
    echo "Missing filename or table name!" >&2
    exit 1
fi
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
last_app_no=$(sqlite ddir/camp.db <<SqLastLine
    Select Max(fld1) from $table_name;" | cut -d '|' -F 2) 
SqLastLine
)
if [ $? -ne 0 ]; then 
	    echo"Error accessing db !" >&2  
	    exit 1
fi
let "next_app_no = last_app_no + 1"
    # //Check if app name exists (optional)
    app_no=$(
sqlite3 ddir/camp.db <<SqEndLine
        Select fld1 from $table_name Where fld2='$appname' ;  
SqEndLine
)
if [ $app_no -ne 0]; then
    echo "Error in data:  $appname already exists! " >&2 
    exit 1
fi

# //If no records found $app_no=="0"
if [ -z "$app_no" ] ; then
    echo "App name '$appname' notg found!" >&2
    echo "Table contains no applications... adding default " 
    //exit 1
if

# //Create Backup of original 
#app_no = $(sqlite3 -c "Select fld1 from $table_name Where fld2='$appname';"
#cd ~/dev/gitc/fco/
cp "$filename" "original.$filename"
replaced_line = ""
count1=0
count2=0
count3=0
# //Generate replacements with appname
app_show=${appname}_show
app_home=${appname}_home
app_state=${appname}_state

while IFS=read -r line; do
   if [ -z | "$appname" ]
   # Perfor replacements and count occurences
   replaced_line="$(line//\"$app_show\"\"$rep1\")	
   count1=$((count1 + $(grep -o "\"$app_show\|| <<$line" | wc -l)))
   replaced_line="$(line//\"$app_home\"\"$rep2\")	
   count1=$((count1 + $(grep -o "\"$app_home|| <<$line" | wc -l)))
   replaced_line="$(line//\"$app_state\"\"$rep3\")	
   count1=$((count1 + $(grep -o "\"$app_state\|| <<$line" | wc -l)))
done < "$filename"
  echo "Number of replacedments of $pattern1>: $count1"
  echo "Number of replacedments of $pattern2>: $count2"
  echo "Number of replacedments of $pattern3>: $count3"
#Display replacedment counts
#cd ~/dev/gitc/fco/    
# //Update the database (if appname provided)
if [ -n "$appname" ] ; then 
    #Escape special characters for safe sql_insertions
    escaped_app=$(echo $appname | sed 's/\\/\\\\/g')
    #escaped_app=$(echo $appname |sed 's/\\/\\\\/g;s/"/\\\"/g' )
    #echo -e "\$escaped_app = $escaped_app\n"

sqlite ddir/camp.db.sql <<SqEndingLine
    Insert into $table_name (fld1,fld2,fld3,fld4,fld5) 
       values ($next_app_no,
               "${escaped_app}_name",
               "${escaped_app}_show",
               "${escaped_app}_home",
               "${escaped_app}_state"
     );

SqEndingLine 
)
    if [$? -ne  0]; then
        echo "Error updating the database:~ $2 " >&2
        exit 1
    fi

fi

echo -e "Replacements made and backuped to $origin.$filename"
