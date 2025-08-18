# SMS Application Ingress Setup for Minikube

## 🚀 Quick Setup

### 1. Setup Minikube Ingress
```bash
cd application/sms/helm-charts
./setup-minikube-ingress.sh
```

### 2. Deploy Application with Ingress
```bash
./deploy-with-ingress.sh
```

### 3. Add Hosts Entry
```bash
echo "$(minikube ip) sms-app.local" | sudo tee -a /etc/hosts
```

### 4. Access Application
Visit: http://sms-app.local

## 📋 Manual Setup Steps

### 1. Enable Minikube Ingress Addon
```bash
minikube addons enable ingress
```

### 2. Verify Ingress Controller
```bash
kubectl get pods -n ingress-nginx
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=300s
```

### 3. Deploy SMS Application
```bash
cd application/sms/helm-charts
./deploy-all.sh
```

### 4. Check Ingress Status
```bash
kubectl get ingress -n sms-app
kubectl describe ingress sms-frontend -n sms-app
```

### 5. Setup DNS Resolution
```bash
# Get Minikube IP
minikube ip

# Add to /etc/hosts
echo "$(minikube ip) sms-app.local" | sudo tee -a /etc/hosts
```

## 🔧 Configuration Details

### Ingress Configuration
```yaml
ingress:
  enabled: true
  className: "nginx"
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
  hosts:
    - host: sms-app.local
      paths:
        - path: /
          pathType: Prefix
```

### Service Names
- **Frontend**: `sms-frontend:80`
- **Course API**: `sms-course-service:80`
- **Student API**: `sms-student-service:80`
- **Auth API**: `sms-auth-service:80`

## 🔍 Troubleshooting

### Check Ingress Status
```bash
kubectl get ingress -n sms-app
kubectl describe ingress sms-frontend -n sms-app
```

### Check Ingress Controller Logs
```bash
kubectl logs -n ingress-nginx -l app.kubernetes.io/component=controller
```

### Test DNS Resolution
```bash
nslookup sms-app.local
ping sms-app.local
```

### Check Frontend Service
```bash
kubectl get svc sms-frontend -n sms-app
kubectl port-forward svc/sms-frontend 8080:80 -n sms-app
```

### Common Issues

#### 1. Ingress Not Working
- Check if ingress addon is enabled: `minikube addons list`
- Verify ingress controller is running: `kubectl get pods -n ingress-nginx`
- Check ingress resource: `kubectl get ingress -n sms-app`

#### 2. DNS Not Resolving
- Verify /etc/hosts entry: `cat /etc/hosts | grep sms-app.local`
- Check minikube IP: `minikube ip`
- Try with IP directly: `curl http://$(minikube ip)`

#### 3. 404 Errors
- Check service endpoints: `kubectl get endpoints -n sms-app`
- Verify pod status: `kubectl get pods -n sms-app`
- Check ingress annotations

#### 4. API Calls Failing
- Verify service names in frontend environment variables
- Check if services are running: `kubectl get svc -n sms-app`
- Test API endpoints directly: `kubectl port-forward svc/sms-course-service 8080:80 -n sms-app`

## 🌐 Alternative Access Methods

### Port Forwarding (if ingress fails)
```bash
# Frontend
kubectl port-forward svc/sms-frontend 8080:80 -n sms-app

# APIs
kubectl port-forward svc/sms-course-service 8081:80 -n sms-app
kubectl port-forward svc/sms-student-service 8082:80 -n sms-app
kubectl port-forward svc/sms-auth-service 8083:80 -n sms-app
```

### NodePort Service (alternative)
```yaml
service:
  type: NodePort
  port: 80
  nodePort: 30080
```

Access via: `http://$(minikube ip):30080`

## 📊 Monitoring

### Check Application Health
```bash
# All pods
kubectl get pods -n sms-app

# Ingress status
kubectl get ingress -n sms-app

# Service endpoints
kubectl get endpoints -n sms-app
```

### View Logs
```bash
# Frontend logs
kubectl logs -l app.kubernetes.io/name=frontend -n sms-app

# Ingress controller logs
kubectl logs -n ingress-nginx -l app.kubernetes.io/component=controller
```