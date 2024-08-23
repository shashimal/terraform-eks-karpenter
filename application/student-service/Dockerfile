
# Use the official Maven image to build the Spring Boot application
FROM maven:3.8.4-openjdk-17 AS build

# Set the working directory inside the container
WORKDIR /app

# Copy the pom.xml file to the container first, to leverage Docker caching
COPY pom.xml .

# Download the project dependencies specified in the pom.xml
RUN mvn dependency:go-offline

# Copy the entire source code to the container
COPY . .

# Build the Spring Boot application with Maven (you can specify profiles if needed)
RUN mvn package -DskipTests

# Use the official OpenJDK 17 image as the base image for the final runtime image
FROM openjdk:17-jdk

#ARG JAR_FILE=student-service-0.0.1-SNAPSHOT.jar

# Set the working directory inside the container
WORKDIR /app

# Copy the Spring Boot application JAR file from the build stage to the final image
COPY --from=build /app/target/student-service-0.0.1-SNAPSHOT.jar /app/student-service-0.0.1-SNAPSHOT.jar

# Expose the port on which your Spring Boot application is running (change the port if needed)
EXPOSE 8080

# Command to run your Spring Boot application using the JAR file
CMD ["java", "-jar", "student-service-0.0.1-SNAPSHOT.jar"]

