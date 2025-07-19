# Stage 1: Desarrollo, construir la aplicacion.
# Usamos Maven con Java 17
FROM maven:3.9.5-eclipse-temurin-17-alpine AS builder

# Asignamos el directorio de trabajo.
WORKDIR /app

# Se copian el pom.xml
COPY pom.xml .

# Se copia el codigo fuente
COPY src ./src

RUN mvn clean package -DskipTests

# Stage 2: Crear la imagen de producción.
FROM open-liberty:kernel-slim-java17-openj9 AS prod

USER root

RUN apt-get update && apt-get install -y net-tools && rm -rf /var/lib/apt/lists/*

RUN featureUtility installFeature \
    jakartaee-10.0 \
    microprofile-7.0 \
    passwordUtilities-1.1 \
    ssl-1.0


COPY server.xml /opt/ol/wlp/usr/servers/defaultServer/

COPY --from=builder /app/target/openliberty-mongo-app.war /opt/ol/wlp/usr/servers/defaultServer/apps/

COPY certs/truststore.p12 /opt/ol/wlp/output/defaultServer/resources/security/truststore.p12

EXPOSE 9080

CMD ["server", "run", "defaultServer"]
