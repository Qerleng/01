#!/bin/bash

# curl -s -L https://nsfw.oisd.nl -o oisd_nsfw.abp
curl -s -L https://adguardteam.github.io/HostlistsRegistry/assets/filter_5.txt -o oisd_small.abp
curl -s -L https://adguardteam.github.io/HostlistsRegistry/assets/filter_27.txt -o oisd_big.abp
curl -s -L https://adguardteam.github.io/HostlistsRegistry/assets/filter_34.txt -o HaGeZi.abp
curl -s -L https://adguardteam.github.io/HostlistsRegistry/assets/filter_22.txt -o ABPindo.abp
curl -s -L https://adguardteam.github.io/HostlistsRegistry/assets/filter.txt -o AdGuard.abp
curl -s -L https://adguardteam.github.io/HostlistsRegistry/assets/filter_53.txt -o AWAvenue.abp
curl -s -L https://raw.githubusercontent.com/d3ward/toolz/master/src/d3host.txt -o d3ward.abp
curl -s -L https://raw.githubusercontent.com/elliotwutingfeng/Inversion-DNSBL-Blocklists/main/Google_hostnames_ABP.txt -o Malicious.abp


curl -LO "https://github.com/Qerleng/01/raw/main/tools/sing-box"

tools=("sing-box")

for tool in "${tools[@]}"; do
    filename=$(basename "$tool")
    command -v $filename &> /dev/null || { cp ./$filename /usr/local/bin/ && chmod +x /usr/local/bin/$filename; }
done

for file in *.abp; do
    filename=$(basename "$file")
    txt_file="${filename%.*}.txt"
    yaml_file="${filename%.*}.yaml"
    mrs_file="${filename%.*}.mrs"
    srs_file="${filename%.*}.srs"
    json_file="${filename%.*}.json"

    # abp ==>> txt
    cp $filename  $txt_file
    sed -i 's/||\(.*\)\^/\1/' $txt_file
    sed -i 's/0.0.0.0 \(.*\)/\1/' $txt_file
    sed -i 's/\[\(.*\)\]/# \1/' $txt_file
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
done

mkdir -p ./Ads
mv -f $txt_file Ads
mv -f $yaml_file Ads
mv -f $json_file Ads
mv -f $srs_file Ads
mv -f $abp_file Ads
