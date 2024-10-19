echo "Downloading oisd full source list..."
curl -sSf -o rule-sosmed.abp https://raw.githubusercontent.com/Qerleng/01/main/rule_provider/rule-sosmed.yaml
python3 - <<EOF
import re
import yaml

with open("rule-sosmed.abp", "r") as file:
  input_text = file.read()

domains = []
payload_lines2 = re.findall(r"  - DOMAIN-SUFFIX,|(.+)", input_text)
payload_lines = re.findall(r"  - DOMAIN,|(.+)", input_text)
payload_lines1 = re.findall(r"  - DOMAIN-REGEX,|(.+)", input_text)
mains = payload_lines + payload_lines1 + payload_lines2
for line in mains:
  if line:
    domain = line.split("$")[0].strip()
  if any(prefix in domain for prefix in ("#", "!", "@@", "tt", "video", "ttwstatic.com", "tiktok", "tik", "muscdn.com", "musical.ly", "fbcdn", "byteoversea", "wa", "whatsapp")):
    continue
#  elif any(prefix in domain for prefix in ("[", "/", "*", "^")):
    domains.append("DOMAIN-REGEX," + domain)
  else:
    domains.append(domain)

payload = [f'{line}' for line in domains]

data = {
  "payload": payload
}

yaml_output = yaml.dump(data, sort_keys=False, default_flow_style=False)

formatted_yaml = re.sub(r"(\s+-) '(.+)'", r"\1 \2", yaml_output)

with open("rule-sosmed.yaml", "w") as file:
  file.write(formatted_yaml)
EOF
# mv -if oisd-full.txt 
# mv -if rule_basicads.yaml ./Ads/oisd.txt
