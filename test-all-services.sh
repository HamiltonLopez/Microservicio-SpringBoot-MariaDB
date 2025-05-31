#!/bin/bash

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Función para imprimir mensajes de estado
print_status() {
    local status=$1
    local message=$2
    if [ $status -eq 0 ]; then
        echo -e "${GREEN}✓ $message${NC}"
    else
        echo -e "${RED}✗ $message${NC}"
    fi
}

# Función para probar un endpoint
test_endpoint() {
    local name=$1
    local url=$2
    local method=${3:-GET}
    local data=$4

    echo -e "\n${YELLOW}Probando $name en $url${NC}"
    
    if [ "$method" = "GET" ]; then
        response=$(curl -s -w "\n%{http_code}" "$url")
    else
        if [ -n "$data" ]; then
            response=$(curl -s -w "\n%{http_code}" -X "$method" -H "Content-Type: application/json" -d "$data" "$url")
        else
            response=$(curl -s -w "\n%{http_code}" -X "$method" "$url")
        fi
    fi

    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')

    if [ "$http_code" -ge 200 ] && [ "$http_code" -lt 300 ]; then
        print_status 0 "$method $url - HTTP $http_code"
        echo "Respuesta: $body"
        return 0
    else
        print_status 1 "$method $url - HTTP $http_code"
        echo "Error: $body"
        return 1
    fi
}

# Función para obtener IP de servicio en Kubernetes
get_k8s_service_ip() {
    local service=$1
    kubectl get service "$service" -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
}

# Verificar si los servicios están corriendo localmente
echo -e "${YELLOW}=== Probando servicios locales ===${NC}"

# Crear un estudiante
test_endpoint "Create Student" "http://localhost:8081/api/students" "POST" '{
    "name": "Test Student",
    "email": "test@example.com",
    "age": 20
}'

# Obtener todos los estudiantes
test_endpoint "Get All Students" "http://localhost:8082/api/students"

# Obtener estudiante por ID (asumiendo que el ID 1 existe)
test_endpoint "Get Student by ID" "http://localhost:8083/api/students/1"

# Actualizar estudiante
test_endpoint "Update Student" "http://localhost:8084/api/students/1" "PUT" '{
    "name": "Updated Student",
    "email": "updated@example.com",
    "age": 21
}'

# Eliminar estudiante
test_endpoint "Delete Student" "http://localhost:8085/api/students/1" "DELETE"

# Verificar servicios en Kubernetes
echo -e "\n${YELLOW}=== Verificando servicios en Kubernetes ===${NC}"

# Verificar que Kubernetes está disponible
if ! kubectl cluster-info &> /dev/null; then
    echo -e "${RED}Error: No se puede conectar al cluster de Kubernetes${NC}"
    exit 1
fi

# Verificar estado de los pods
echo -e "\n${YELLOW}Estado de los pods:${NC}"
kubectl get pods

# Verificar estado de los servicios
echo -e "\n${YELLOW}Estado de los servicios:${NC}"
kubectl get services
# ... existing code ...

# Función para obtener IP de servicio en Kubernetes
get_k8s_service_ip() {
    local service=$1
    echo "192.168.49.2"  # Retornamos la IP fija de Minikube
}

# ... existing code ...

echo -e "\n${YELLOW}=== Probando servicios en Kubernetes ===${NC}"

# Usar directamente la IP de Minikube para las pruebas
MINIKUBE_IP="192.168.49.2"

# Probar servicios en Kubernetes usando la IP de Minikube
test_endpoint "K8s Create Student" "http://$MINIKUBE_IP:30081/api/students" "POST" '{
    "name": "K8s Test Student",
    "email": "k8s@example.com",
    "age": 20
}'

test_endpoint "K8s Get All Students" "http://$MINIKUBE_IP:30082/api/students"

test_endpoint "K8s Get Student by ID" "http://$MINIKUBE_IP:30083/api/students/1"

test_endpoint "K8s Update Student" "http://$MINIKUBE_IP:30084/api/students/1" "PUT" '{
    "name": "K8s Updated Student",
    "email": "k8s.updated@example.com",
    "age": 21
}'

test_endpoint "K8s Delete Student" "http://$MINIKUBE_IP:30085/api/students/1" "DELETE"

echo -e "\n${YELLOW}=== Resumen de la base de datos ===${NC}"
echo "MariaDB está disponible en $MINIKUBE_IP:30006"
# ... existing code ...