#!/bin/bash

set -e -o pipefail


curl -Lo geoip.db "https://github.com/malikshi/v2ray-rules-dat/releases/latest/download/GeoIP.db"
curl -Lo geosite.db "https://github.com/malikshi/v2ray-rules-dat/releases/latest/download/GeoSite.db"
curl -Lo geoip.dat "https://github.com/malikshi/v2ray-rules-dat/releases/latest/download/GeoIP.dat"
curl -Lo geosite.dat "https://github.com/malikshi/v2ray-rules-dat/releases/latest/download/GeoSite.dat"

for tool in tools/*; do
    filename=$(basename "$tool")
    command -v $filename &> /dev/null || { cp ./$filename /usr/local/bin/ && chmod +x /usr/local/bin/$filename; }
done

mkdir -p original

sing-box geosite list private -f db/geosite.db | awk '{print $1}' | sort > geosite_categories.list
while IFS= read -r category; do
    v2dat unpack geosite -o "original/geosite" -f "$category" "db/geosite.dat" &
done < geosite_categories.list
wait

sing-box geoip list -f db/geoip.db | awk '{print $1}' | sort > geoip_categories.list
while IFS= read -r category; do
    v2dat unpack geoip -o "original/geoip" -f "$category" "db/geoip.dat" &
done < geoip_categories.list
wait


rm -rf geoip.db geosite.db geoip.dat geosite.dat
