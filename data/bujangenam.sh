#!/bin/bash

curl -sS -L https://nsfw.oisd.nl -o oisd_nsfw.abp
curl -sS -L https://small.oisd.nl -o oisd_small.abp
curl -sS -L https://big.oisd.nl -o oisd_big.abp
curl -sS -L https://adguardteam.github.io/HostlistsRegistry/assets/filter_34.txt -o HaGeZi.abp
curl -sS -L https://adguardteam.github.io/HostlistsRegistry/assets/filter_22.txt -o ABPindo.abp
curl -sS -L https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt -o AdGuard.abp
curl -sS -L https://adguardteam.github.io/HostlistsRegistry/assets/filter_53.txt -o AWAvenue.abp
curl -sS -L https://raw.githubusercontent.com/d3ward/toolz/master/src/d3host.adblock -o D3ward.abp
curl -sS -L https://adguardteam.github.io/HostlistsRegistry/assets/filter_11.txt -o Malicious.abp

for file in tools/*; do
    filename=$(basename "$file")
    command -v $filename &> /dev/null || { cp ./tools/$filename /usr/local/bin/ && chmod +x /usr/local/bin/$filename; }
done

for file in *.abp; do
    mkdir -p ./Ads
    filename=$(basename "$file")
    txt_file="${filename%.*}.txt"
    yaml_file="${filename%.*}.yaml"
    mrs_file="${filename%.*}.mrs"
    srs_file="${filename%.*}.srs"
    json_file="${filename%.*}.json"

    # abp ==>> yaml ~ Domain ==>> mrs
    echo "payload:" > $txt_file && cat $file >> $txt_file
    sed -i 's/||\(.*\)\^/- "+.\1"/' $txt_file
    sed -i 's/0.0.0.0 \(.*\)/- "\1"/' $txt_file
    sed -i 's/\(.*\)/\1/' $txt_file
    sed -i 's/^! /# /' $txt_file
    sed -i -e '/^#/d' -e '/^$/d' $txt_file
    sed -i -e '/^!/d' -e '/^$/d' $txt_file
    teks=$(basename "$txt_file")
    category=$(echo "$teks")
    output_file="${category%.*}.txt"
    (cd Ads && mihomo convert-ruleset domain yaml $output_file ${output_file%.*}.mrs && mv -if "$filename" ${filename%.*}.txt) 

    # abp ==>> yaml ~ Classical
    echo "payload:" > $yaml_file && cat $file >> $yaml_file
    sed -i 's/||\(.*\)\^/  - DOMAIN-SUFFIX,\1/' $yaml_file
    sed -i 's/0.0.0.0 \(.*\)/  - DOMAIN-SUFFIX,\1/' $yaml_file
    sed -i 's/\(.*\)//' $yaml_file
    sed -i 's/\[\(.*\)\]//' $yaml_file
    sed -i 's/^! /# /' $yaml_file
    sed -i -e '/^#/d' -e '/^$/d' $yaml_file
    sed -i -e '/^!/d' -e '/^$/d' $yaml_file

    # yaml ==>> json srs
    jq -R 'select(test("^  - DOMAIN-SUFFIX")) | split(",")[1]' $yaml_file | jq -s '{ "version": 1, "rules": [{ "domain_suffix": . }] }' > $json_file
    sing-box rule-set convert $json_file
    sing-box rule-set compile $json_file

    echo "$txt_file"
    echo "$yaml_file"
    echo "$json_file"
    echo "$srs_file"

    mv "${file%.*}.txt" Ads/
    mv "${file%.*}.json" Ads/
    mv "${file%.*}.srs" Ads/
    mv "${file%.*}.yaml" Ads/
    mv "$file" Ads/
    
done




