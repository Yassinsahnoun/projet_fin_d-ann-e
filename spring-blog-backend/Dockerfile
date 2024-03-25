FROM maven:3.8.4-openjdk-11 AS builder

WORKDIR /app

COPY . .

RUN mvn dependency:resolve

FROM adoptopenjdk:11-jre-hotspot

WORKDIR /app

COPY --from=builder /app/target/spring-blog-backend-0.0.1-SNAPSHOT.jar /app/spring-blog-backend.jar

EXPOSE 8080

CMD ["java", "-jar", "spring-blog-backend.jar"]