#!/bin/bash
set -e

# This script validates Azure Image Builder templates (.json files)
# It checks for basic JSON syntax and the required structure for AIB templates

TEMPLATE_FILE=$1
echo "Validating template: $TEMPLATE_FILE"

# Check if file exists
if [ ! -f "$TEMPLATE_FILE" ]; then
  echo "❌ Template file not found: $TEMPLATE_FILE"
  exit 1
fi

# Validate JSON syntax
echo "Validating JSON syntax..."
cat "$TEMPLATE_FILE" | jq . >/dev/null || {
  echo "❌ Invalid JSON syntax in template file!"
  exit 1
}
echo "✅ JSON syntax is valid"

# Validate resource type
echo "Validating Image Builder template structure..."
TYPE=$(jq -r '.type // empty' "$TEMPLATE_FILE")
if [[ "$TYPE" != "Microsoft.VirtualMachineImages/imageTemplates" ]]; then
  echo "❌ Template type must be 'Microsoft.VirtualMachineImages/imageTemplates', found: '$TYPE'"
  exit 1
fi

# Check for required properties
echo "Checking required properties..."
jq -e '.properties.source' "$TEMPLATE_FILE" >/dev/null || {
  echo "❌ Missing required 'properties.source' section in template!"
  exit 1
}

jq -e '.properties.customize' "$TEMPLATE_FILE" >/dev/null || {
  echo "❌ Missing required 'properties.customize' section in template!"
  exit 1
}

jq -e '.properties.distribute' "$TEMPLATE_FILE" >/dev/null || {
  echo "❌ Missing required 'properties.distribute' section in template!"
  exit 1
}

# Validate source type
SOURCE_TYPE=$(jq -r '.properties.source.type // empty' "$TEMPLATE_FILE")
if [[ -z "$SOURCE_TYPE" ]]; then
  echo "❌ Missing required 'properties.source.type' property!"
  exit 1
fi

# Validate distribute array is not empty
DIST_COUNT=$(jq '.properties.distribute | length' "$TEMPLATE_FILE")
if [[ "$DIST_COUNT" -lt 1 ]]; then
  echo "❌ The 'properties.distribute' array must contain at least one item!"
  exit 1
fi

echo "✅ Image Builder template structure is valid"
exit 0
