# SMS Application Umbrella Chart

This umbrella chart manages the SMS (Student Management System) application components as dependencies.

## Components

- **mongodb** - MongoDB StatefulSet with persistent storage
- **course-service** - Course management service

## Quick Start

### Deploy using the umbrella chart:
```bash
cd application/sms/helm-charts
./deploy.sh
```

### Manual deployment:
```bash
cd application/sms/helm-charts/sms-app

# Update dependencies
helm dependency update

# Deploy
helm install sms-app . --namespace sms-app --create-namespace
```

### Cleanup:
```bash
./cleanup.sh
```

## Configuration

You can configure the components by modifying the `sms-app/values.yaml` file:

```yaml
# Enable/disable components
mongodb:
  enabled: true
  
course-service:
  enabled: true
  replicaCount: 2  # Scale course service
```

## Dependencies

The umbrella chart uses local file dependencies:
- `mongodb` from `file://../mongodb`
- `course-service` from `file://../course-service`

## Accessing Services

After deployment:

```bash
# Check status
kubectl get pods -n sms-app

# Access course service
kubectl port-forward svc/sms-app-course-service 8080:80 -n sms-app

# Access MongoDB (for debugging)
kubectl port-forward svc/sms-app-mongodb 27017:27017 -n sms-app
```

## Service Names

When deployed via umbrella chart, services are prefixed with the release name:
- MongoDB: `sms-app-mongodb:27017`
- Course Service: `sms-app-course-service:80`

## Customization

Override values during installation:
```bash
helm install sms-app ./sms-app \
  --namespace sms-app \
  --create-namespace \
  --set mongodb.persistence.size=20Gi \
  --set course-service.replicaCount=3
```