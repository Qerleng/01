for file in tools/*; do
    filename=$(basename "$file")
    command -v $filename &> /dev/null || { cp ./tools/$filename /usr/local/bin/ && chmod +x /usr/local/bin/$filename; }
done


for file in *.yaml; do
    filename=$(basename "$file")
    txt_file="${filename%.*}.txt"
    json_file="${filename%.*}.json"
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


    jq -nR '{
        version: 1,
        rules: [
            reduce (inputs | sub("^ *- *"; "") | select(length > 0) | split(",")) as $item ({};
                if $item[0] == "DOMAIN-SUFFIX" then
                    .domain_suffix += [$item[1]]
                elif $item[0] == "DOMAIN-KEYWORD" then
                    .domain_keyword += [$item[1]]
                elif $item[0] == "DOMAIN-REGEX" then
                    .domain_regex += [$item[1]]
                elif $item[0] == "DOMAIN" then
                    .domain += [$item[1]]
                else
                    .
                end
            )
        ]
    }' < $yaml_file > $json_file && \
    sing-box rule-set format $json_file -w && \
    sing-box rule-set compile $json_file &


done
