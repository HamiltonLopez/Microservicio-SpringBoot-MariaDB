# Microservicios de Gestión de Estudiantes

Este proyecto implementa una arquitectura de microservicios para la gestión de estudiantes, utilizando Spring Boot, MariaDB, Docker y Kubernetes.

## Estructura del Proyecto

```
.
├── mariadb-service/               # Servicio de base de datos
├── students-create-service-spring/  # Servicio de creación de estudiantes
├── students-get-service-spring/     # Servicio de listado de estudiantes
├── students-getbyid-service-spring/ # Servicio de obtención de estudiante por ID
├── students-update-service-spring/  # Servicio de actualización de estudiantes
├── students-delete-service-spring/  # Servicio de eliminación de estudiantes
├── docker-compose-spring.yml      # Compose file para todos los servicios
└── test-spring-services.sh       # Script de prueba de servicios
```

## Servicios Disponibles

### Base de Datos (MariaDB)
- Puerto: 3306
- Base de datos: studentsdb
- Usuario por defecto: root
- Contraseña por defecto: root

### Microservicios

| Servicio   | Puerto | Endpoint             | Método | Descripción                    |
|------------|--------|---------------------|---------|--------------------------------|
| Create     | 8081   | /api/students       | POST    | Crear nuevo estudiante         |
| Get All    | 8082   | /api/students       | GET     | Listar todos los estudiantes   |
| Get By ID  | 8083   | /api/students/{id}  | GET     | Obtener estudiante por ID      |
| Update     | 8084   | /api/students/{id}  | PUT     | Actualizar estudiante          |
| Delete     | 8085   | /api/students/{id}  | DELETE  | Eliminar estudiante            |

## Modelo de Datos

```json
{
  "id": "long",
  "name": "string",
  "email": "string",
  "age": "integer"
}
```

## Requisitos

- Java 17
- Docker
- Kubernetes (opcional)
- Maven

## Configuración

### Docker Compose
Para ejecutar todos los servicios usando Docker Compose:

```bash
docker compose -f docker-compose-spring.yml up --build
```

### Kubernetes
Para desplegar en Kubernetes:

```bash
# Desplegar MariaDB
kubectl apply -f mariadb-service/k8s/

# Desplegar microservicios
   kubectl apply -f students-create-service-spring/k8s/
   kubectl apply -f students-get-service-spring/k8s/
   kubectl apply -f students-getbyid-service-spring/k8s/
   kubectl apply -f students-update-service-spring/k8s/
   kubectl apply -f students-delete-service-spring/k8s/
```

## Colección de Postman

Se incluye una colección de Postman (`students-microservices.postman_collection.json`) con todos los endpoints configurados para pruebas.

## Estructura de Submodules

Este repositorio utiliza Git submodules para manejar los diferentes servicios. Para clonar el repositorio completo:

```bash
git clone --recursive [URL_REPOSITORIO]
```

Para actualizar todos los submodules:

```bash
git submodule update --remote --merge
```

## Desarrollo Local

1. Clonar el repositorio con submodules
2. Iniciar MariaDB:
   ```bash
   docker compose -f mariadb-service/docker-compose.yml up -d
   ```
3. Ejecutar cada servicio individualmente:
   ```bash
   cd [service-directory]
   ./mvnw spring-boot:run
   ```

## Pruebas

Se incluye un script de prueba (`test-spring-services.sh`) que verifica el funcionamiento de todos los servicios.

Para ejecutar las pruebas:
```bash
./test-spring-services.sh
``` 