curl -LO https://github.com/Qerleng/01/raw/main/tools/sing-box
curl -Lo geoip.db "https://github.com/rfxcll/v2ray-rules-dat/releases/latest/download/GeoIP.db"

chmod +x ./sing-box

./sing-box tools --help > categories
./sing-box geoip list | awk '{print $1}' | sort > geoip_categories

rm -f sing-box geoip.db
