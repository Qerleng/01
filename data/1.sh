curl -LO https://github.com/Qerleng/01/raw/main/tools/sing-box

./sing-box geoip [command] --help | awk '{print}' | sort > categories

rm -f sing-box
