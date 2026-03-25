# Building Repose Docker Image with Java 11

This guide explains how to build a Docker image for Repose 9.1.0.5 with Java 11, which addresses CVE-2023-41993 and other Java 8 vulnerabilities.

## Quick Start (Recommended)

The easiest way to build the image is using the multi-stage Dockerfile that extracts Repose from the official image and rebases it on Java 11:

```bash
# Build the image
docker build -f Dockerfile-new -t repose:9.1.0.5-java11-patched .

# Run the container
docker-compose up -d
```

This approach:
- ✅ No need to build Repose from source
- ✅ Uses the official Repose 9.1.0.5 binaries
- ✅ Rebases on Eclipse Temurin 11 JRE (secure, LTS)
- ✅ Maintains all Repose functionality

## What This Does

The Dockerfile uses a multi-stage build:

1. **Stage 1 (Extractor)**: Pulls the official `rackerlabs/repose:9.1.0.5` image and extracts:
   - Repose JAR files from `/usr/share/repose`
   - Configuration files from `/etc/repose`
   - Runtime directories from `/var/repose` and `/var/log/repose`

2. **Stage 2 (Final Image)**: 
   - Starts with `eclipse-temurin:11-jre-jammy` (Ubuntu 22.04 LTS with Java 11)
   - Copies extracted Repose files
   - Configures logging for Docker (stdout/stderr)
   - Sets up proper permissions and security

## Prerequisites

- Docker installed and running
- Internet connection (to pull base images)

## Build Commands

### Using Docker Directly

```bash
# Build the image
docker build -f Dockerfile-new -t repose:9.1.0.5-java11-patched .

# Run with docker run
docker run -d \
  --name repose \
  -p 8080:8080 \
  -v /etc/repose:/etc/repose \
  -v /usr/share/repose/filters:/usr/share/repose/filters \
  -e JAVA_OPTS="-Xmx1024m" \
  repose:9.1.0.5-java11-patched
```

### Using Docker Compose (Recommended)

```bash
# Build and run
docker-compose up -d

# View logs
docker-compose logs -f

# Stop
docker-compose down
```

## Verification

### Check Java Version

```bash
docker run --rm repose:9.1.0.5-java11-patched java -version
```

Expected output:
```
openjdk version "11.0.x" 2024-xx-xx
OpenJDK Runtime Environment Temurin-11.0.x+x (build 11.0.x+x)
OpenJDK 64-Bit Server VM Temurin-11.0.x+x (build 11.0.x+x, mixed mode)
```

### Check Container Health

```bash
# Check if container is running
docker ps | grep repose

# Check logs
docker logs repose

# Test endpoint (if configured)
curl http://localhost:8080
```

### Verify CVE Fix

The image uses Java 11, which is not affected by CVE-2023-41993. You can verify by:

1. Checking the Java version (shown above)
2. Running a security scanner on the image:
   ```bash
   docker scan repose:9.1.0.5-java11-patched
   ```

## What Changed

### Security Improvements
- **Java Version**: Upgraded from OpenJDK 8 to Eclipse Temurin 11 JRE
- **Base OS**: Updated from Ubuntu 18.04 to Ubuntu 22.04 LTS (Jammy)
- **CVE Fixed**: CVE-2023-41993 and other Java 8 vulnerabilities
- **LTS Support**: Both Java 11 and Ubuntu 22.04 have long-term support

### Docker Best Practices
- Multi-stage build for smaller final image
- Non-root user (repose) for security
- Health check included
- Logs to stdout/stderr (Docker-friendly)
- OpenShift compatible (arbitrary user ID support)

## Configuration

### Environment Variables

- `JAVA_OPTS`: JVM options (e.g., `-Xmx1024m -Xms512m`)
- `APP_ROOT`: Repose config directory (default: `/etc/repose`)
- `APP_VARS`: Repose var directory (default: `/var/repose`)
- `APP_LOGS`: Repose log directory (default: `/var/log/repose`)

### Volumes

Mount these directories to persist configuration and data:

```bash
docker run -d \
  -v /path/to/config:/etc/repose \
  -v /path/to/filters:/usr/share/repose/filters \
  repose:9.1.0.5-java11-patched
```

### Ports

- `8080`: Default Repose service port (configurable in system-model.cfg.xml)

## Troubleshooting

### Build fails with "manifest unknown"

The official Repose image might not be available. Check:
```bash
docker pull rackerlabs/repose:9.1.0.5
```

If unavailable, you'll need to build Repose from source first (see Alternative Build Method below).

### Container fails to start

Check logs:
```bash
docker logs repose
```

Common issues:
- Missing configuration files in `/etc/repose`
- Port 8080 already in use
- Insufficient memory (increase with `JAVA_OPTS=-Xmx2048m`)

### Java version mismatch

Ensure you're checking the right container:
```bash
docker run --rm repose:9.1.0.5-java11-patched java -version
```

## Alternative Build Method (From Source)

If you need to build Repose from source with Java 11:

### Prerequisites
- Java 11 or later installed
- Gradle (included via wrapper)

### Steps

1. **Build Repose packages**:
   ```bash
   ./gradlew clean buildAll
   ```

2. **Create a Dockerfile that uses local packages**:
   ```dockerfile
   FROM eclipse-temurin:11-jre-jammy
   
   # Copy and install .deb packages
   COPY repose-aggregator/artifacts/*/build/distributions/*.deb /tmp/packages/
   RUN dpkg -i /tmp/packages/*.deb || apt-get install -f -y
   
   # ... rest of configuration
   ```

3. **Build the image**:
   ```bash
   docker build -t repose:9.1.0.5-java11-source .
   ```

Note: This method requires fixing build.gradle dependencies (JCenter shutdown issues).

## Additional Resources

- [Eclipse Temurin](https://adoptium.net/) - Official Java distribution
- [Repose Documentation](http://www.openrepose.org/)
- [CVE-2023-41993 Details](https://nvd.nist.gov/vuln/detail/CVE-2023-41993)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)

## Support

For issues:
1. Check Docker logs: `docker logs repose`
2. Verify Java version in container
3. Ensure base images are accessible
4. Check Repose configuration files

---
**Security Note**: This image addresses CVE-2023-41993 by using Java 11. Always keep your images updated and scan regularly for vulnerabilities.
