# --- Build Stage ---
# Use a Debian-based OpenJDK 21 image for the build stage.
# 'openjdk:21-jdk' is the most common variant that includes apt-get.
FROM openjdk:21-jdk as build # <--- THIS LINE IS CRUCIAL FOR APT-GET

# Update package lists and install Maven.
# This will now work because openjdk:21-jdk has apt-get.
RUN apt-get update && apt-get install -y maven

# Set the working directory inside the container for the build
WORKDIR /app

# Copy your project files into the build stage
COPY . .

# Build your Maven project
RUN mvn clean install

# --- Production Stage ---
# Use a slim Java 21 runtime image for the final application.
FROM openjdk:21-jdk-slim

# Set the working directory for the application
WORKDIR /app

# Expose the port your Spring Boot application runs on
EXPOSE 8083

# Copy the built JAR from the build stage to the production stage
# As discussed, the standard path is /app/target/todolist-1.0.0.jar
COPY --from=build /app/target/todolist-1.0.0.jar app.jar

# Define the command to run your application
ENTRYPOINT ["java", "-jar", "app.jar"]