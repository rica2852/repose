@echo off
REM Build script for Repose Docker image with Java 11
REM This script builds the Repose packages and Docker image

echo =========================================
echo Building Repose with Java 11
echo =========================================
echo.

REM Check if Java is available
java -version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Java is not installed or not in PATH
    echo Please install Java 11+ and add it to your PATH
    exit /b 1
)

echo Checking Java version...
java -version
echo.

REM Step 1: Clean and build packages
echo Step 1: Building Repose packages...
call gradlew.bat clean buildAll

if errorlevel 1 (
    echo ERROR: Gradle build failed
    exit /b 1
)

echo [OK] Packages built successfully
echo.

REM Step 2: Build Docker image
echo Step 2: Building Docker image...
docker build -f Dockerfile-new -t repose:9.1.0.5-java11-patched .

if errorlevel 1 (
    echo ERROR: Docker build failed
    exit /b 1
)

echo [OK] Docker image built successfully
echo.

REM Step 3: Verify
echo Step 3: Verifying image...
docker images | findstr repose

echo.
echo =========================================
echo Build completed successfully!
echo =========================================
echo.
echo To run the container:
echo   docker-compose up -d
echo.
echo Or:
echo   docker run -d -p 8080:8080 --name repose repose:9.1.0.5-java11-patched
echo.
echo To verify Java version:
echo   docker run --rm repose:9.1.0.5-java11-patched java -version
echo.
