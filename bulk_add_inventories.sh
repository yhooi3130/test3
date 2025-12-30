ORG_ID=2
USER="aapadmin"
PASS="UWC@(xru5"
HOST="192.168.65.216"

while IFS=',' read -r inv desc; do
  # Trim whitespace
  inv=$(echo "$inv" | xargs)
  desc=$(echo "$desc" | xargs)

  # Skip if no name
  [[ -z "$inv" ]] && continue

  echo "🔍 Checking if inventory '$inv' exists in org $ORG_ID ..."

  # Check if inventory already exists
  COUNT=$(curl -k -s -u "$USER:$PASS" \
    "https://$HOST/api/controller/v2/inventories/?name=$inv&organization=$ORG_ID" \
    | jq -r '.count')

  if [[ "$COUNT" -gt 0 ]]; then
    echo "✅ Inventory '$inv' already exists. Skipping."
    continue
  fi

  # Build JSON dynamically
  if [[ -n "$desc" ]]; then
    DATA=$(jq -n --arg name "$inv" --arg org "$ORG_ID" --arg desc "$desc" \
      '{name: $name, organization: ($org|tonumber), description: $desc}')
  else
    DATA=$(jq -n --arg name "$inv" --arg org "$ORG_ID" \
      '{name: $name, organization: ($org|tonumber)}')
  fi

  echo "➕ Creating inventory '$inv' ..."
  curl -k -s -u "$USER:$PASS" -X POST "https://$HOST/api/controller/v2/inventories/" \
    -H "Content-Type: application/json" \
    -d "$DATA" | jq '.'
done < inventories.csv
