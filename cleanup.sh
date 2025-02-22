#!/bin/bash

# Function to prompt user for confirmation
confirm() {
    read -p "$1 (y/N): " response
    case "$response" in
        [yY][eE][sS]|[yY])
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Ask user whether to use Docker or Podman
read -p "Are you using Docker or Podman? (docker/podman): " engine
if [[ "$engine" != "docker" && "$engine" != "podman" ]]; then
    echo "Invalid input. Please enter 'docker' or 'podman'."
    exit 1
fi

echo "Checking current disk usage..."
$engine system df

echo ""

if confirm "Do you want to remove unused images, containers, networks, and build cache?"; then
    $engine system prune -a --volumes
fi

echo ""

if confirm "Do you want to remove all images?"; then
    $engine rmi $($engine images -q) -f
fi

echo ""

if confirm "Do you want to remove all stopped containers?"; then
    $engine rm $($engine ps -a -q)
fi

echo ""

if confirm "Do you want to remove all volumes?"; then
    $engine volume rm $($engine volume ls -q)
fi

echo ""

if confirm "Do you want to completely reset $engine configuration? (This will delete ~/.docker or ~/.config/containers)"; then
    if [[ "$engine" == "docker" ]]; then
        rm -rf ~/.docker
    else
        rm -rf ~/.config/containers
    fi
fi

echo "Cleanup completed! Check your disk space again using '$engine system df'."
