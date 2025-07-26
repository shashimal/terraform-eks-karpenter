# SMS Application - Kubernetes Architecture Diagram

## High-Level Architecture Overview

```mermaid
graph TB
    %% External Traffic
    Internet([Internet/Users]) --> LB[Load Balancer]
    
    %% Ingress Layer
    LB --> Ingress[Ingress Controller<br/>nginx/traefik]
    
    %% Kubernetes Cluster
    subgraph "Kubernetes Cluster"
        %% Ingress
        Ingress --> FrontendSvc[Frontend Service<br/>ClusterIP:80]
        
        %% Frontend Tier
        subgraph "Frontend Namespace"
            FrontendSvc --> FrontendPod1[Frontend Pod 1<br/>React App<br/>Port: 80]
            FrontendSvc --> FrontendPod2[Frontend Pod 2<br/>React App<br/>Port: 80]
            FrontendPod1 --> FrontendPVC[Frontend PVC<br/>Static Assets]
        end
        
        %% API Gateway/Services
        FrontendPod1 -.->|API Calls| StudentSvc[Student Service<br/>ClusterIP:80]
        FrontendPod1 -.->|API Calls| CourseSvc[Course Service<br/>ClusterIP:80]
        FrontendPod1 -.->|API Calls| AuthSvc[Auth Service<br/>ClusterIP:80]
        
        %% Microservices Tier
        subgraph "Services Namespace"
            %% Student Service
            StudentSvc --> StudentPod1[Student Pod 1<br/>Node.js<br/>Port: 3001]
            StudentSvc --> StudentPod2[Student Pod 2<br/>Node.js<br/>Port: 3001]
            StudentPod1 --> StudentPVC[Student PVC<br/>File Uploads]
            
            %% Course Service
            CourseSvc --> CoursePod1[Course Pod 1<br/>Node.js<br/>Port: 3002]
            CourseSvc --> CoursePod2[Course Pod 2<br/>Node.js<br/>Port: 3002]
            
            %% Auth Service
            AuthSvc --> AuthPod1[Auth Pod 1<br/>Node.js<br/>Port: 3003]
            AuthSvc --> AuthPod2[Auth Pod 2<br/>Node.js<br/>Port: 3003]
        end
        
        %% Database Tier
        subgraph "Database Namespace"
            StudentPod1 -.->|MongoDB Connection| MongoSvc[MongoDB Service<br/>ClusterIP:27017]
            CoursePod1 -.->|MongoDB Connection| MongoSvc
            AuthPod1 -.->|MongoDB Connection| MongoSvc
            
            MongoSvc --> MongoPod[MongoDB Pod<br/>Port: 27017]
            MongoPod --> MongoPVC[MongoDB PVC<br/>Persistent Storage]
        end
        
        %% ConfigMaps and Secrets
        subgraph "Configuration"
            StudentCM[Student ConfigMap]
            CourseCM[Course ConfigMap]
            AuthCM[Auth ConfigMap]
            FrontendCM[Frontend ConfigMap]
            
            AuthSecret[Auth Secret<br/>JWT Keys]
            MongoSecret[MongoDB Secret<br/>Credentials]
        end
        
        %% Configuration connections
        StudentPod1 -.-> StudentCM
        StudentPod1 -.-> MongoSecret
        CoursePod1 -.-> CourseCM
        CoursePod1 -.-> MongoSecret
        AuthPod1 -.-> AuthCM
        AuthPod1 -.-> AuthSecret
        AuthPod1 -.-> MongoSecret
        FrontendPod1 -.-> FrontendCM
        MongoPod -.-> MongoSecret
    end
    
    %% External Storage
    MongoPVC -.-> EBS[AWS EBS Volume<br/>Persistent Storage]
    StudentPVC -.-> EFS[AWS EFS<br/>Shared File Storage]
    
    %% Monitoring & Logging
    subgraph "Observability"
        Prometheus[Prometheus<br/>Metrics Collection]
        Grafana[Grafana<br/>Dashboards]
        ELK[ELK Stack<br/>Logging]
    end
    
    StudentPod1 -.->|Metrics| Prometheus
    CoursePod1 -.->|Metrics| Prometheus
    AuthPod1 -.->|Metrics| Prometheus
    FrontendPod1 -.->|Logs| ELK
    
    %% Styling
    classDef frontend fill:#e1f5fe
    classDef service fill:#f3e5f5
    classDef database fill:#e8f5e8
    classDef config fill:#fff3e0
    classDef storage fill:#fce4ec
    classDef monitoring fill:#f1f8e9
    
    class FrontendSvc,FrontendPod1,FrontendPod2,FrontendCM,FrontendPVC frontend
    class StudentSvc,StudentPod1,StudentPod2,StudentCM,CourseSvc,CoursePod1,CoursePod2,CourseCM,AuthSvc,AuthPod1,AuthPod2,AuthCM service
    class MongoSvc,MongoPod,MongoSecret database
    class StudentCM,CourseCM,AuthCM,FrontendCM,AuthSecret,MongoSecret config
    class MongoPVC,StudentPVC,EBS,EFS storage
    class Prometheus,Grafana,ELK monitoring
```

