#!/bin/bash

#clear terminal
clear

# Change directory to docker-env
cd /var/www/docker-dir

# Function to start Docker container
start_container() {
    if [ -n "$(docker ps -aqf "status=exited")" ]; then
        echo "Docker containers starting..."
        docker start $(docker ps -aqf "status=exited")
    else
        echo "Docker containers already started"
    fi
}

# Function to stop Docker container
stop_container() {
    if [ -n "$(docker ps -q)" ]; then
        echo "Docker containers stopping..."
        docker stop $(docker ps -q)
    else
        echo "Docker containers already stopped"
    fi
}

# Function to restart Docker container
restart_container() {
    if [ -n "$(docker ps -q)" ]; then
        echo "Docker containers restarting..."
        docker restart $(docker ps -q)
    else
        start_container
    fi
}

# Function to bring down and then bring up Docker containers
reload_containers() {
    echo "Bringing down Docker containers..."
    docker-compose -f docker-compose.yml -f docker-compose.override.yml down

    echo "Bringing up Docker containers in detached mode..."
    docker-compose -f docker-compose.yml -f docker-compose.override.yml up -d

    PHPSTORM_CONTAINER=$(docker ps -a --filter "name=phpstorm_helpers" --format '{{.Names}}')

    if [ -n "$PHPSTORM_CONTAINER" ]; then
        echo "PhpStorm helper up docker container..."
        docker start "${PHPSTORM_CONTAINER}"
    fi
}

# Function to bring down and then bring up Docker containers
rebuild_containers() {
    echo "Docker build stating..."
    stop_container

    echo "Removing exited Docker containers..."
    docker rm $(docker ps -aqf "status=exited")

    echo "build Docker containers..."
    docker-compose -f docker-compose.yml -f docker-compose.override.yml up -d --build
    #docker-compose -f docker-compose.yml -f docker-compose.override.yml build --no-cache
    echo "Docker build successfully."
}

# Function to clear cache for Docker containers
clear_docker_cache() {
    echo "Clearing Docker build cache..."
    stop_container
    echo "Clearing Docker build cache..."
    docker builder prune -f
    echo "Clearing stopped containers, networks, build cache, and dangling images..."
    docker system prune -a -f
    docker image prune -a -f
    reload_containers
    echo "Docker cache cleared successfully."
}

# Check if Docker is running
if docker info > /dev/null 2>&1; then
    echo "Docker is running..."
else
    "/mnt/c/Program Files/Docker/Docker/Docker Desktop.exe"
    echo "Waiting for Docker Desktop to start... Please be patient."
    sleep 25
fi

echo "Select docker operation:"
echo "1. Start"
echo "2. Stop"
echo "3. Restart"
echo "4. Reload"
echo "5. Clear Cache"
echo "6. Rebuild"

read operation

case $operation in
    1)
        start_container
        ;;
    2)
        stop_container
        exit
        ;;
    3)
        restart_container
        ;;
    4)
        reload_containers
        ;;
    5)
        clear_docker_cache
        ;;
    6)
        rebuild_containers
        ;;
    *)
        start_container
        ;;
esac

#clear terminal
clear

echo "Select PHP bash:"
echo "1. PHP bash"

read operation2

#clear terminal
clear

case $operation2 in
    1)
        echo "Welcome to Docker PHP 8.3 bash !!!"
        # Run docker exec command
        docker exec -it docker-env-php bash
        ;;
    *)
        exit
        ;;
esac
