#!/bin/bash

# validate-aib-template.sh
# Script to validate Azure VM Image Builder template files

set -euo pipefail

# Default values
TEMPLATE_FILE=""
TEMPLATE_TYPE=""

# Parse arguments
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    --template-file)
      TEMPLATE_FILE="$2"
      shift 2
      ;;
    --template-type)
      TEMPLATE_TYPE="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Check required arguments
if [[ -z "$TEMPLATE_FILE" ]]; then
  echo "Error: Missing required argument --template-file"
  exit 1
fi

if [[ -z "$TEMPLATE_TYPE" ]]; then
  echo "Error: Missing required argument --template-type"
  exit 1
fi

# Check if template file exists
if [[ ! -f "$TEMPLATE_FILE" ]]; then
  echo "❌ Template file not found: $TEMPLATE_FILE"
  exit 1
fi

# Validate template file
echo "Validating template file: $TEMPLATE_FILE"

# First validate JSON syntax
echo "Validating JSON syntax..."
cat "$TEMPLATE_FILE" | jq . >/dev/null || {
  echo "❌ Invalid JSON syntax in template file!"
  exit 1
}

echo "✅ JSON syntax validation passed"

# Additional validations based on template type
if [[ "$TEMPLATE_TYPE" == "imageTemplate" ]]; then
  # Validate source type
  SOURCE_TYPE=$(jq -r '.properties.source.type' "$TEMPLATE_FILE")
  if [[ -z "$SOURCE_TYPE" || "$SOURCE_TYPE" == "null" ]]; then
    echo "❌ Missing or invalid source type in template!"
    exit 1
  fi
  echo "✅ Source type validation passed: $SOURCE_TYPE"
  
  # Validate distribute array
  DISTRIBUTE_COUNT=$(jq '.properties.distribute | length' "$TEMPLATE_FILE")
  if [[ "$DISTRIBUTE_COUNT" -lt 1 ]]; then
    echo "❌ Template must have at least one distribute target!"
    exit 1
  fi
  echo "✅ Distribute array validation passed: $DISTRIBUTE_COUNT target(s)"

  # Validate customizer array (if exists)
  if jq -e '.properties.customize' "$TEMPLATE_FILE" > /dev/null; then
    CUSTOMIZE_COUNT=$(jq '.properties.customize | length' "$TEMPLATE_FILE")
    echo "✅ Customize array validation passed: $CUSTOMIZE_COUNT customizer(s)"
  else
    echo "⚠️ No customizers found in template"
  fi
elif [[ "$TEMPLATE_TYPE" == "armTemplate" ]]; then
  # Validate ARM template structure
  if ! jq -e '.resources' "$TEMPLATE_FILE" > /dev/null; then
    echo "❌ Invalid ARM template: missing 'resources' section!"
    exit 1
  fi
  
  # Check for imageTemplate resource
  if ! jq -e '.resources[] | select(.type == "Microsoft.VirtualMachineImages/imageTemplates")' "$TEMPLATE_FILE" > /dev/null; then
    echo "❌ Invalid ARM template: no imageTemplate resource found!"
    exit 1
  fi
  echo "✅ ARM template structure validation passed"
else
  echo "❌ Invalid template type: $TEMPLATE_TYPE (must be 'imageTemplate' or 'armTemplate')"
  exit 1
fi

echo "✅ Template validation successful!"
exit 0
