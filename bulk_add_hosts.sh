INV_ID=8
USER="aapadmin"
PASS="UWC@(xru5"


HOST="192.168.65.216"

while IFS=',' read -r name desc vars; do
  # Start building JSON
  json="{\"name\": \"$name\""

  # Add description if not empty
  [[ -n "$desc" ]] && json+=", \"description\": \"$desc\""

  # Add variables if not empty, convert & to newlines for YAML
  if [[ -n "$vars" ]]; then
    vars_yaml=$(echo "$vars" | sed 's/&/\\n/g' | sed 's/=/\: /g')
    json+=", \"variables\": \"$vars_yaml\""
  fi

  json+="}"

  # Send request
  curl -k -s -u "$USER:$PASS" -X POST https://$HOST/api/controller/v2/inventories/$INV_ID/hosts/ \
    -H "Content-Type: application/json" \
    -d "$json" \
    | jq '.'

done < hosts_list.csv
