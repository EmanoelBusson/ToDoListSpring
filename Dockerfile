# Use a Java 21 base image for the build stage
# This simplifies things as Java 21 and Maven are likely pre-installed or easily configured.
FROM openjdk:21 as build

# Update package lists and install Maven.
# If openjdk:21 doesn't come with maven, this is needed.
# Many openjdk images are slim, so maven might not be there.
RUN apt-get update && apt-get install -y maven

# Set the working directory inside the container
WORKDIR /app

# Copy your project files into the build stage
# This should be done before running mvn clean install
COPY . .

# Build your Maven project
# The error was here because Java 17 was trying to compile Java 21 code
RUN mvn clean install

# --- Production Stage ---
# Use a slim Java 21 runtime image for the final application
FROM openjdk:21-jdk-slim

# Set the working directory for the application
WORKDIR /app

# Expose the port your Spring Boot application runs on
EXPOSE 8083

# Copy the built JAR from the build stage to the production stage
COPY --from=build /app/target/todolist-1.0.0.jar app.jar

# Define the command to run your application
ENTRYPOINT ["java", "-jar", "app.jar"]