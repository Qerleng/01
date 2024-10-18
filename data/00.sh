curl -LO https://github.com/Qerleng/00/raw/main/rule_provider/FCM.yaml
curl -LO https://github.com/Qerleng/00/raw/main/rule_provider/NTP.yaml
curl -LO https://github.com/Qerleng/00/raw/main/rule_provider/Sosmed.yaml
curl -LO https://github.com/Qerleng/00/raw/main/rule_provider/Stream.yaml
curl -LO https://github.com/Qerleng/00/raw/main/rule_provider/E-Banking.yaml
curl -LO https://github.com/Qerleng/00/raw/main/rule_provider/gaming.yaml


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
    output_file="${category%.*}.txt"
    echo $txt_file && cat $file >> $txt_file
    sed -i 's/  - DOMAIN-SUFFIX,\(.*\)/\1/' $txt_file
    sed -i 's/  - DOMAIN,\(.*\)/full:\1/' $txt_file
    sed -i 's/  - DOMAIN-KEYWORD,\(.*\)/keyword\1/' $txt_file
    sed -i 's/  - DST-PORT,\(.*\)//' $txt_file
    sed -i 's/  - DOMAIN-REGEX,\(.*\)/regexp:\1/' $txt_file
    sed -i 's/\(.*\)/\1/' $txt_file
    sed -i 's/^! /# /' $txt_file
    sed -i -e '/^#/d' -e '/^$/d' $txt_file
    sed -i -e '/^!/d' -e '/^$/d' $txt_file
    (mihomo convert-ruleset domain yaml $output_file ${output_file%.*}.mrs) 

    mkdir -p trash
    mv "${file%.*}.txt" trash/
    mv "${file%.*}.mrs" trash/
    mv "${file%.*}.yaml" trash/

done
