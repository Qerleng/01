#!/bin/bash

# curl -s -L https://nsfw.oisd.nl -o oisd_nsfw.abp
curl -s -L https://adguardteam.github.io/HostlistsRegistry/assets/filter_5.txt -o oisd_small.abp
curl -s -L https://adguardteam.github.io/HostlistsRegistry/assets/filter_27.txt -o oisd_big.abp
curl -s -L https://adguardteam.github.io/HostlistsRegistry/assets/filter_34.txt -o HaGeZi.abp
curl -s -L https://adguardteam.github.io/HostlistsRegistry/assets/filter_22.txt -o ABPindo.abp
curl -s -L https://adguardteam.github.io/HostlistsRegistry/assets/filter.txt -o AdGuard.abp
curl -s -L https://adguardteam.github.io/HostlistsRegistry/assets/filter_53.txt -o AWAvenue.abp
curl -s -L https://raw.githubusercontent.com/d3ward/toolz/master/src/d3host.txt -o D3ward.abp
curl -s -L https://raw.githubusercontent.com/elliotwutingfeng/Inversion-DNSBL-Blocklists/main/Google_hostnames_ABP.txt -o Malicious.abp


for file in tools/*; do
    filename=$(basename "$file")
    command -v $filename &> /dev/null || { cp ./tools/$filename /usr/local/bin/ && chmod +x /usr/local/bin/$filename; }
done

for file in *.abp; do
    filename=$(basename "$file")
    txt_file="${filename%.*}.txt"
    yaml_file="${filename%.*}.yaml"
    mrs_file="${filename%.*}.mrs"
    srs_file="${filename%.*}.srs"
    json_file="${filename%.*}.json"

    # abp ==>> yaml ~ Domain
    echo "payload:" > $txt_file && cat $file >> $txt_file
    sed -i 's/||\(.*\)\^/- "+.\1["]/' $txt_file
    sed -i 's/0.0.0.0 \(.*\)/-"\1["]/' $txt_file
    sed -i 's/\[\(.*\)\]/\1/' $txt_file
    sed -i 's/^! /# /' $txt_file
    sed -i -e '/^#/d' -e '/^$/d' $txt_file
    sed -i -e '/^!/d' -e '/^$/d' $txt_file

    # abp ==>> yaml ~ Classical 
    echo "payload:" > $yaml_file && cat $file >> $yaml_file
    sed -i 's/||\(.*\)\^/  - DOMAIN-SUFFIX,\1/' $yaml_file
    sed -i 's/0.0.0.0 \(.*\)/  - DOMAIN-SUFFIX,\1/' $yaml_file
    sed -i 's/\[\(.*\)\]/# \1/' $yaml_file
    sed -i 's/^! /# /' $yaml_file
    sed -i -e '/^#/d' -e '/^$/d' $yaml_file
    sed -i -e '/^!/d' -e '/^$/d' $yaml_file

    # yaml ==>> json srs
    jq -R 'select(test("^  - DOMAIN-SUFFIX")) | split(",")[1]' $yaml_file | jq -s '{ "version": 1, "rules": [{ "domain_suffix": . }] }' > $json_file
    sing-box rule-set compile $json_file

    mkdir -p ./Ads
    mv "${file%.abp}.txt" Ads/
    mv "${file%.abp}.yaml" Ads/
    mv "${file%.abp}.json" Ads/
    mv "${file%.abp}.srs" Ads/
    mv "$file" Ads/
    
done

for file in ./Ads/*.txt; do
    filename=$(basename "$file")
    mkdir -p ./test/
    category=$(echo "$filename")
    output_file="test/${category%.*}.yaml"
    echo "payload:" > $output_file
    mv "$file" $output_file
done

for file in test/*; do
    filename=$(basename "$file")
    (cd test && mihomo convert-ruleset domain yaml $filename ${filename%.*}.mrs) &
done
