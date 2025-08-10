#!/bin/bash

# SMS Application Deployment Script
# Supports multiple environments: local, staging, production

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
ENVIRONMENT="local"
NAMESPACE="default"
RELEASE_NAME="sms"
CHART_PATH="application/sms/helm-charts/sms-app"
DRY_RUN=false
UPGRADE=false

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -e, --environment ENV    Environment to deploy (local, staging, production) [default: local]"
    echo "  -n, --namespace NS       Kubernetes namespace [default: default]"
    echo "  -r, --release NAME       Helm release name [default: sms]"
    echo "  -u, --upgrade            Upgrade existing release instead of install"
    echo "  --dry-run               Perform a dry run without actually deploying"
    echo "  -h, --help              Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 -e local                    # Deploy to local minikube"
    echo "  $0 -e staging -n sms-staging   # Deploy to EKS staging"
    echo "  $0 -e production -u            # Upgrade production deployment"
    echo "  $0 --dry-run -e production     # Dry run for production"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -e|--environment)
            ENVIRONMENT="$2"
            shift 2
            ;;
        -n|--namespace)
            NAMESPACE="$2"
            shift 2
            ;;
        -r|--release)
            RELEASE_NAME="$2"
            shift 2
            ;;
        -u|--upgrade)
            UPGRADE=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            echo "Unknown option $1"
            show_usage
            exit 1
            ;;
    esac
done

# Validate environment
case $ENVIRONMENT in
    local|staging|production)
        ;;
    *)
        echo -e "${RED}Error: Invalid environment '$ENVIRONMENT'. Must be one of: local, staging, production${NC}"
        exit 1
        ;;
esac

# Set values file based on environment
case $ENVIRONMENT in
    local)
        VALUES_FILE="values-dev.yaml"
        ;;
    staging)
        VALUES_FILE="values-staging.yaml"
        ;;
    production)
        VALUES_FILE="values-eks.yaml"
        ;;
esac

echo -e "${BLUE}🚀 SMS Application Deployment${NC}"
echo "=================================="
echo -e "${YELLOW}Environment:${NC} $ENVIRONMENT"
echo -e "${YELLOW}Namespace:${NC} $NAMESPACE"
echo -e "${YELLOW}Release:${NC} $RELEASE_NAME"
echo -e "${YELLOW}Values File:${NC} $VALUES_FILE"
echo -e "${YELLOW}Action:${NC} $([ "$UPGRADE" = true ] && echo "Upgrade" || echo "Install")"
echo -e "${YELLOW}Dry Run:${NC} $([ "$DRY_RUN" = true ] && echo "Yes" || echo "No")"
echo ""

# Check if values file exists
if [ ! -f "$CHART_PATH/$VALUES_FILE" ]; then
    echo -e "${RED}Error: Values file '$CHART_PATH/$VALUES_FILE' not found${NC}"
    exit 1
fi

# Check if chart directory exists
if [ ! -d "$CHART_PATH" ]; then
    echo -e "${RED}Error: Chart directory '$CHART_PATH' not found${NC}"
    exit 1
fi

# Environment-specific pre-deployment checks
case $ENVIRONMENT in
    local)
        echo -e "${YELLOW}📋 Local Environment Checks${NC}"
        # Check if minikube is running
        if ! minikube status > /dev/null 2>&1; then
            echo -e "${RED}Error: Minikube is not running. Please start minikube first.${NC}"
            exit 1
        fi
        
        # Check if ingress addon is enabled
        if ! minikube addons list | grep -q "ingress.*enabled"; then
            echo -e "${YELLOW}Warning: Ingress addon is not enabled. Enabling it now...${NC}"
            minikube addons enable ingress
        fi
        
        echo -e "${GREEN}✅ Local environment checks passed${NC}"
        ;;
        
    staging|production)
        echo -e "${YELLOW}📋 EKS Environment Checks${NC}"
        
        # Check if kubectl is configured for the right cluster
        CURRENT_CONTEXT=$(kubectl config current-context 2>/dev/null || echo "none")
        echo -e "${YELLOW}Current kubectl context:${NC} $CURRENT_CONTEXT"
        
        # Check if AWS Load Balancer Controller is installed
        if ! kubectl get deployment -n kube-system aws-load-balancer-controller > /dev/null 2>&1; then
            echo -e "${RED}Warning: AWS Load Balancer Controller not found in kube-system namespace${NC}"
            echo -e "${YELLOW}Please ensure AWS Load Balancer Controller is installed for ALB ingress${NC}"
        fi
        
        echo -e "${GREEN}✅ EKS environment checks completed${NC}"
        ;;
