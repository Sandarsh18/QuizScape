# Use Flutter stable with Dart 3
FROM ghcr.io/cirruslabs/flutter:stable

# Set working directory
WORKDIR /app

# Copy pubspec first for caching
COPY pubspec.* /app/

# Get dependencies
RUN flutter pub get

# Copy rest of the project
COPY . /app

# Expose port for web
EXPOSE 8080

# Run Flutter web server
CMD ["flutter", "run", "-d", "web-server", "--web-port=8080", "--web-hostname=0.0.0.0"]
