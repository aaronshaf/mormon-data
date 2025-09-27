#!/bin/bash

# validate.sh - Validate all JSON files in the repository

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅${NC} $1"
}

print_error() {
    echo -e "${RED}❌${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠️${NC} $1"
}

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    print_error "jq is not installed. Please install jq to validate JSON files."
    echo "Install with: brew install jq (macOS) or apt-get install jq (Ubuntu)"
    exit 1
fi

# Find all JSON files in the repository
json_files=$(find . -name "*.json" -not -path "./node_modules/*" -not -path "./.git/*" | sort)

if [ -z "$json_files" ]; then
    print_warning "No JSON files found in the repository."
    exit 0
fi

echo "Validating JSON files..."
echo

# Count total files
total_files=$(echo "$json_files" | wc -l | tr -d ' ')
valid_files=0
invalid_files=0

# Validate each JSON file
for file in $json_files; do
    if jq empty "$file" 2>/dev/null; then
        print_status "$file"
        ((valid_files++))
    else
        print_error "$file"
        echo "   Error details:"
        jq empty "$file" 2>&1 | sed 's/^/   /'
        echo
        ((invalid_files++))
    fi
done

echo
echo "Validation Summary:"
echo "==================="
echo "Total files checked: $total_files"
echo -e "Valid files: ${GREEN}$valid_files${NC}"

if [ $invalid_files -gt 0 ]; then
    echo -e "Invalid files: ${RED}$invalid_files${NC}"
    echo
    print_error "JSON validation failed. Please fix the invalid files before committing."
    exit 1
else
    echo -e "Invalid files: ${GREEN}0${NC}"
    echo
    print_status "All JSON files are valid!"
    exit 0
fi