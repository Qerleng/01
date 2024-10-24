
geoipAddresses=("firewall" "geoid" "private" "malicious" "id" "google" "netflix" "telegram" "twitter")


for file in rule_provider/${geoipAddresses[@]}; do
    filename=$(basename "$file")
    txt_file="${filename%.*}.txt"
    yaml_file="${filename%.*}.yaml"
    mrs_file="${filename%.*}.mrs"
    srs_file="${filename%.*}.srs"
    ars_file="${filename%.*}.ars"
    json_file="${filename%.*}.json"

    rm -rf $mrs_file
    rm -rf $yaml_file
    rm -rf $srs_file
    rm -rf $json_file

done