esac

# Create namespace if it doesn't exist (except for default)
if [ "$NAMESPACE" != "default" ]; then
    echo -e "${YELLOW}📦 Creating namespace '$NAMESPACE' if it doesn't exist...${NC}"
    kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -
fi

# Build Helm command
HELM_CMD="helm"
if [ "$UPGRADE" = true ]; then
    HELM_CMD="$HELM_CMD upgrade"
else
    HELM_CMD="$HELM_CMD install"
fi

HELM_CMD="$HELM_CMD $RELEASE_NAME $CHART_PATH"
HELM_CMD="$HELM_CMD -f $CHART_PATH/$VALUES_FILE"
HELM_CMD="$HELM_CMD --namespace $NAMESPACE"

if [ "$DRY_RUN" = true ]; then
    HELM_CMD="$HELM_CMD --dry-run --debug"
fi

# Add timeout for production deployments
if [ "$ENVIRONMENT" = "production" ]; then
    HELM_CMD="$HELM_CMD --timeout 10m"
fi

echo -e "${YELLOW}🔧 Executing Helm command:${NC}"
echo "$HELM_CMD"
echo ""

# Execute the deployment
if eval "$HELM_CMD"; then
    if [ "$DRY_RUN" = false ]; then
        echo ""
        echo -e "${GREEN}🎉 Deployment successful!${NC}"
        echo ""
        
        # Show post-deployment information
        case $ENVIRONMENT in
            local)
                echo -e "${BLUE}📋 Post-deployment Information:${NC}"
                echo "• Add '127.0.0.1 sms-app.local' to your /etc/hosts file"
                echo "• Access the application at: http://sms-app.local"
                echo ""
                echo -e "${YELLOW}🔍 Useful commands:${NC}"
                echo "• Check pods: kubectl get pods -n $NAMESPACE"
                echo "• Check ingress: kubectl get ingress -n $NAMESPACE"
                echo "• View logs: kubectl logs -f deployment/$RELEASE_NAME-frontend -n $NAMESPACE"
                ;;
                
            staging)
                echo -e "${BLUE}📋 Post-deployment Information:${NC}"
                echo "• Application will be available at: https://staging-sms.yourdomain.com"
                echo "• Check ALB creation in AWS Console"
                echo ""
                echo -e "${YELLOW}🔍 Useful commands:${NC}"
                echo "• Check pods: kubectl get pods -n $NAMESPACE"
                echo "• Check ingress: kubectl get ingress -n $NAMESPACE"
                echo "• Describe ingress: kubectl describe ingress $RELEASE_NAME-sms-app-ingress -n $NAMESPACE"
                ;;
                
            production)
                echo -e "${BLUE}📋 Post-deployment Information:${NC}"
                echo "• Application will be available at: https://sms.yourdomain.com"
                echo "• Monitor ALB health checks in AWS Console"
                echo "• Check CloudWatch logs for application metrics"
                echo ""
                echo -e "${YELLOW}🔍 Useful commands:${NC}"
                echo "• Check pods: kubectl get pods -n $NAMESPACE"
                echo "• Check HPA: kubectl get hpa -n $NAMESPACE"
                echo "• View ingress: kubectl describe ingress $RELEASE_NAME-sms-app-ingress -n $NAMESPACE"
                ;;
        esac
    else
        echo -e "${GREEN}✅ Dry run completed successfully${NC}"
    fi
else
    echo -e "${RED}❌ Deployment failed${NC}"
    exit 1
fi