# Servicio de Base de Datos MariaDB

Servicio de base de datos centralizada para todos los microservicios de estudiantes.

## Estructura del Proyecto

```
.
├── k8s/                          # Manifiestos de Kubernetes
│   ├── deployment.yaml
│   ├── service.yaml
│   └── persistent-volume.yaml
├── docker-compose.yml           # Configuración de Docker Compose
└── README.md
```

## Configuración

### Detalles de Conexión
- **Puerto**: 3306
- **Base de datos**: studentsdb
- **Usuario**: root
- **Contraseña**: root

### Esquema de Base de Datos

```sql
CREATE TABLE students (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    age INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

### Docker Compose
```yaml
version: '3.8'

services:
  mariadb:
    image: mariadb:10.6
    environment:
      - MYSQL_ROOT_PASSWORD=root
      - MYSQL_DATABASE=studentsdb
    ports:
      - "3306:3306"
    volumes:
      - mariadb_data:/var/lib/mysql

volumes:
  mariadb_data:
```

## Despliegue

### Docker
```bash
# Iniciar el servicio
docker compose up -d

# Detener el servicio
docker compose down

# Detener y eliminar volúmenes
docker compose down -v
```

### Kubernetes
```bash
# Crear recursos
kubectl apply -f k8s/

# Eliminar recursos
kubectl delete -f k8s/
```

## Persistencia de Datos

- Los datos se almacenan en un volumen Docker o PersistentVolume de Kubernetes
- Se mantiene la persistencia entre reinicios
- Backup automático no configurado (se recomienda implementar)

## Monitoreo

- Logs disponibles a través de Docker/Kubernetes
- Métricas básicas de MariaDB habilitadas
- Se recomienda configurar herramientas de monitoreo adicionales

## Seguridad

- Contraseña de root configurada por variable de entorno
- Puerto expuesto solo para desarrollo (se recomienda restringir en producción)
- Sin SSL configurado (se recomienda habilitar en producción)

## Mantenimiento

### Backup Manual
```bash
# Crear backup
docker exec mariadb-service_mariadb_1 mysqldump -u root -proot studentsdb > backup.sql

# Restaurar backup
docker exec -i mariadb-service_mariadb_1 mysql -u root -proot studentsdb < backup.sql
```

### Acceso al CLI
```bash
docker exec -it mariadb-service_mariadb_1 mysql -u root -proot studentsdb
```

## Consideraciones

- Servicio compartido por todos los microservicios
- Punto único de fallo (considerar replicación en producción)
- Escalamiento vertical disponible
- Se recomienda implementar:
  - Replicación master-slave
  - Backup automático
  - Monitoreo avanzado
  - SSL/TLS
  - Políticas de retención de logs
  - Usuarios específicos por servicio 