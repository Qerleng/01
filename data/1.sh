for file in rule_provider/*.yaml; do
    filename=$(basename "$file")
    txt_file="${filename%.*}.txt"
    yaml_file="${filename%.*}.yaml"
    mrs_file="${filename%.*}.mrs"
    category=$(echo "$txt_file")
    output_file="${category%.*}.txt"
    echo $txt_file && cat $file >> $txt_file
    sed -i 's/  - DOMAIN-SUFFIX,\(.*\)/- "+.\1"/' $txt_file
    sed -i 's/  - DOMAIN,\(.*\)/- "\1"/' $txt_file
    sed -i 's/  - DOMAIN-KEYWORD,\(.*\)/- "\1"/' $txt_file
    sed -i 's/  - DST-PORT,\(.*\)//' $txt_file
    sed -i 's/  - DOMAIN-REGEX,\(.*\)/- "\1"/' $txt_file
    sed -i 's/\(.*\)/\1/' $txt_file
    sed -i 's/^! /# /' $txt_file
    sed -i -e '/^#/d' -e '/^$/d' $txt_file
    sed -i -e '/^!/d' -e '/^$/d' $txt_file
    (mihomo convert-ruleset domain yaml $output_file ${output_file%.*}.mrs) 


    rm "${file%.*}.txt" 
    mv "${file%.*}.mrs" rule_provider/
#    mv "${file%.*}.yaml" trash/

done
