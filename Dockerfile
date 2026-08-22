# Build the WAR with the Maven wrapper.
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /src
COPY pom.xml mvnw ./
COPY .mvn .mvn
RUN ./mvnw -B -q dependency:go-offline || true
COPY src src
RUN ./mvnw -B package -DskipTests

# Serve it on Tomcat 9 against the compose-provided MySQL.
FROM tomcat:9.0-jdk17-temurin
COPY --from=build /src/target/train-schedule.war /usr/local/tomcat/webapps/train-schedule.war
ENV DB_URL=jdbc:mysql://db:3306/trains \
    DB_USER=root \
    DB_PASSWORD=root
EXPOSE 8080
