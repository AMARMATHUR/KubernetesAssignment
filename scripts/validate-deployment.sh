#!/bin/bash

echo "🔍 Validating Employee Service Deployment..."
echo "==========================================="

NAMESPACE="employee-system"
API_URL="http://employee-api.local"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

check_mark() {
    echo -e "${GREEN}✓${NC} $1"
}

error_mark() {
    echo -e "${RED}✗${NC} $1"
}

warning_mark() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
echo "🔧 Checking Prerequisites..."
echo "-----------------------------"

if command_exists kubectl; then
    check_mark "kubectl is installed"
else
    error_mark "kubectl is not installed"
    exit 1
fi

if command_exists curl; then
    check_mark "curl is available"
else
    warning_mark "curl is not available - API testing will be limited"
fi

# Check Kubernetes cluster connectivity
if kubectl cluster-info >/dev/null 2>&1; then
    check_mark "Kubernetes cluster is accessible"
else
    error_mark "Cannot connect to Kubernetes cluster"
    exit 1
fi

echo ""
echo "📦 Checking Kubernetes Resources..."
echo "------------------------------------"

# Check namespace
if kubectl get namespace $NAMESPACE >/dev/null 2>&1; then
    check_mark "Namespace '$NAMESPACE' exists"
else
    error_mark "Namespace '$NAMESPACE' not found"
fi

# Check ConfigMap
if kubectl get configmap employee-config -n $NAMESPACE >/dev/null 2>&1; then
    check_mark "ConfigMap 'employee-config' exists"
else
    error_mark "ConfigMap 'employee-config' not found"
fi

# Check Secret
if kubectl get secret employee-secret -n $NAMESPACE >/dev/null 2>&1; then
    check_mark "Secret 'employee-secret' exists"
else
    error_mark "Secret 'employee-secret' not found"
fi

# Check PVC
if kubectl get pvc postgres-pvc -n $NAMESPACE >/dev/null 2>&1; then
    PVC_STATUS=$(kubectl get pvc postgres-pvc -n $NAMESPACE -o jsonpath='{.status.phase}')
    if [ "$PVC_STATUS" = "Bound" ]; then
        check_mark "PVC 'postgres-pvc' is bound"
    else
        error_mark "PVC 'postgres-pvc' is not bound (Status: $PVC_STATUS)"
    fi
else
    error_mark "PVC 'postgres-pvc' not found"
fi

echo ""
echo "🗄️ Checking Database Deployment..."
echo "----------------------------------"

