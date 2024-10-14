echo "Downloading oisd full source list..."
curl -sSf -o oisd-full.txt https://big.oisd.nl/
python3 - <<EOF
import re
import yaml

with open("oisd-full.txt", "r") as file:
  input_text = file.read()

payload_lines = re.findall(r"\|\|(.+)\^", input_text)
domains = []
for line in payload_lines:
  if line:
    domain = line.split("$")[0].strip()
  if any(prefix in domain for prefix in ("autodesk", "github", "tiktok", "pinterest", "pinimg", "twitter", "linkedin", "telegram", "facebook", "line", "instagram", "whatsapp")):
    continue
  else:
    domains.append("DOMAIN-SUFFIX," + domain)
    
payload = [f'"+.{line}"' for line in payload_lines]

data = {
  "payload": payload
}

yaml_output = yaml.dump(data, sort_keys=False, default_flow_style=False)

formatted_yaml = re.sub(r"(\s+  -) '(.+)'", r"\1 \2", yaml_output)

with open("rule_basicads.yaml", "w") as file:
  file.write(formatted_yaml)
EOF
rm oisd-full.txt

echo "Downloading oisd nsfw source list..."
curl -sSf -o oisd-nsfw.txt https://nsfw.oisd.nl
python3 - <<EOF
import re
import yaml

with open("oisd-nsfw.txt", "r") as file:
  input_text = file.read()

payload_lines = re.findall(r"\|\|(.+)\^", input_text)
payload = [f'"+.{line}"' for line in payload_lines]

data = {
  "payload": payload
}

yaml_output = yaml.dump(data, sort_keys=False, default_flow_style=False)

formatted_yaml = re.sub(r"(\s+-) '(.+)'", r"\1 \2", yaml_output)

with open("rule_nsfw.yaml", "w") as file:
  file.write(formatted_yaml)
EOF
rm oisd-nsfw.txt


echo "Downloading Malicious Sites source list..."
curl -sSf -o rule-malicious.txt https://raw.githubusercontent.com/elliotwutingfeng/Inversion-DNSBL-Blocklists/main/Google_hostnames_ABP.txt
python3 - <<EOF
import re
import yaml

with open("rule-malicious.txt", "r") as file:
  input_text = file.read()

payload_lines = re.findall(r"\|\|(.+)\^", input_text)
payload = [f'"+.{line}"' for line in payload_lines]

data = {
  "payload": payload
}

yaml_output = yaml.dump(data, sort_keys=False, default_flow_style=False)

formatted_yaml = re.sub(r"(\s+-) '(.+)'", r"\1 \2", yaml_output)

with open("rule_malicious.yaml", "w") as file:
  file.write(formatted_yaml)
EOF
rm rule-malicious.txt

echo "Downloading Malicious IP Addresses source list..."
curl -s https://raw.githubusercontent.com/elliotwutingfeng/Inversion-DNSBL-Blocklists/main/Google_ipv4.txt -o rule_maliciousip.yaml
(echo "#payload:" && cat rule_maliciousip.yaml) > rule_maliciousip.tmp
mv rule_maliciousip.tmp rule_maliciousip.yaml
#start word
sed -ie "/^#/! s/^/- '/" rule_maliciousip.yaml
#end word
sed -ie "/^#/! s/$/\/32'/" rule_maliciousip.yaml
sed -i 's|#payload:|payload:|' rule_maliciousip.yaml
rm -fr rule_maliciousip.yamle
