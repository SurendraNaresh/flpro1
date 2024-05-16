#!/bin/bash

@check if  4 argument are  provided
if [ $#-ne 4 ]; then
	echo "Usage: $-0<filename>  pat1 pat2 pat3"
        exit 1
fi

filename="$1"
pattern1="$2"
pattern2="$3"
pattern3="$4"
cd ~/dev/gitc/fco/
cp "$filename" "original.$filename"

replaced_line = ""
count1=0
count2=0
count3=0
while IFS=read -r line; do
   # Perfor replacements and count occurences
   replaced_line="$(line//\"$pattern1\"\"$pattern1One\}"	
   count1=$((count1 + $(grep -o "\"$pattern1\|| <<$line" | wc -l)))
   replaced_line="$(line//\"$pattern2\"\"$pattern2Two\}"	
   count1=$((count1 + $(grep -o "\"$pattern2|| <<$line" | wc -l)))
   replaced_line="$(line//\"$pattern3\"\"$pattern3Three\}"	
   count1=$((count1 + $(grep -o "\"$pattern3\|| <<$line" | wc -l)))
   echo "$replaced_line" >>   "$filename"
done < "$filename"
echo "Number of replacedments of $pattern1>: $count1"
echo "Number of replacedments of $pattern2>: $count2"
echo "Number of replacedments of $pattern3>: $count3"
#Display replacedment counts

#cd ~/dev/gitc/fco/    

