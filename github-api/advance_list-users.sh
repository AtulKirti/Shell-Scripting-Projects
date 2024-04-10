#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# GitHub API URL
API_URL="https://api.github.com"

# Function to make a GET request to the GitHub API
function github_api_get {
    local endpoint="$1"
    local url="${API_URL}/${endpoint}"

    # Send a GET request to the GitHub API with authentication
    curl -s -u "${USERNAME}:${TOKEN}" "$url"
}

# Function to list users with read access to the repository
function list_users_with_read_access {
    local endpoint="repos/${REPO_OWNER}/${REPO_NAME}/collaborators"
    local page=1

    echo -e "${YELLOW}Listing users with read access to ${REPO_OWNER}/${REPO_NAME}...${NC}"
    echo -e "${GREEN}---------------------------------------------${NC}"

    while true; do
        # Fetch the list of collaborators on the repository
        collaborators="$(github_api_get "${endpoint}?per_page=100&page=${page}" | jq -r '.[] | select(.permissions.pull == true) | .login')"
        
        # Check if there are no more collaborators
        if [ -z "$collaborators" ]; then
            break
        fi
        
        # Output the list of collaborators with read access
        echo -e "${GREEN}Page ${page}:${NC}"
        echo "$collaborators"
        
        ((page++))
    done

    echo -e "${GREEN}---------------------------------------------${NC}"
}

# Main script

# Check if GitHub username and token are provided
if [[ -z "$USERNAME" || -z "$TOKEN" ]]; then
    echo -e "${RED}GitHub username and token are required.${NC}"
    exit 1
fi

# Check if repository owner and name are provided
if [[ -z "$1" || -z "$2" ]]; then
    echo -e "${RED}Repository owner and name are required.${NC}"
    exit 1
fi

USERNAME=$1
TOKEN=$2
REPO_OWNER=$3
REPO_NAME=$4

list_users_with_read_access
