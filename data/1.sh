curl -LO https://github.com/Qerleng/01/raw/main/tools/sing-box

chmod +x ./sing-box

./sing-box geoip -f --help > categories

rm -f sing-box
