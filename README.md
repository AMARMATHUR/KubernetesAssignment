# Employee Service - Kubernetes Assignment

This project implements a multi-tier architecture with a .NET 8 Web API and PostgreSQL database, containerized and deployed on Kubernetes.

## 🏗️ Architecture

- **Service API Tier**: .NET 8 Web API with Entity Framework Core
- **Database Tier**: PostgreSQL with persistent storage
- **Orchestration**: Kubernetes with proper networking and security

## 📁 Project Structure

```
.
├── src/
│   └── EmployeeService.API/           # .NET 8 Web API
│       ├── Controllers/               # API Controllers
│       ├── Data/                     # Entity Framework Context
│       ├── Models/                   # Domain Models
│       ├── Dockerfile               # Docker configuration
│       └── appsettings.json        # Configuration
├── k8s/                             # Kubernetes manifests
│   ├── namespace.yaml              # Namespace definition
│   ├── configmap.yaml             # Configuration data
│   ├── secret.yaml                # Sensitive data
│   ├── postgres-pv.yaml           # Persistent storage
│   ├── postgres-deployment.yaml   # Database deployment
│   ├── api-deployment.yaml        # API deployment
│   └── ingress.yaml               # External access
├── scripts/                        # Deployment scripts
└── docs/                          # Documentation
```

## 🔗 Links

- **Code Repository**: https://github.com/AMARMATHUR/KubernetesAssignment
- **Docker Hub Image**: `amarmathur/employee-api:latest` 
- **API Endpoint**: `http://employee-api.local/api/employees`
- **📋 Comprehensive Documentation**: [Assignment Documentation](docs/DOCUMENTATION.md)

## 🚀 Quick Start

### Prerequisites

- Docker & Docker Hub account
- Kubernetes cluster (local or cloud)
- kubectl CLI
- .NET 8 SDK (for local development)

### 1. Build and Push Docker Image

```bash
# Update Docker username in the script
./scripts/build-and-push.sh
# or on Windows
./scripts/build-and-push.bat
```

### 2. Deploy to Kubernetes

```bash
# Deploy all components
./scripts/deploy.sh

# Check deployment status
kubectl get all -n employee-system
```

### 3. Access the API

Add to your hosts file:
```
<NGINX_INGRESS_IP> employee-api.local
```

Test the API:
```bash
curl http://employee-api.local/api/employees
```

## 🔍 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/employees` | Get all employees |
| GET | `/api/employees/{id}` | Get employee by ID |
| GET | `/api/employees/department/{dept}` | Get employees by department |
| GET | `/health` | Health check |

## 📊 Sample Data

The database is pre-seeded with 8 employee records across different departments:
- Engineering (3 employees)
- Marketing (2 employees) 
- HR, Finance, Sales (1 each)

## 🎯 Kubernetes Features Implemented

### ✅ Service API Tier
- ✅ **Exposed outside cluster**: Via Ingress
- ✅ **Number of pods**: 4 replicas with auto-scaling
- ✅ **Rolling updates**: Configured with RollingUpdate strategy
- ✅ **Persistent storage**: Not required (stateless)

### ✅ Database Tier  
- ✅ **Exposed outside cluster**: No (internal only)
- ✅ **Number of pods**: 1 replica
- ✅ **Rolling updates**: Not configured (data consistency)
- ✅ **Persistent storage**: Yes (2Gi PVC)

### ✅ Additional Requirements
- ✅ **ConfigMap**: Database configuration externalized
- ✅ **Secret**: Database password secured
- ✅ **Data persistence**: PVC ensures data survives pod restarts
- ✅ **Service communication**: DNS-based service discovery
- ✅ **Ingress**: External access configured

## 🛠️ Configuration

### ConfigMap (k8s/configmap.yaml)
```yaml
data:
  database-host: "postgres-service"
  database-name: "employeedb"
  database-user: "postgres"
```

## 📋 Testing Scenarios

1. **API Access**: `curl http://employee-api.local/api/employees`
2. **Pod Resilience**: Delete API pod and verify auto-recreation
3. **Data Persistence**: Delete DB pod and verify data retention
4. **Scaling**: Scale API pods up/down
5. **Health Checks**: Monitor `/health` endpoint

## 🧹 Cleanup

```bash
./scripts/cleanup.sh
```

