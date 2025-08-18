# SMS Application - Kubernetes Architecture

## High-Level Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                                    INTERNET                                         │
└─────────────────────────────────┬───────────────────────────────────────────────────┘
                                  │
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                              AWS LOAD BALANCER                                     │
│                          (ALB - Application Load Balancer)                         │
│                              sms.duleendra.com                                     │
└─────────────────────────────────┬───────────────────────────────────────────────────┘
                                  │
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                                EKS CLUSTER                                         │
│ ┌─────────────────────────────────────────────────────────────────────────────────┐ │
│ │                              INGRESS LAYER                                     │ │
│ │ ┌─────────────────────────────────────────────────────────────────────────────┐ │ │
│ │ │                         Ingress Controller                                  │ │ │
│ │ │                            (AWS ALB)                                        │ │ │
│ │ │                                                                             │ │ │
│ │ │  Routes:                                                                    │ │ │
│ │ │  /api/auth     → sms-auth-service:80                                       │ │ │
│ │ │  /api/users    → sms-auth-service:80                                       │ │ │
│ │ │  /api/courses  → sms-course-service:80                                     │ │ │
│ │ │  /api/students → sms-student-service:80                                    │ │ │
│ │ │  /             → sms-frontend:80                                           │ │ │
│ │ └─────────────────────────────────────────────────────────────────────────────┘ │ │
│ └─────────────────────────────────────────────────────────────────────────────────┘ │
│                                       │                                             │
│ ┌─────────────────────────────────────────────────────────────────────────────────┐ │
│ │                            APPLICATION LAYER                                   │ │
│ │                                                                                 │ │
│ │ ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐ │ │
│ │ │   Frontend      │  │  Auth Service   │  │ Course Service  │  │   Student   │ │ │
│ │ │   (React)       │  │   (Node.js)     │  │   (Node.js)     │  │  Service    │ │ │
│ │ │                 │  │                 │  │                 │  │ (Node.js)   │ │ │
│ │ │ Deployment:     │  │ Deployment:     │  │ Deployment:     │  │ Deployment: │ │ │
│ │ │ - 3 replicas    │  │ - 2 replicas    │  │ - 2 replicas    │  │ - 2 replicas│ │ │
│ │ │ - Port: 80      │  │ - Port: 8080    │  │ - Port: 8081    │  │ - Port: 8082│ │ │
│ │ │ - HPA enabled   │  │ - HPA enabled   │  │ - HPA enabled   │  │ - HPA enabled│ │ │
│ │ │                 │  │                 │  │                 │  │             │ │ │
│ │ │ Service:        │  │ Service:        │  │ Service:        │  │ Service:    │ │ │
│ │ │ sms-frontend    │  │sms-auth-service │  │sms-course-service│  │sms-student- │ │ │
│ │ │                 │  │                 │  │                 │  │   service   │ │ │
│ │ └─────────────────┘  └─────────────────┘  └─────────────────┘  └─────────────┘ │ │
│ │         │                      │                      │                │       │ │
│ │         │                      │                      │                │       │ │
│ │         └──────────────────────┼──────────────────────┼────────────────┘       │ │
│ │                                │                      │                        │ │
│ │                                └──────────────────────┼────────────────────────┤ │
│ │                                                       │                        │ │
│ │                                └───────────────────────┘                        │ │
│ └─────────────────────────────────────────────────────────────────────────────────┘ │
│                                       │                                             │
│ ┌─────────────────────────────────────────────────────────────────────────────────┐ │
│ │                         CONFIGURATION LAYER                                    │ │
│ │                                                                                 │ │
│ │ ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────────────────────┐ │ │
│ │ │   ConfigMap     │  │ Kubernetes      │  │    AWS Secrets Manager          │ │ │
│ │ │  sms-config     │  │    Secret       │  │        (Production)             │ │ │
│ │ │                 │  │  sms-secret     │  │                                 │ │ │
│ │ │ Contains:       │  │ (Development)   │  │ Secrets:                        │ │ │
│ │ │ - NODE_ENV      │  │                 │  │ - sms-app/mongodb-credentials   │ │ │
│ │ │ - Service Ports │  │ Contains:       │  │ - sms-app/jwt-secret            │ │ │
│ │ │ - MongoDB Host  │  │ - MONGODB_URI   │  │                                 │ │ │
│ │ │ - Frontend URLs │  │ - JWT_SECRET    │  │ Accessed via:                   │ │ │
│ │ │                 │  │                 │  │ - SecretProviderClass           │ │ │
│ │ │                 │  │                 │  │ - CSI Driver                    │ │ │
│ │ │                 │  │                 │  │ - IAM Role (IRSA)               │ │ │
│ │ └─────────────────┘  └─────────────────┘  └─────────────────────────────────┘ │ │
│ └─────────────────────────────────────────────────────────────────────────────────┘ │
│                                       │                                             │
│ ┌─────────────────────────────────────────────────────────────────────────────────┐ │
│ │                           DATABASE LAYER                                       │ │
│ │                                                                                 │ │
│ │ ┌─────────────────────────────────────────────────────────────────────────────┐ │ │
│ │ │                          MongoDB StatefulSet                                │ │ │
│ │ │                            sms-mongodb                                      │ │ │
│ │ │                                                                             │ │ │
│ │ │ StatefulSet:                                                                │ │ │
│ │ │ - 1 replica (can be scaled to 3 for HA)                                    │ │ │
│ │ │ - Port: 27017                                                               │ │ │
│ │ │ - Persistent Volume: 20Gi (gp3 EBS)                                        │ │ │
│ │ │ - Health checks enabled                                                     │ │ │
│ │ │                                                                             │ │ │
│ │ │ Service:                                                                    │ │ │
│ │ │ - sms-mongodb:27017                                                         │ │ │
│ │ │ - ClusterIP                                                                 │ │ │
│ │ └─────────────────────────────────────────────────────────────────────────────┘ │ │
│ └─────────────────────────────────────────────────────────────────────────────────┘ │
│                                                                                     │
│ ┌─────────────────────────────────────────────────────────────────────────────────┐ │
│ │                           STORAGE LAYER                                        │ │
│ │                                                                                 │ │
│ │ ┌─────────────────┐  ┌─────────────────────────────────────────────────────┐ │ │
│ │ │ MongoDB Storage │  │           Student Service Storage                  │ │ │
│ │ │                 │  │                                                     │ │ │
│ │ │ PVC:            │  │ PVC:                                                │ │ │
│ │ │ - 20Gi          │  │ - 10Gi                                              │ │ │
│ │ │ - gp3 EBS       │  │ - gp3 EBS                                           │ │ │
│ │ │ - ReadWriteOnce │  │ - ReadWriteOnce                                     │ │ │
│ │ │                 │  │ - Mount: /app/uploads                               │ │ │
│ │ └─────────────────┘  └─────────────────────────────────────────────────────┘ │ │
│ └─────────────────────────────────────────────────────────────────────────────────┘ │
│                                                                                     │
│ ┌─────────────────────────────────────────────────────────────────────────────────┐ │
│ │                        SECURITY & RBAC LAYER                                   │ │
│ │                                                                                 │ │
│ │ ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────────────────────┐ │ │
│ │ │ Service Account │  │   IAM Role      │  │        Network Policies         │ │ │
│ │ │                 │  │     (IRSA)      │  │                                 │ │ │
│ │ │ For Secrets:    │  │                 │  │ - Pod-to-Pod communication      │ │ │
│ │ │ sms-secrets-sa  │  │ Permissions:    │  │ - Database access restrictions  │ │ │
│ │ │                 │  │ - SecretsManager│  │ - External traffic control      │ │ │
│ │ │ For Services:   │  │   GetSecretValue│  │                                 │ │ │
│ │ │ - Default SAs   │  │ - DescribeSecret│  │                                 │ │ │
│ │ └─────────────────┘  └─────────────────┘  └─────────────────────────────────┘ │ │
│ └─────────────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────────┐
│                              AWS SERVICES INTEGRATION                              │
│                                                                                     │
│ ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│ │   EKS Cluster   │  │ Secrets Manager │  │   EBS Volumes   │  │  Route53 + ACM  │ │
│ │                 │  │                 │  │                 │  │                 │ │
│ │ - Worker Nodes  │  │ - JWT Secret    │  │ - gp3 Storage   │  │ - DNS Records   │ │
│ │ - OIDC Provider │  │ - MongoDB Creds │  │ - 20Gi MongoDB  │  │ - SSL Certs     │ │
│ │ - VPC/Subnets   │  │ - Auto Rotation │  │ - 10Gi Uploads  │  │ - Domain Mgmt   │ │
│ └─────────────────┘  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

