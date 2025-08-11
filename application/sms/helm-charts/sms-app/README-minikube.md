# SMS App - Minikube Deployment Guide

This guide helps you deploy the SMS application on a local Minikube cluster for development.

## Prerequisites

1. **Install Minikube**
   ```bash
   # macOS
   brew install minikube
   
   # Or download from https://minikube.sigs.k8s.io/docs/start/
   ```

2. **Start Minikube**
   ```bash
   minikube start --memory=4096 --cpus=2
   ```

3. **Enable Ingress Addon**
   ```bash
   minikube addons enable ingress
   ```

4. **Add Local DNS Entry**
   ```bash
   echo "127.0.0.1 sms-app.local" | sudo tee -a /etc/hosts
   ```

## Deployment Steps

1. **Navigate to the helm chart directory**
   ```bash
   cd terraform-eks-karpenter/application/sms/helm-charts/sms-app
   ```

2. **Update Helm dependencies** (if using umbrella chart)
   ```bash
   helm dependency update
   ```

3. **Deploy the application**
   ```bash
   helm install sms-app . -f values-dev.yaml
   ```

4. **Check deployment status**
   ```bash
   kubectl get pods
   kubectl get ingress
   ```

5. **Get Minikube IP and setup port forwarding**
   ```bash
   # Get minikube IP
   minikube ip
   
   # Or use tunnel for ingress
   minikube tunnel
   ```

## Access the Application

Once deployed, you can access the application at:
- **Frontend**: http://sms-app.local

## Configuration Details

The `values-dev.yaml` file configures the application for local development:

### Frontend Configuration
- **Replicas**: 1 (single instance)
- **Ingress**: Uses nginx ingress controller
- **Resources**: Minimal CPU/memory for local development
- **Domain**: sms-app.local

### MongoDB Configuration
- **Replicas**: 1 (single instance)
- **Authentication**: Simple username/password (admin/password123)
- **Storage**: 1Gi persistent volume
- **AWS Features**: Disabled (no Secrets Manager, no IAM roles)
- **Health Checks**: Disabled for faster startup

## Useful Commands

```bash
# Check pod logs
kubectl logs -f deployment/sms-app-frontend
kubectl logs -f statefulset/sms-app-mongodb

# Port forward to services directly
kubectl port-forward svc/sms-app-frontend 8080:80
kubectl port-forward svc/sms-app-mongodb 27017:27017

# Connect to MongoDB
kubectl exec -it sms-app-mongodb-0 -- mongo -u admin -p password123

# Uninstall the application
helm uninstall sms-app

# Clean up
minikube delete
```

## Troubleshooting

1. **Ingress not working**
   - Ensure ingress addon is enabled: `minikube addons list`
   - Check if minikube tunnel is running: `minikube tunnel`

2. **Pods not starting**
   - Check resource constraints: `kubectl describe pod <pod-name>`
   - Increase minikube resources: `minikube start --memory=6144 --cpus=3`

3. **DNS resolution issues**
   - Verify /etc/hosts entry: `cat /etc/hosts | grep sms-app.local`
   - Use minikube IP directly: `curl http://$(minikube ip)/`

4. **MongoDB connection issues**
   - Check if MongoDB pod is ready: `kubectl get pods`
   - Verify credentials in secret: `kubectl get secret sms-app-mongodb-auth -o yaml`

## Development Workflow

1. Make changes to your application code
2. Build new Docker images
3. Update image tags in values-dev.yaml
4. Upgrade the helm release:
   ```bash
   helm upgrade sms-app . -f values-dev.yaml
   ```

This setup provides a lightweight, local development environment that mirrors your production setup without AWS dependencies.