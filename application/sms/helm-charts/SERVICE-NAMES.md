# SMS Application Service Names

## 🎯 Correct Service Names in Kubernetes Cluster

When deployed via the umbrella chart (`sms-app`), the services will have these names:

### **MongoDB StatefulSet**
- **Service Name**: `sms-mongodb`
- **Port**: `27017`
- **Full DNS**: `sms-mongodb.sms-app.svc.cluster.local`

### **Course Service**
- **Service Name**: `sms-course-service`
- **Port**: `80` (maps to container port 3002)
- **Full DNS**: `sms-course-service.sms-app.svc.cluster.local`

### **Student Service**
- **Service Name**: `sms-student-service`
- **Port**: `80` (maps to container port 3001)
- **Full DNS**: `sms-student-service.sms-app.svc.cluster.local`
- **Persistent Volume**: `/app/uploads` (5Gi)

### **Auth Service**
- **Service Name**: `sms-auth-service`
- **Port**: `80` (maps to container port 3003)
- **Full DNS**: `sms-auth-service.sms-app.svc.cluster.local`
- **JWT Authentication**: Enabled with configurable secret

### **Frontend Service**
- **Service Name**: `sms-frontend`
- **Port**: `80` (maps to container port 80)
- **Full DNS**: `sms-frontend.sms-app.svc.cluster.local`
- **Ingress**: `sms-app.local` (Minikube)

## 🔗 Connection Strings

### **From Services to MongoDB**
```
MONGODB_URI=mongodb://sms-mongodb:27017/course-db
MONGODB_URI=mongodb://sms-mongodb:27017/student-db
MONGODB_URI=mongodb://sms-mongodb:27017/auth-db
```

### **From External Services to APIs**
```
COURSE_API_URL=http://sms-course-service:80/api/courses
STUDENT_API_URL=http://sms-student-service:80/api/students
AUTH_API_URL=http://sms-auth-service:80/api/auth
```

## 📋 Service Naming Convention

Helm uses this pattern for service names:
```
{release-name}-{chart-name}
```

Where:
- `release-name` = `sms-app` (umbrella chart release)
- `chart-name` = `mongodb` or `course-service`

## 🔍 Verification Commands

```bash
# Check services
kubectl get services -n sms-app

# Test DNS resolution
kubectl run dns-test --rm -i --tty --image=busybox --restart=Never -- nslookup sms-app-mongodb.sms-app.svc.cluster.local

# Test MongoDB connection
kubectl run mongodb-test --rm -i --tty --image=mongo:latest --restart=Never -- mongosh --host sms-app-mongodb --port 27017

# Check course service logs
kubectl logs -l app.kubernetes.io/name=course-service -n sms-app
```

## ⚠️ Important Notes

1. **StatefulSet Services**: MongoDB uses a StatefulSet, so the service name is crucial for persistent connections
2. **Namespace**: All services are in the `sms-app` namespace
3. **Port Mapping**: Course service exposes port 80 externally but runs on port 3002 internally
4. **DNS**: Full DNS names include the namespace and cluster domain