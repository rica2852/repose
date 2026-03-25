# Quick Start Guide - Repose with Java 11

## TL;DR

```bash
# Build everything
./gradlew clean buildAll
docker build -f Dockerfile-new -t repose:9.1.0.5-java11-patched .

# Run
docker-compose up -d

# Verify
docker exec repose java -version
```

## What Was Fixed
- ✅ CVE-2023-41993 (Java 8 vulnerability)
- ✅ Upgraded to Java 11 (LTS)
- ✅ Updated to Ubuntu 22.04 LTS
- ✅ Using Eclipse Temurin (official OpenJDK distribution)

## Build Commands

### Windows
```cmd
build-docker.bat
```

### Linux/Mac
```bash
chmod +x build-docker.sh
./build-docker.sh
```

## Run Commands

### Using Docker Compose (Recommended)
```bash
docker-compose up -d
docker-compose logs -f
docker-compose down
```

### Using Docker Directly
```bash
docker run -d \
  --name repose \
  -p 8080:8080 \
  -v /etc/repose:/etc/repose \
  -e JAVA_OPTS="-Xmx1024m" \
  repose:9.1.0.5-java11-patched
```

## Verify Installation

```bash
# Check Java version
docker run --rm repose:9.1.0.5-java11-patched java -version

# Check container logs
docker logs repose

# Test endpoint
curl http://localhost:8080
```

## Troubleshooting

### "No such file or directory: *.deb"
Run `./gradlew buildAll` first to create the packages.

### "Java version mismatch"
Ensure Java 11+ is installed:
```bash
java -version
```

### Container won't start
Check logs:
```bash
docker logs repose
```

## File Changes
- ✏️ `build.gradle` - Java 11 compatibility
- ✏️ `gradle/wrapper/gradle-wrapper.properties` - Gradle 6.9.4
- ✏️ `docker-compose.yaml` - New build configuration
- ✏️ Performance test YAML files - Java 11
- ✨ `Dockerfile-new` - Java 11 Docker image
- ✨ Build scripts and documentation

## More Information
- Full details: `UPGRADE-SUMMARY.md`
- Docker build guide: `BUILD-DOCKER.md`
- Original Dockerfile: `Dockerfile` (Java 8 - deprecated)
