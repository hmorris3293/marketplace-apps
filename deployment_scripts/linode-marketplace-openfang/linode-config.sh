#!/bin/bash
#
# OpenFang Marketplace App Deployment Script
# Automates the deployment of OpenFang Agent OS on Linode instances
#
# UDF Configuration:
# <UDF name="domain" label="Domain Name" description="Domain for SSL certificate and access">
# <UDF name="username" label="System User" description="Username for openfang application" default="openfang">
# <UDF name="openai_api_key" label="OpenAI API Key (Optional)" default="">
# <UDF name="anthropic_api_key" label="Anthropic API Key (Optional)" default="">
# <UDF name="loglevel" label="Log Level" oneOf="debug,info,warn,error" default="info">

set -e
set -o pipefail

# Enable debugging output (send to /dev/ttyS0 and logfile)
exec > >(tee /dev/ttyS0 /var/log/stackscript.log)
exec 2>&1

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
MARKETPLACE_APP="linode-marketplace-openfang"
GITHUB_USER="${GH_USER:-RightNow-AI}"
GITHUB_BRANCH="${GH_BRANCH:-main}"
GITHUB_REPO="${GITHUB_REPO:-openfang}"
WORK_DIR="/opt/linode"
REPO_DIR="${WORK_DIR}/${MARKETPLACE_APP}"

# Functions
print_header() {
    echo -e "${GREEN}=== $1 ===${NC}"
}

print_error() {
    echo -e "${RED}ERROR: $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}WARNING: $1${NC}"
}

cleanup() {
    EXIT_CODE=$?
    if [ $EXIT_CODE -ne 0 ]; then
        print_error "Deployment failed with exit code $EXIT_CODE"
    else
        print_header "Deployment completed successfully!"
    fi
    exit $EXIT_CODE
}

trap cleanup EXIT

# Ensure running as root
if [[ $EUID -ne 0 ]]; then
    print_error "This script must be run as root"
    exit 1
fi

print_header "OpenFang Marketplace App Deployment"
echo "Domain: $DOMAIN"
echo "Username: $USERNAME"
echo "Log Level: $LOGLEVEL"

# Update system packages
print_header "Updating system packages"
apt-get update
apt-get upgrade -y
apt-get install -y git curl wget python3 python3-pip python3-venv

# Create work directory
print_header "Setting up directories"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

# Clone or update repository
if [ ! -d "$REPO_DIR" ]; then
    print_header "Cloning marketplace app repository"
    git clone --depth 1 -b "${GITHUB_BRANCH}" \
        "https://github.com/${GITHUB_USER}/${MARKETPLACE_APP}.git" \
        "$REPO_DIR"
else
    print_header "Updating marketplace app repository"
    cd "$REPO_DIR"
    git pull origin "${GITHUB_BRANCH}"
fi

cd "$REPO_DIR"

# Create Python virtual environment
print_header "Setting up Python virtual environment"
python3 -m venv /opt/venv
source /opt/venv/bin/activate

# Install Python dependencies
print_header "Installing Python dependencies"
pip install --upgrade pip
pip install -q -r requirements.txt
ansible-galaxy collection install -q -r collections.yml

# Prepare group_vars directory
print_header "Preparing Ansible variables"
mkdir -p group_vars/linode
group_vars_file="group_vars/linode/vars"

# Generate secure credentials
OPENFANG_API_KEY=$(python3 -c "import secrets; print(secrets.token_urlsafe(32))")
OPENFANG_DB_PASSWORD=$(python3 -c "import secrets; print(secrets.token_urlsafe(32))")

# Create group_vars file
cat > "$group_vars_file" <<EOF
---
app_name: openfang
app_user: "$USERNAME"
app_home: "/home/$USERNAME/openfang"
app_data_dir: "/home/$USERNAME/openfang_data"
openfang_version: "0.6.9"
openfang_api_key: "$OPENFANG_API_KEY"
openfang_api_port: 4200
openfang_domain: "$DOMAIN"
openfang_enable_ssl: true
openfang_default_provider: "openai"
openfang_default_model: "gpt-4-turbo"
openfang_db_password: "$OPENFANG_DB_PASSWORD"
loglevel: "$LOGLEVEL"
EOF

# Set environment variables for LLM providers if provided
print_header "Configuring LLM providers"
if [ -n "$OPENAI_API_KEY" ]; then
    export OPENAI_API_KEY="$OPENAI_API_KEY"
    echo "  - OpenAI API key configured"
fi

if [ -n "$ANTHROPIC_API_KEY" ]; then
    export ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY"
    echo "  - Anthropic API key configured"
fi

# Run Ansible deployment
print_header "Running Ansible playbooks"

# Provision phase (generate credentials)
print_header "Provision Phase"
ansible-playbook -i localhost, -c local provision.yml \
    -e "domain=$DOMAIN" \
    -e "username=$USERNAME" \
    || {
        print_error "Provision playbook failed"
        exit 1
    }

# Main deployment phase
print_header "Deployment Phase"
ansible-playbook -i localhost, -c local site.yml \
    || {
        print_error "Site playbook failed"
        exit 1
    }

# Verify deployment
print_header "Verifying deployment"

# Check if container is running
if docker ps | grep -q openfang; then
    print_header "OpenFang container is running"
else
    print_error "OpenFang container is not running"
    docker logs openfang
    exit 1
fi

# Check API response
sleep 5
if curl -s -f -H "Authorization: Bearer $OPENFANG_API_KEY" http://127.0.0.1:4200/health > /dev/null; then
    print_header "OpenFang API is responding"
else
    print_warning "Could not verify API response (may be initializing)"
fi

# Display completion information
print_header "Deployment Information"
echo ""
echo "Dashboard URL: https://$DOMAIN/"
echo "API Endpoint: https://$DOMAIN/v1/"
echo "API Bearer Token: $OPENFANG_API_KEY"
echo ""
echo "Credentials file: /home/$USERNAME/.credentials"
echo "Configuration: /home/$USERNAME/openfang_data/config.toml"
echo ""
echo "Next steps:"
echo "1. Set up LLM provider credentials in the config file"
echo "2. Access the dashboard and create your first agent"
echo "3. Configure channel adapters (Telegram, Discord, etc.)"
echo ""
echo "For more information, visit: https://openfang.sh/docs/"
echo ""

# Save Ansible facts for future reference
print_header "Saving deployment information"
mkdir -p /opt/linode/deployment-info
cat > /opt/linode/deployment-info/credentials.txt <<EOF
OpenFang Deployment Credentials
Generated: $(date)

Dashboard: https://$DOMAIN/
API Key: $OPENFANG_API_KEY
System User: $USERNAME
Application Directory: /home/$USERNAME/openfang
Data Directory: /home/$USERNAME/openfang_data

Database Password: $OPENFANG_DB_PASSWORD

To retrieve credentials later:
cat /home/$USERNAME/.credentials
EOF

chmod 600 /opt/linode/deployment-info/credentials.txt

print_header "Deployment complete!"
exit 0
