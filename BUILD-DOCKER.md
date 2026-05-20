# Docker Image: Build & History

## How It Originally Worked

The original Docker pipeline was fully integrated into Gradle via `com.bmuschko:gradle-docker-plugin`, defined in `repose-aggregator/artifacts/docker/build.gradle`. It supported two modes:

### From local packages ("file" mode)

The default during development. Gradle would:
1. Build DEB/RPM packages from the valve, filter-bundle, extensions-filter-bundle, and experimental-filter-bundle subprojects
2. Copy them into a staging directory alongside a Dockerfile
3. The Dockerfile installed them with `dpkg -R --install`

The source Dockerfiles still exist at:
- `repose-aggregator/artifacts/docker/src/docker/resources/file/ubuntu/Dockerfile`
- `repose-aggregator/artifacts/docker/src/docker/resources/file/centos/Dockerfile`

### From the package repository ("repo" mode)

Triggered by passing `-Prepose-version=X.X.X.X`. Used a different Dockerfile that pulled packages directly from `nexus.openrepose.org` via APT/Yum. No local build needed.

Source Dockerfiles:
- `repose-aggregator/artifacts/docker/src/docker/resources/repo/ubuntu/Dockerfile`
- `repose-aggregator/artifacts/docker/src/docker/resources/repo/centos/Dockerfile`

### Publish flow

Wired into the `:release` task. A full release would:
1. Build the image locally (Ubuntu and CentOS variants)
2. Tag as `rackerlabs/repose:<version>` and `rackerlabs/repose:latest`
3. Push to Docker Hub
4. Remove the local image

### What was in the image

Four packages were installed:
- `repose` — the valve fat JAR (`repose.jar`) + directory structure + configs
- `repose-filter-bundle` — EAR with standard filters → `/usr/share/repose/filters/`
- `repose-extensions-filter-bundle` — EAR → `/usr/share/repose/filters/`
- `repose-experimental-filter-bundle` — EAR → `/usr/share/repose/filters/`

Base: Ubuntu 18.04 + OpenJDK 8 (or CentOS 7 + java-1.8.0-openjdk).

---

## What Changed

The old pipeline depended on infrastructure that no longer exists (JCenter, the Nexus package repo, Docker Hub credentials). The new approach is a self-contained multi-stage `Dockerfile` at the repo root.

### New image details

| Aspect | Old | New |
|--------|-----|-----|
| Base OS | Ubuntu 18.04 / CentOS 7 | Ubuntu 22.04 (Jammy) |
| Java | OpenJDK 8 | Eclipse Temurin 11 JRE |
| Build method | Pre-built .deb/.rpm packages | Source build via Gradle in builder stage |
| Filter bundles | Installed via OS packages | Copied as EAR files from build output |
| Registry | `rackerlabs/repose` on Docker Hub | Local build only (no push configured) |

### Artifacts included

- `/usr/share/repose/repose.jar` — valve fat JAR (shadowJar)
- `/usr/share/repose/filters/*.ear` — filter-bundle, extensions-filter-bundle, experimental-filter-bundle
- `/etc/repose/*.xml`, `/etc/repose/*.cfg.xml` — default configs

---

## Building

```bash
docker build -t repose:9.1.0.5-java11 .
```

Or with compose:

```bash
docker-compose up -d
```

The build takes a while — it compiles the full project (Scala + Java) inside the builder stage. Tests are skipped (`-x test -x integrationTest`).

## Running

```bash
docker run -d \
  --name repose \
  -p 8080:8080 \
  -v /path/to/config:/etc/repose \
  -e JAVA_OPTS="-Xmx1024m" \
  repose:9.1.0.5-java11
```

### Environment variables

- `JAVA_OPTS` — JVM flags (memory, GC tuning, etc.)

### Volumes

- `/etc/repose` — mount your own system-model, configs, etc.

### Ports

- `8080` — default Repose service port (configurable in `system-model.cfg.xml`)

## Verification

```bash
# Check Java version
docker run --rm repose:9.1.0.5-java11 java -version

# Check logs
docker logs repose
```

## Reference Files

- `Dockerfile` — the current production Dockerfile
- `docker-compose.yaml` — convenience compose file
- `repose-aggregator/artifacts/docker/` — original Gradle-based Docker build (still in tree, not used)
- `repose-aggregator/artifacts/docker/src/docker/resources/` — the original Dockerfiles for Ubuntu and CentOS variants
