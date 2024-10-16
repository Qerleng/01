echo "Downloading oisd full source list..."
curl -sSf -o oisd-full.txt https://adguardteam.github.io/HostlistsRegistry/assets/filter_53.txt
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
    
payload = [f'"{line}"' for line in domains]

data = {
  "payload": payload
}

yaml_output = yaml.dump(data, sort_keys=False, default_flow_style=False)

formatted_yaml = re.sub(r"(\s+-) '(.+)'", r"\1 \2", yaml_output)

with open("rule_basicads.yaml", "w") as file:
  file.write(formatted_yaml)
EOF
# mv -if oisd-full.txt 
# mv -if rule_basicads.yaml ./Ads/oisd.txt
