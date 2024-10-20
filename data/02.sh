echo "Downloading oisd full source list..."
curl -sSf -o rule-umum.abp https://raw.githubusercontent.com/Qerleng/01/main/rule_provider/rule-umum.yaml
python3 - <<EOF
import re
import yaml

with open("rule-umum.abp", "r") as file:
  input_text = file.read()

domains = []
payload_lines2 = re.findall(r"  - (.+)", input_text)
for line in payload_lines2:
  if line:
    domain = line.split("$")[0].strip()
  if any(prefix in domain for prefix in ("#", "payload:" )):
    continue
#  elif any(prefix in domain for prefix in ("[", "/", "*", "^")):
#    domains.append("DOMAIN-REGEX," + domain)
  else:
    domains.append(domain)

payload = [f'{line}' for line in domains]

data = {
  "payload": payload
}

yaml_output = yaml.dump(data, sort_keys=False, default_flow_style=False)

formatted_yaml = re.sub(r"(\s+-) '(.+)'", r"\1 \2", yaml_output)

with open("rule-umum.yaml", "w") as file:
  file.write(formatted_yaml)
EOF
# mv -if oisd-full.txt 
# mv -if rule_basicads.yaml ./Ads/oisd.txt
