# Use official OpenJDK image as the base image
FROM openjdk:17

# Set the working directory in the container
WORKDIR /app

# Copy the packaged JAR file into the container
COPY target/todo-0.0.1-SNAPSHOT.jar app.jar


# Expose port 8080 to the outside world
EXPOSE 8080

# Command to run the Spring Boot application
CMD ["java", "-jar", "app.jar"]
