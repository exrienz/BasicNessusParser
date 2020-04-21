##
# Created by Exrienz @ Muzaffar Mohamed 2/9/2019
##
#./NessusComplianceParser.sh [CSV_filename_without_extension]

clear

cat $1.csv | grep '"""' | cut -d "]" -f1  > output.txt
cat output.txt | grep '"""' | sed 's/"""//g' | sed 's/"" ://g' | sed 's/""://g'  > output2.txt

#Remove Badwords
sed -i '/CIS/d' output2.txt
sed -i '/OPTIONS=/d' output2.txt
sed -i '/Paynet_Generic_Redhat.audit/d' output2.txt
sed -i '/\/usr\/bin\/awk/d' output2.txt

#Add 999.0. in front, and 0.999 behind. Remove it later
cat output2.txt | sed 's/^/999.0./' | awk '{sub("$", "0.999", $1)}; 1' > output3.txt
mv output3.txt output2.txt

#Sorting Numbers
cat output2.txt | sort -uk1,1 | sort -t '.' -n -k 1,1 -k 2,2 -k 3,3 -k 4,4 -k 5,5 -k 6,6 -k 7,7 -k 8,8 > sanitized.txt 
sed -i '/CIS/d' sanitized.txt
sed -i '/\/usr\/bin\/awk/d' sanitized.txt

awk 'x[$1]++ == 1 { print $1}' output2.txt > number.txt

####Grep line where contain 'number'

input="number.txt"
while IFS= read -r line
do
  if grep -q -E "$line.*FAILED" "output2.txt"; then
	sed -i "/$line/{;/\[PASSED/s/\[PASSED/\[FAILED/;}" sanitized.txt
  fi
done < "$input"

function compliance_score(){
	value=`cat sanitized.txt | grep -o "$2" | wc -l`
	echo "<h3>Total $2 Compliance: $value</h3>" >> $1.html 
}

echo "<html><table>" > $1.html
compliance_score $1 "PASSED"
compliance_score $1 "FAILED"
compliance_score $1 "WARNING"

# Remove extra number
#Add 999.0. in front. Remove it later
cat sanitized.txt | sed 's/999.0.//g' | sed 's/0.999//' > output3.txt
mv output3.txt sanitized.txt 

cat sanitized.txt | sed -e 's/^/<tr><td>/' | sed s'/.$/]<\/td><\/tr>/' | sed 's/ /<\/td><td>/' | sed -r 's/(.*) /\1<\/td><td align="center">/' | sed 's/\[PASSE\]/PASSED/' | sed 's/\[FAILE\]/FAILED/' | sed 's/\[WARNIN\]/WARNING/' >> $1.html

rm output.txt output2.txt sanitized.txt number.txt
echo "</table></html>" >> $1.html

clear

echo
echo "======================================="
echo "Success! Your output was in HTML format"
echo "======================================="
echo
