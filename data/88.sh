
geoipAddresses=("fastly" "firewall" "geoid" "private" "doh" "malicious" "cloudflare" "cloudfront" "id" "facebook" "google" "netflix" "telegram" "twitter")


for file in rule_provider/"${geoipAddresses[@]}".yaml; do
    filename=$(basename "$file")
    txt_file="${filename%.*}.txt"
    yaml_file="${filename%.*}.yaml"
    mrs_file="${filename%.*}.mrs"
    srs_file="${filename%.*}.srs"
    ars_file="${filename%.*}.ars"
    json_file="${filename%.*}.json"

    rm -if $mrs_file
    rm -if $file
    rm -if $srs_file
    rm -if $json_file

done
