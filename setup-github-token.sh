#!/bin/bash
# Script to set up GitHub token for the talentradar-config-server-rw repository
# This script requires GitHub CLI (gh) to be installed and authenticated

set -e

# Repository name
REPO="AmaliTech-Training-Academy/talentradar-config-server-rw"

# Check if gh is installed
if ! command -v gh &> /dev/null; then
    echo "GitHub CLI (gh) is not installed. Please install it first."
    echo "Installation instructions: https://cli.github.com/manual/installation"
    exit 1
fi

# Check if authenticated
if ! gh auth status &> /dev/null; then
    echo "Please authenticate with GitHub CLI first by running 'gh auth login'"
    exit 1
fi

echo "Setting up GitHub token for $REPO"

# Ask for the GitHub token
read -p "Enter your GitHub Personal Access Token (will not be displayed): " -s GITHUB_TOKEN
echo ""
if [ -z "$GITHUB_TOKEN" ]; then
    echo "GitHub token is required"
    exit 1
fi

# Set repository secret
echo "Setting GITHUB_TOKEN secret..."
gh secret set GITHUB_TOKEN --repo $REPO --body "$GITHUB_TOKEN"

echo ""
echo "GitHub token set successfully for $REPO"
echo ""
echo "Make sure your token has the following permissions:"
echo "- repo (all repository permissions) - if accessing private repos"
echo "- public_repo - if accessing only public repos"
echo ""
echo "The token will be used by the config server to access the configuration repository."

exit 0
