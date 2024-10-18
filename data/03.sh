#!/bin/bash

transform_rules() {
    jq -nR '{
        version: 1,
        rules: [
            reduce (inputs | sub("^ *- *"; "") | select(length > 0) | split(",")) as $item ({};
                if $item[0] == "DOMAIN-SUFFIX" then
                    .domain_suffix += [$item[1]]
                elif $item[0] == "DOMAIN-KEYWORD" then
                    .domain_keyword += [$item[1]]
                elif $item[0] == "DOMAIN-REGEX" then
                    .domain_regex += [$item[1]]
                elif $item[0] == "DOMAIN" then
                    .domain += [$item[1]]
                else
                    .
                end
            )
        ]
    }' "$input_file" > "$output_file"
}

if [ $# -lt 1 ]; then
    echo "Usage: $0 <input_yaml_file1> <input_yaml_file2> ..."
    exit 1
fi

for input_file in "$@"; do
    [ ! -f "$input_file" ] && { echo "File not found: $input_file"; return 1; }

    output_file="${input_file%.yaml}.json"
    transform_rules && \
    sing-box rule-set format "$output_file" -w && \
    echo "$input_file ==>> $output_file"
done
