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

v2dat unpack geoip -h

if [ $? -eq 0 ];then
    echo "[NOTICE] get geoip.dat successfully!"
    v2dat unpack geoip -o ./original "geoip.dat"
else
    echo "get geoip.dat failed! please check your network!"
    exit 1
fi

rm -rf geoip.db geosite.db geoip.dat geosite.dat
