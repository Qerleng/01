for file in rule_provider/mlbb_port.yaml; do
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
    129.227.151.138:30190
    sed -i 's/  - DST-PORT,\(.*\)/- ".*.*.*.*:\1"/' $txt_file
    sed -i 's/  - DOMAIN-REGEX,\(.*\)/- "\1"/' $txt_file
    sed -i 's/\(.*\)/\1/' $txt_file
    sed -i 's/^! /# /' $txt_file
    sed -i -e '/^#/d' -e '/^$/d' $txt_file
    sed -i -e '/^!/d' -e '/^$/d' $txt_file
    (mihomo convert-ruleset domain yaml $output_file ${output_file%.*}.mrs) 


    mv "$txt_file" rule_provider/
    mv "$mrs_file" rule_provider/
#    mv "${file%.*}.yaml" trash/

done
