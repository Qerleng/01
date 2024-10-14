#!/bin/bash

set -e -o pipefail


curl -Lo geoip.db "https://github.com/rfxcll/v2ray-rules-dat/releases/latest/download/GeoIP.db"
curl -Lo geosite.db "https://github.com/rfxcll/v2ray-rules-dat/releases/latest/download/GeoSite.db"
curl -Lo geoip.dat "https://github.com/rfxcll/v2ray-rules-dat/releases/latest/download/GeoIP.dat"
curl -Lo geosite.dat "https://github.com/rfxcll/v2ray-rules-dat/releases/latest/download/GeoSite.dat"


#./sing-box geosite list private -f geosite.db | awk '{print $1}' | sort > geosite_categories

geoipAddresses=("fastly" "doh" "malicious" "cloudfront" "id" "facebook" "google" "netflix" "telegram" "twitter")
geositeDomains=("category-porn" "oisd-nsfw" "rule-doh" "rule-gaming" "rule-indo" "rule-playstore" "rule-sosmed" "rule-streaming" "rule-umum" "rule-ipcheck" "rule-speedtest" "videoconference" "rule-malicious" "urltest" "openai" "ecommerce-id" "bank-id")

for tool in tools/*; do
    filename=$(basename "$tool")
    command -v $filename &> /dev/null || { cp ./$filename /usr/local/bin/ && chmod +x /usr/local/bin/$filename; }
done

for item in "${geoipAddresses[@]}"; do
    mkdir -p ./rule/ip
    v2dat unpack geoip -o ./rule/ip -f "$item" "geoip.dat"
done 

for item in "${geositeDomains[@]}"; do
    mkdir -p ./rule/geo
    v2dat unpack geosite -o ./rule/geo -f "$item" "geosite.dat"
done 

# txt ==>> yaml
for file in ./rule/ip/*; do
    filename=$(basename "$file")
    mkdir -p ./rule-set/geoip/
    mkdir -p ./rule_provider/
    category=$(echo "$filename" | sed 's/geoip_\(.*\)\.*/\1/')
    output_file="rule_provider/${category%.*}.yaml"
    echo "payload:" > $output_file
    output_file2="rule/ip/${category%.*}.yaml"
    echo "payload:" > $output_file2
    while IFS= read -r line; do
        case $line in
            *.*.*.*/*)
                echo "  - IP-CIDR,${line#Anjengg:}" >> "$output_file"
                echo "- '${line#IP-CIDR:}'" >> "$output_file2"
                ;;
            *)
                echo "  - IP-CIDR6,$line" >> "$output_file"
                echo "- '${line#IP-CIDR6:}'" >> "$output_file2"
                ;;
        esac
    done < "$file" &
done

for file in ./rule/geo/*; do
    filename=$(basename "$file")
    category=$(echo "$filename" | sed 's/geosite_\(.*\)\.*/\1/')
    output_file="rule_provider/${category%.*}.yaml"
    echo "payload:" > $output_file
    output_file2="rule/geo/${category%.*}.yaml"
    echo "payload:" > $output_file2
    while IFS= read -r line; do
        case $line in
            regexp:*)
                echo "  - DOMAIN-REGEX,${line#regexp:}" >> "$output_file"
                echo "- '${line#regexp:}'" >> "$output_file2"
                ;;
            keyward:*)
                echo "  - DOMAIN-KEYWORD,${line#keyward:}" >> "$output_file"
                echo "- '+.${line#keyward:}'" >> "$output_file2"
                ;;
            full:*)
                echo "  - DOMAIN,${line#full:}" >> "$output_file"
                echo "- '${line#full:}'" >> "$output_file2"
                ;;
            *)
                echo "  - DOMAIN-SUFFIX,$line" >> "$output_file"
                echo "- '+.$line'" >> "$output_file2"
                ;;
        esac
    done < "$file" &
done

# yaml ==>> mrs
# rm rule-set/geosite/*.mrs rule-set/geoip/*.mrs

for file in rule/geo/*.yaml; do
    filename=$(basename "$file")
    (cd rule/geo && mihomo convert-ruleset domain yaml $filename ${filename%.*}.mrs && mv -if "${filename%.*}.mrs" ../../rule_provider/ && rm -if  $filename) &
done

for file in rule/ip/*.yaml; do
    filename=$(basename "$file")
    (cd rule/ip && mihomo convert-ruleset ipcidr yaml $filename ${filename%.*}.mrs && mv -if "${filename%.*}.mrs" ../../rule_provider/ && rm -if  $filename) &
done

# json ==>> srs

for file in rule/ip/*.txt; do
    filename=$(basename "$file")
    category=$(echo "$filename" | sed 's/geoip_\(.*\)\.txt/\1/')
    output_file="rule/ip/${category}.json"
    jq -nR '[inputs] | { "version": 1, "rules": [ { "ip_cidr": . } ] }' < $file > $output_file && \
    sing-box rule-set format $output_file -w &
done

for item in "${geositeDomains[@]}"; do
    sing-box geosite export "$item"
done

for item in rule/ip/*.json; do
    CrashCore rule-set compile "$item"
    mv "${item%.json}.srs" rule_provider/
    mv "$item" rule_provider/
done

for item in *.json; do
    filename=$(basename "$item")
    category=$(echo "$filename" | sed 's/geosite-\(.*\)\.*/\1/')
    output_file="rule_provider/${category%.*}.json"
    output_file2="rule_provider/${category%.*}.srs"
    sing-box rule-set compile "$item"
    mv "${item%.json}.srs" $output_file2
    mv "$item" $output_file
done


# rm -f rule/
rm -rf geoip.db geosite.db geoip.dat geosite.dat geosite_categories.list