## Component Details

### Frontend Service
- **Technology**: React.js
- **Replicas**: 3 (Production), 1 (Development)
- **Port**: 80
- **Autoscaling**: HPA enabled (3-10 pods)
- **Purpose**: User interface for the SMS application

### Auth Service
- **Technology**: Node.js
- **Replicas**: 2 (Production), 1 (Development)
- **Port**: 8080
- **Endpoints**: `/api/auth`, `/api/users`
- **Purpose**: Authentication and user management

### Course Service
- **Technology**: Node.js
- **Replicas**: 2 (Production), 1 (Development)
- **Port**: 8081
- **Endpoints**: `/api/courses`
- **Purpose**: Course management functionality

### Student Service
- **Technology**: Node.js
- **Replicas**: 2 (Production), 1 (Development)
- **Port**: 8082
- **Endpoints**: `/api/students`
- **Storage**: 10Gi EBS volume for file uploads
- **Purpose**: Student management and file handling

### MongoDB Database
- **Type**: StatefulSet
- **Replicas**: 1 (can be scaled to 3 for HA)
- **Port**: 27017
- **Storage**: 20Gi gp3 EBS volume
- **Purpose**: Primary database for all services

## Network Flow

1. **External Traffic** → ALB → Ingress Controller
2. **Ingress Controller** → Routes to appropriate services based on path
3. **Services** → Load balance to backend pods
4. **Backend Pods** → Connect to MongoDB for data operations
5. **Configuration** → Loaded from ConfigMap and Secrets

## Security Architecture

### Development Environment
- Kubernetes native secrets
- Basic authentication
- Local storage

### Production Environment
- AWS Secrets Manager integration
- IAM roles with IRSA (IAM Roles for Service Accounts)
- EBS encryption
- Network policies
- SSL/TLS termination at ALB

## Storage Architecture

### Persistent Volumes
- **MongoDB**: 20Gi gp3 EBS volume
- **Student Uploads**: 10Gi gp3 EBS volume
- **Storage Class**: gp3 (optimized for EKS)

### Backup Strategy
- EBS snapshots for persistent volumes
- MongoDB replica sets for data redundancy
- Cross-AZ deployment for high availability

## Monitoring & Observability

### Health Checks
- Liveness probes on all services
- Readiness probes for traffic routing
- Startup probes for initialization

### Metrics & Logging
- Container logs via CloudWatch
- Prometheus metrics collection
- Grafana dashboards
- AWS Load Balancer access logs

## Scaling Strategy

### Horizontal Pod Autoscaler (HPA)
- CPU-based scaling (70% threshold)
- Memory-based scaling (80% threshold)
- Min/Max replica configuration per service

### Vertical Scaling
- Resource requests and limits defined
- Node autoscaling for cluster capacity
- EBS volume expansion capabilities