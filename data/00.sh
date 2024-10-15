curl -s -LO https://github.com/Qerleng/00/raw/main/rule_provider/FCM.yaml
curl -s -LO https://github.com/Qerleng/00/raw/main/rule_provider/NTP.yaml
curl -s -LO https://github.com/Qerleng/00/raw/main/rule_provider/wa.yaml


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
    sed -i 's/  - DOMAIN-SUFFIX,\(.*\)/- "+.\1"/' $txt_file
    sed -i 's/  - DOMAIN,\(.*\)/- "\1"/' $txt_file
    sed -i 's/  - DOMAIN-KEYWORD,\(.*\)/- "\1"/' $txt_file
    sed -i 's/  - DST-PORT,\(.*\)/- \:1/' $txt_file
    sed -i 's/  - DOMAIN-REGEX,\(.*\)/- "\1"/' $txt_file
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
