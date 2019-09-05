##
# Created by Exrienz @ Muzaffar Mohamed 2/9/2019
##
#./NessusComplianceParser.sh [CSV_filename_without_extension]

cat $1.csv | grep '"""' | sed 's/"""//g' | sed 's/"" ://g' | sed 's/""://g'  > $1.txt
cat $1.txt | sort -uk1,1 | sort -t '.' -n -k 1,1 -k 2,2 -k 3,3 -k 4,4 -k 5,5 -k 6,6 -k 7,7 -k 8,8 > sanitized.txt 
sed -i '/CIS/d' sanitized.txt
awk 'x[$1]++ == 1 { print $1}' $1.txt > number.txt
input="number.txt"
while IFS= read -r line
do
  if grep -q -E "$line.*FAILED" "$1.txt"; then
	sed -i "/$line/{;/\[PASSED\]/s/\[PASSED\]/\[FAILED\]/;}" sanitized.txt
  fi
done < "$input"
function compliance_score(){
	value=`cat sanitized.txt | grep -o "$2" | wc -l`
	echo "<h3>Total $2 Compliance: $value</h3>" >> $1.html 
}
echo "<html><table>" > $1.html
#compliance_score $1 "PASSED"
#compliance_score $1 "FAILED"
#compliance_score $1 "WARNING"
cat sanitized.txt | sed -e 's/^/<tr><td>/' | sed s'/.$/]<\/td><\/tr>/' | sed 's/ /<\/td><td>/' | sed -r 's/(.*) /\1<\/td><td align="center">/' | sed 's/\[PASSED\]/PASSED/' | sed 's/\[FAILED\]/FAILED/' | sed 's/\[WARNING\]/WARNING/' >> $1.html
rm $1.txt sanitized.txt number.txt
echo "</table></html>" >> $1.html
