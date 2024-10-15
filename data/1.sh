for tool in tools/*; do
    filename=$(basename "$tool")
    command -v $filename &> /dev/null || { cp ./$filename /usr/local/bin/ && chmod +x /usr/local/bin/$filename; }
done

sing-box geoip -h --help > categories
