#!/bin/bash

# Colores para la salida
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para imprimir encabezados
print_header() {
    echo -e "\n${YELLOW}=== $1 ===${NC}"
}

# Función para ejecutar pruebas de un servicio
run_service_tests() {
    local service_name=$1
    local service_dir=$2
    
    print_header "Ejecutando pruebas para $service_name"
    
    if [ -d "$service_dir" ]; then
        cd "$service_dir"
        
        # Verificar si existe el archivo pom.xml
        if [ -f "pom.xml" ]; then
            echo -e "${YELLOW}Ejecutando pruebas Maven...${NC}"
            if mvn test; then
                echo -e "${GREEN}✓ Pruebas completadas exitosamente para $service_name${NC}"
                cd ..
                return 0
            else
                echo -e "${RED}✗ Falló la ejecución de pruebas para $service_name${NC}"
                cd ..
                return 1
            fi
        else
            echo -e "${RED}✗ No se encontró el archivo pom.xml en $service_name${NC}"
            cd ..
            return 1
        fi
    else
        echo -e "${RED}✗ No se encontró el directorio para $service_name${NC}"
        return 1
    fi
}

# Función para mostrar el resumen
show_summary() {
    local total=$1
    local passed=$2
    
    echo -e "\n${YELLOW}=== Resumen de Pruebas ===${NC}"
    echo -e "Total de servicios probados: $total"
    echo -e "Servicios exitosos: ${GREEN}$passed${NC}"
    echo -e "Servicios fallidos: ${RED}$((total - passed))${NC}"
    
    if [ $passed -eq $total ]; then
        echo -e "${GREEN}✓ Todas las pruebas pasaron exitosamente${NC}"
    else
        echo -e "${RED}✗ Algunas pruebas fallaron${NC}"
    fi
}

# Inicializar contadores
total_services=0
passed_services=0

# Array de servicios para probar
declare -A services=(
    ["Create Service"]="students-create-service-spring"
    ["Get Service"]="students-get-service-spring"
    ["GetById Service"]="students-getbyid-service-spring"
    ["Update Service"]="students-update-service-spring"
    ["Delete Service"]="students-delete-service-spring"
)

print_header "Iniciando pruebas unitarias de todos los servicios"

# Ejecutar pruebas para cada servicio
for service_name in "${!services[@]}"; do
    service_dir="${services[$service_name]}"
    total_services=$((total_services + 1))
    
    if run_service_tests "$service_name" "$service_dir"; then
        passed_services=$((passed_services + 1))
    fi
done

# Mostrar resumen final
show_summary $total_services $passed_services

# Establecer el código de salida
if [ $passed_services -eq $total_services ]; then
    exit 0
else
    exit 1
fi 