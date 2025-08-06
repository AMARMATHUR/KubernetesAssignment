@echo off
REM Configuration
set DOCKER_USERNAME=amarmathur
set IMAGE_NAME=employee-api
set TAG=latest

echo Building and pushing Employee API Docker image...

REM Navigate to the API directory
cd src\EmployeeService.API

REM Build Docker image
echo Building Docker image...
docker build -t %DOCKER_USERNAME%/%IMAGE_NAME%:%TAG% .

REM Push to Docker Hub
echo Pushing to Docker Hub...
docker push %DOCKER_USERNAME%/%IMAGE_NAME%:%TAG%

echo Docker image build and push completed!
echo Image: %DOCKER_USERNAME%/%IMAGE_NAME%:%TAG%

REM Go back to root directory
cd ..\..

pause
