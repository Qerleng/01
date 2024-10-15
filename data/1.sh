curl -LO https://github.com/Qerleng/01/raw/main/tools/sing-box
curl -LO https://github.com/Qerleng/01/raw/main/tools/mihomo
curl -LO https://github.com/Qerleng/01/raw/main/tools/v2dat



chmod +x ./sing-box
chmod +x ./mihomo
chmod +x ./v2dat

mkdir -p help

./sing-box convert --help > help/categories
./mihomo  --help > help/categories1
./v2dat  --help > help/categories2


rm -f sing-box mihomo v2dat
