#!/bin/bash

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root or with sudo"
    exit 1
fi

# Function to display disk usage
display_disk_usage() {
    echo "Disk usage on /:"
    df -h /
    echo
}

echo -e "\033[1;33mStarting system cleanup...\033[0m"

# Display disk usage before cleanup
echo -e "\n\033[1;34m=== Before cleanup ===\033[0m"
display_disk_usage

# Docker cleanup
if command -v docker &> /dev/null; then
    echo -e "\033[1;32mCleaning up Docker...\033[0m"
    
    # Stop all running containers
    echo "Stopping running containers..."
    docker stop $(docker ps -q) 2>/dev/null || echo "No running containers to stop"

    # Perform system prune
    echo "Pruning Docker system..."
    docker system prune --all --force --volumes

    # Clean volumes
    echo "Pruning volumes..."
    docker volume prune --force

    # Clean Docker Compose builds
    if command -v docker-compose &> /dev/null; then
        echo "Cleaning Docker Compose build cache..."
        docker-compose build --force-rm --no-cache --pull 2>/dev/null || true
        docker-compose down --volumes --rmi all 2>/dev/null || true
    fi

    # Clean Docker logs
    echo "Truncating Docker logs..."
    find /var/lib/docker/containers/ -name '*.log' -exec truncate -s 0 {} \; 2>/dev/null
else
    echo -e "\033[1;31mDocker not found. Skipping Docker cleanup.\033[0m"
fi

# APT cleanup
echo -e "\n\033[1;32mCleaning up APT packages...\033[0m"
apt-get clean
apt-get autoremove --purge -y
apt-get autoclean

# Clean kernel packages
echo "Removing old kernels..."
dpkg -l | grep -E 'linux-(image|modules|headers)-[0-9]+' | 
awk '{print $2}' | 
grep -v $(uname -r | sed 's/-generic//') | 
xargs sudo apt-get purge -y 2>/dev/null || true

# Clean temporary directories
echo -e "\n\033[1;32mCleaning temporary files...\033[0m"
rm -rf /tmp/* /var/tmp/* /var/cache/apt/* 2>/dev/null || true

# Clean journal logs
echo "Cleaning journal logs..."
journalctl --rotate 2>/dev/null || true
journalctl --vacuum-time=1d 2>/dev/null || true

# Clean thumbnail cache
echo "Cleaning thumbnail cache..."
rm -rf ~/.cache/thumbnails/* /root/.cache/thumbnails/* 2>/dev/null || true

# Display disk usage after cleanup
echo -e "\n\033[1;34m=== After cleanup ===\033[0m"
display_disk_usage

echo -e "\n\033[1;33mCleanup completed!\033[0m"#!/bin/bash

# Check if running as root
if [ "$EUID" -ne 0 ]; then
	    echo "Please run as root or with sudo"
	        exit 1
fi

# Function to display disk usage
display_disk_usage() {
	    echo "Disk usage on /:"
	        df -h /
		    echo
	    }

	    echo -e "\033[1;33mStarting system cleanup...\033[0m"

	    # Display disk usage before cleanup
	    echo -e "\n\033[1;34m=== Before cleanup ===\033[0m"
	    display_disk_usage

	    # Docker cleanup
	    if command -v docker &> /dev/null; then
		        echo -e "\033[1;32mCleaning up Docker...\033[0m"
			    
			    # Stop all running containers
			        echo "Stopping running containers..."
				    docker stop $(docker ps -q) 2>/dev/null || echo "No running containers to stop"

				        # Perform system prune
					    echo "Pruning Docker system..."
					        docker system prune --all --force --volumes

						    # Clean volumes
						        echo "Pruning volumes..."
							    docker volume prune --force

							        # Clean Docker Compose builds
								    if command -v docker-compose &> /dev/null; then
									            echo "Cleaning Docker Compose build cache..."
										            docker-compose build --force-rm --no-cache --pull 2>/dev/null || true
											            docker-compose down --volumes --rmi all 2>/dev/null || true
												        fi

													    # Clean Docker logs
													        echo "Truncating Docker logs..."
														    find /var/lib/docker/containers/ -name '*.log' -exec truncate -s 0 {} \; 2>/dev/null
													    else
														        echo -e "\033[1;31mDocker not found. Skipping Docker cleanup.\033[0m"
	    fi

	    # APT cleanup
	    echo -e "\n\033[1;32mCleaning up APT packages...\033[0m"
	    apt-get clean
	    apt-get autoremove --purge -y
	    apt-get autoclean

	    # Clean kernel packages
	    echo "Removing old kernels..."
	    dpkg -l | grep -E 'linux-(image|modules|headers)-[0-9]+' | 
		    awk '{print $2}' | 
		    grep -v $(uname -r | sed 's/-generic//') | 
		    xargs sudo apt-get purge -y 2>/dev/null || true

	    # Clean temporary directories
	    echo -e "\n\033[1;32mCleaning temporary files...\033[0m"
	    rm -rf /tmp/* /var/tmp/* /var/cache/apt/* 2>/dev/null || true

	    # Clean journal logs
	    echo "Cleaning journal logs..."
	    journalctl --rotate 2>/dev/null || true
	    journalctl --vacuum-time=1d 2>/dev/null || true

	    # Clean thumbnail cache
	    echo "Cleaning thumbnail cache..."
	    rm -rf ~/.cache/thumbnails/* /root/.cache/thumbnails/* 2>/dev/null || true

	    # Display disk usage after cleanup
	    echo -e "\n\033[1;34m=== After cleanup ===\033[0m"
	    display_disk_usage

	    echo -e "\n\033[1;33mCleanup completed!\033[0m"
