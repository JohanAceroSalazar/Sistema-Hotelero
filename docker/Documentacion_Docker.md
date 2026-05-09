# 🐳 Docker Compose - Sistema Hotelero con PostgreSQL y Liquibase

## 📌 Descripción
El archivo `docker-compose.yml` levanta dos servicios principales:

- **PostgreSQL**: Base de datos del sistema hotelero  
- **Liquibase**: Herramienta para gestionar y versionar la base de datos  

---

## ⚙️ Configuración del Docker Compose

```yaml
services:

  postgres:
    image: postgres:15
    container_name: sistema_hotelero
    restart: always
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: sistema_hotelero
      POSTGRES_DB: sistema_hotelero
    ports:
      - "5436:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

  liquibase:
    image: liquibase/liquibase
    container_name: liquibase_hotel
    depends_on:
      - postgres
    volumes:
      - ./:/liquibase/changelog
      - ./postgresql-42.7.9.jar:/liquibase/lib/postgresql.jar
    working_dir: /liquibase/changelog
    command: >
      --url=jdbc:postgresql://postgres:5432/sistema_hotelero
      --username=postgres
      --password=sistema_hotelero
      --driver=org.postgresql.Driver
      --changeLogFile=changelog-master.yaml
      update

volumes:
  postgres_data:
```

## Conexion

- PostgreSQL: `localhost:5436`
- Base: `sistema_hotelero`
- Usuario: `postgres`
- Contraseña: `sistema_hotelero`

## Arranque

Desde la raiz de este repo:

### Levantar los contenedores
```
docker compose up -d
```

### Ejecutar cambios nuevos:

```
docker compose run liquibase
```