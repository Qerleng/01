curl -LO https://github.com/Qerleng/01/raw/main/tools/sing-box
curl -Lo geip.db "https://github.com/rfxcll/v2ray-rules-dat/releases/latest/download/GeoIP.db"

chmod +x ./sing-box
chmod +x ./geip.db

./sing-box geoip --help > categories
./sing-box geoip list -f .geip.db > geoip_categories

rm -f sing-box geip.db
