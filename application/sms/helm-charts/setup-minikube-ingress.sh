#!/bin/bash

# Minikube Ingress Setup Script for SMS Application

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}Setting up Minikube Ingress for SMS Application...${NC}"

# Check if minikube is running
if ! minikube status >/dev/null 2>&1; then
    echo -e "${RED}Minikube is not running. Please start minikube first:${NC}"
    echo "minikube start"
    exit 1
fi

echo -e "${GREEN}✓ Minikube is running${NC}"

# Enable ingress addon
echo -e "${YELLOW}Enabling ingress addon...${NC}"
minikube addons enable ingress

# Wait for ingress controller to be ready
echo -e "${YELLOW}Waiting for ingress controller to be ready...${NC}"
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=300s

echo -e "${GREEN}✓ Ingress controller is ready${NC}"

# Get minikube IP
MINIKUBE_IP=$(minikube ip)
echo -e "${BLUE}Minikube IP: $MINIKUBE_IP${NC}"

# Check if hosts entry exists
HOSTS_ENTRY="$MINIKUBE_IP sms-app.local"
if grep -q "sms-app.local" /etc/hosts; then
    echo -e "${YELLOW}Hosts entry already exists. You may need to update it manually:${NC}"
    echo "Current entry:"
    grep "sms-app.local" /etc/hosts
    echo ""
    echo -e "${YELLOW}Expected entry:${NC}"
    echo "$HOSTS_ENTRY"
else
    echo -e "${YELLOW}Adding hosts entry...${NC}"
    echo "You need to add the following line to your /etc/hosts file:"
    echo "$HOSTS_ENTRY"
    echo ""
    echo "Run this command:"
    echo "echo '$HOSTS_ENTRY' | sudo tee -a /etc/hosts"
fi

echo ""
echo -e "${GREEN}Minikube ingress setup completed!${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "1. Deploy the SMS application: ./deploy-all.sh"
echo "2. Add hosts entry: echo '$HOSTS_ENTRY' | sudo tee -a /etc/hosts"
echo "3. Access the application: http://sms-app.local"
echo ""
echo -e "${BLUE}Useful commands:${NC}"
echo "Check ingress status: kubectl get ingress -n sms-app"
echo "Check ingress controller: kubectl get pods -n ingress-nginx"
echo "Minikube dashboard: minikube dashboard"