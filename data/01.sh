for file in tools/*; do
    filename=$(basename "$file")
    command -v $filename &> /dev/null || { cp ./tools/$filename /usr/local/bin/ && chmod +x /usr/local/bin/$filename; }
done


for file in *.yaml; do
    filename=$(basename "$file")
    txt_file="${filename%.*}.txt"
    yaml_file="${filename%.*}.yaml"
    mrs_file="${filename%.*}.mrs"
    category=$(echo "$txt_file")
    echo $txt_file && cat $file >> $txt_file
    sed -i 's/- DOMAIN-SUFFIX,\(.*\)/- "+.\1"/' $txt_file
    sed -i 's/- DOMAIN,\(.*\)/- "\1"/' $txt_file
    sed -i 's/- DOMAIN-KEYWORD,\(.*\)/- "\1"/' $txt_file
    sed -i 's/- DST-PORT,\(.*\)//' $txt_file
    sed -i 's/- DOMAIN-REGEX,\(.*\)/- "\1"/' $txt_file
    (mihomo convert-ruleset domain yaml $category ${category%.*}.mrs) 

    # abp ==>> yaml ~ Classical
    echo $yaml_file && cat $file >> $yaml_file
    sed -i 's/-\(.*\)/  -\1/' $yaml_file

    # yaml ==>> json srs
    jq -R 'select(test("^  - DOMAIN-SUFFIX")) | split(",")[1]' $yaml_file | jq -s '{ "version": 1, "rules": [{ "domain_suffix": . }] }' > $json_file
    jq -R 'select(test("^  - DOMAIN-REGEX")) | split(",")[1]' $yaml_file | jq -s '{ "version": 1, "rules": [{ "domain_regex": . }] }' > $json_file
    sing-box rule-set compile $json_file

    mkdir -p trash
    mv "${file%.*}.txt" trash/
    mv "${file%.*}.mrs" trash/
    mv "${file%.*}.yaml" trash/
    mv "${file%.*}.abp" trash/

done