## Detailed Component Architecture

```mermaid
graph LR
    %% User Flow
    User[👤 User] --> Browser[🌐 Browser]
    Browser --> CDN[📡 CloudFront CDN]
    CDN --> ALB[⚖️ Application Load Balancer]
    
    %% Kubernetes Ingress
    ALB --> Ingress[🚪 Ingress Controller]
    
    %% Frontend Layer
    subgraph "Frontend Tier"
        Ingress --> FE_SVC[Frontend Service]
        FE_SVC --> FE_POD1[Frontend Pod 1<br/>React + Nginx]
        FE_SVC --> FE_POD2[Frontend Pod 2<br/>React + Nginx]
    end
    
    %% API Layer
    subgraph "API Gateway Tier"
        FE_POD1 --> API_GW[🚪 API Gateway<br/>Optional]
        API_GW --> STUDENT_SVC[Student Service]
        API_GW --> COURSE_SVC[Course Service]
        API_GW --> AUTH_SVC[Auth Service]
    end
    
    %% Microservices
    subgraph "Microservices Tier"
        STUDENT_SVC --> STUDENT_POD[Student Pods<br/>Node.js API]
        COURSE_SVC --> COURSE_POD[Course Pods<br/>Node.js API]
        AUTH_SVC --> AUTH_POD[Auth Pods<br/>Node.js API]
    end
    
    %% Data Layer
    subgraph "Data Tier"
        STUDENT_POD --> MONGO_SVC[MongoDB Service]
        COURSE_POD --> MONGO_SVC
        AUTH_POD --> MONGO_SVC
        MONGO_SVC --> MONGO_POD[MongoDB Pod]
        MONGO_POD --> MONGO_PVC[📀 MongoDB PVC]
    end
    
    %% File Storage
    STUDENT_POD --> FILE_STORAGE[📁 File Storage<br/>AWS EFS]
    
    %% External Services
    subgraph "External Services"
        MONGO_POD -.-> BACKUP[💾 MongoDB Backup<br/>AWS S3]
        FILE_STORAGE -.-> S3[📦 AWS S3<br/>File Backup]
    end
```

## Network Architecture

```mermaid
graph TB
    %% VPC and Subnets
    subgraph "AWS VPC (10.0.0.0/16)"
        subgraph "Public Subnets"
            subgraph "AZ-1a (10.0.1.0/24)"
                ALB1[Application Load Balancer]
                NAT1[NAT Gateway]
            end
            subgraph "AZ-1b (10.0.2.0/24)"
                ALB2[Application Load Balancer]
                NAT2[NAT Gateway]
            end
        end
        
        subgraph "Private Subnets"
            subgraph "AZ-1a (10.0.10.0/24)"
                subgraph "EKS Cluster"
                    NODE1[Worker Node 1<br/>Frontend Pods]
                    NODE2[Worker Node 2<br/>Service Pods]
                end
            end
            subgraph "AZ-1b (10.0.20.0/24)"
                subgraph "EKS Cluster"
                    NODE3[Worker Node 3<br/>Database Pods]
                    NODE4[Worker Node 4<br/>Monitoring]
                end
            end
        end
        
        subgraph "Database Subnets"
            subgraph "AZ-1a (10.0.100.0/24)"
                RDS1[RDS Instance<br/>Optional]
            end
            subgraph "AZ-1b (10.0.200.0/24)"
                RDS2[RDS Standby<br/>Optional]
            end
        end
    end
    
    %% Internet Gateway
    IGW[Internet Gateway] --> ALB1
    IGW --> ALB2
    
    %% NAT Gateway connections
    NODE1 --> NAT1
    NODE2 --> NAT1
    NODE3 --> NAT2
    NODE4 --> NAT2
    
    %% Load Balancer to Nodes
    ALB1 --> NODE1
    ALB1 --> NODE2
    ALB2 --> NODE3
    ALB2 --> NODE4
```

