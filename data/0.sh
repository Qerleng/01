echo "Downloading oisd full source list..."
curl -sSf -o AWAvenue.abp https://adguardteam.github.io/HostlistsRegistry/assets/filter_53.txt
python3 - <<EOF
import re
import yaml

with open("AWAvenue.abp", "r") as file:
  input_text = file.read()

domains = []
payload_lines2 = re.findall(r"\|\|(.+)\^", input_text)
payload_lines = re.findall(r"/(.+)/", input_text)
mains = payload_lines + payload_lines2
for line in mains:
  if line:
    domain = line.split("$")[0].strip()
  if any(prefix in domain for prefix in ("#", "!", "@@", "||", "github", "whatsapp")):
    continue
  elif any(prefix in domain for prefix in ("[", "/", "*", "^")):
    domains.append("DOMAIN-REGEX," + domain)
  else:
    domains.append("DOMAIN-SUFFIX," + domain)

payload = [f'{line}' for line in domains]

data = {
  "payload": payload
}

yaml_output = yaml.dump(data, sort_keys=False, default_flow_style=False)

formatted_yaml = re.sub(r"(\s+-) '(.+)'", r"\1 \2", yaml_output)

with open("AWAvenue.yaml", "w") as file:
  file.write(formatted_yaml)
EOF
# mv -if oisd-full.txt 
# mv -if rule_basicads.yaml ./Ads/oisd.txt