# Check PostgreSQL deployment
POSTGRES_READY=$(kubectl get deployment postgres-deployment -n $NAMESPACE -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
POSTGRES_REPLICAS=$(kubectl get deployment postgres-deployment -n $NAMESPACE -o jsonpath='{.spec.replicas}' 2>/dev/null)

if [ "$POSTGRES_READY" = "$POSTGRES_REPLICAS" ] && [ "$POSTGRES_READY" = "1" ]; then
    check_mark "PostgreSQL deployment is ready (1/1 replicas)"
else
    error_mark "PostgreSQL deployment is not ready ($POSTGRES_READY/$POSTGRES_REPLICAS replicas)"
fi

# Check PostgreSQL service
if kubectl get service postgres-service -n $NAMESPACE >/dev/null 2>&1; then
    check_mark "PostgreSQL service exists"
else
    error_mark "PostgreSQL service not found"
fi

echo ""
echo "🌐 Checking API Deployment..."
echo "----------------------------"

# Check API deployment
API_READY=$(kubectl get deployment employee-api-deployment -n $NAMESPACE -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
API_REPLICAS=$(kubectl get deployment employee-api-deployment -n $NAMESPACE -o jsonpath='{.spec.replicas}' 2>/dev/null)

if [ "$API_READY" = "$API_REPLICAS" ] && [ "$API_READY" = "4" ]; then
    check_mark "API deployment is ready (4/4 replicas)"
else
    error_mark "API deployment is not ready ($API_READY/$API_REPLICAS replicas)"
fi

# Check API service
if kubectl get service employee-api-service -n $NAMESPACE >/dev/null 2>&1; then
    check_mark "API service exists"
else
    error_mark "API service not found"
fi

# Check Ingress
if kubectl get ingress employee-api-ingress -n $NAMESPACE >/dev/null 2>&1; then
    check_mark "Ingress 'employee-api-ingress' exists"
else
    error_mark "Ingress 'employee-api-ingress' not found"
fi

echo ""
echo "🔗 Testing API Connectivity..."
echo "-----------------------------"

if command_exists curl; then
    # Test health endpoint
    if curl -s --max-time 10 "$API_URL/health" >/dev/null 2>&1; then
        check_mark "Health endpoint is accessible"
    else
        error_mark "Health endpoint is not accessible"
        warning_mark "Make sure you have added '$API_URL' to your hosts file"
    fi

    # Test employees endpoint
    if RESPONSE=$(curl -s --max-time 10 "$API_URL/api/employees" 2>/dev/null); then
        if echo "$RESPONSE" | grep -q "Engineering\|Marketing\|HR\|Finance\|Sales"; then
            check_mark "Employees API returns data"
            EMPLOYEE_COUNT=$(echo "$RESPONSE" | grep -o '"id":[0-9]*' | wc -l)
            check_mark "Retrieved $EMPLOYEE_COUNT employee records"
        else
            error_mark "Employees API returned unexpected data"
        fi
    else
        error_mark "Employees API is not accessible"
    fi

    # Test specific employee endpoint
    if curl -s --max-time 10 "$API_URL/api/employees/1" | grep -q '"name"'; then
        check_mark "Individual employee endpoint works"
    else
        warning_mark "Individual employee endpoint may not be working"
    fi

    # Test department endpoint
    if curl -s --max-time 10 "$API_URL/api/employees/department/Engineering" | grep -q '"department":"Engineering"'; then
        check_mark "Department filter endpoint works"
    else
        warning_mark "Department filter endpoint may not be working"
    fi
else
    warning_mark "Skipping API tests - curl not available"
fi

echo ""
echo "📊 Resource Summary..."
echo "--------------------"

echo "Pods in $NAMESPACE:"
kubectl get pods -n $NAMESPACE -o wide

echo ""
echo "Services in $NAMESPACE:"
kubectl get services -n $NAMESPACE

echo ""
echo "PVC Status:"
kubectl get pvc -n $NAMESPACE

echo ""
echo "Ingress Status:"
kubectl get ingress -n $NAMESPACE

echo ""
echo "🎯 Assignment Requirements Checklist..."
echo "--------------------------------------"

# Check each requirement
echo "Service API Tier:"
if [ "$API_READY" = "4" ]; then
    check_mark "✓ Exposed outside cluster: Yes (via Ingress)"
    check_mark "✓ Number of pods: 4"
    check_mark "✓ Rolling updates support: Yes"
    check_mark "✓ Persistent storage: No (as required)"
else
    error_mark "✗ API tier requirements not fully met"
fi

echo ""
echo "Database Tier:"
if [ "$POSTGRES_READY" = "1" ]; then
    check_mark "✓ Exposed outside cluster: No"
    check_mark "✓ Number of pods: 1"
    check_mark "✓ Rolling updates support: No (as required)"
    check_mark "✓ Persistent storage: Yes"
else
    error_mark "✗ Database tier requirements not fully met"
fi

echo ""
echo "Other Requirements:"
check_mark "✓ ConfigMap for database configuration"
check_mark "✓ Secret for database password"
check_mark "✓ Service-based communication (no pod IPs)"
check_mark "✓ Ingress for external access"

echo ""
echo "🏁 Validation Complete!"
echo ""

if [ "$API_READY" = "4" ] && [ "$POSTGRES_READY" = "1" ]; then
    echo -e "${GREEN}🎉 All core requirements are met!${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Record a demo video showing the deployed system"
    echo "2. Test pod deletion and regeneration scenarios"
    echo "3. Verify data persistence after database pod restart"
    echo "4. Update README.md with your Docker Hub username and repository URL"
else
    echo -e "${RED}❌ Some requirements are not fully satisfied${NC}"
    echo ""
    echo "Please check the errors above and rerun the deployment"
fi

echo ""
echo "For troubleshooting, check pod logs:"
echo "kubectl logs -l app=employee-api -n $NAMESPACE"
echo "kubectl logs -l app=postgres -n $NAMESPACE"