## Security Architecture

```mermaid
graph TB
    %% Security Layers
    subgraph "Security Layers"
        subgraph "Network Security"
            WAF[🛡️ AWS WAF<br/>Web Application Firewall]
            SG[🔒 Security Groups]
            NACL[🚧 Network ACLs]
            NP[🔐 Network Policies]
        end
        
        subgraph "Identity & Access"
            IAM[👤 AWS IAM Roles]
            RBAC[🔑 Kubernetes RBAC]
            SA[👥 Service Accounts]
            PSP[🛡️ Pod Security Policies]
        end
        
        subgraph "Data Security"
            SECRETS[🔐 Kubernetes Secrets]
            CM[📋 ConfigMaps]
            ENCRYPTION[🔒 Encryption at Rest]
            TLS[🔐 TLS/SSL]
        end
        
        subgraph "Runtime Security"
            SC[🛡️ Security Contexts]
            ADMISSION[🚪 Admission Controllers]
            FALCO[👁️ Falco Runtime Security]
        end
    end
    
    %% Connections
    WAF --> SG
    SG --> NACL
    NACL --> NP
    
    IAM --> RBAC
    RBAC --> SA
    SA --> PSP
    
    SECRETS --> CM
    CM --> ENCRYPTION
    ENCRYPTION --> TLS
    
    SC --> ADMISSION
    ADMISSION --> FALCO
```

## Deployment Strategy

```mermaid
graph LR
    %% CI/CD Pipeline
    subgraph "CI/CD Pipeline"
        GIT[📝 Git Repository] --> JENKINS[🔧 Jenkins/GitHub Actions]
        JENKINS --> BUILD[🏗️ Docker Build]
        BUILD --> TEST[🧪 Unit Tests]
        TEST --> SCAN[🔍 Security Scan]
        SCAN --> PUSH[📤 Push to Registry]
    end
    
    %% Deployment Stages
    subgraph "Deployment Stages"
        PUSH --> DEV[🧪 Development<br/>Namespace: dev]
        DEV --> STAGING[🎭 Staging<br/>Namespace: staging]
        STAGING --> PROD[🚀 Production<br/>Namespace: production]
    end
    
    %% Helm Deployment
    subgraph "Helm Deployment"
        PROD --> HELM[⚙️ Helm Charts]
        HELM --> K8S[☸️ Kubernetes Cluster]
        K8S --> MONITOR[📊 Monitoring & Alerts]
    end
```

## Resource Requirements

| Component | CPU Request | CPU Limit | Memory Request | Memory Limit | Replicas |
|-----------|-------------|-----------|----------------|--------------|----------|
| Frontend | 100m | 200m | 128Mi | 256Mi | 2-5 |
| Student Service | 250m | 500m | 256Mi | 512Mi | 2-10 |
| Course Service | 250m | 500m | 256Mi | 512Mi | 2-10 |
| Auth Service | 200m | 400m | 256Mi | 512Mi | 2-5 |
| MongoDB | 500m | 1000m | 1Gi | 2Gi | 1 |

## Storage Requirements

| Component | Storage Type | Size | Access Mode |
|-----------|-------------|------|-------------|
| MongoDB Data | AWS EBS (gp3) | 100Gi | ReadWriteOnce |
| Student Uploads | AWS EFS | 50Gi | ReadWriteMany |
| Application Logs | AWS EBS (gp3) | 20Gi | ReadWriteOnce |

This architecture provides:
- **High Availability**: Multi-AZ deployment with load balancing
- **Scalability**: Horizontal pod autoscaling based on metrics
- **Security**: Multiple security layers and best practices
- **Monitoring**: Comprehensive observability stack
- **Disaster Recovery**: Automated backups and multi-region support