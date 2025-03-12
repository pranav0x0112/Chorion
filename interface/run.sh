#! /bin/bash

clear
echo "Welcome to world of ChaCha20! Choose an option to continue."
echo "1) Shell Interface"
echo "2) Web Interface"
read -p "Enter your choice: " choice

if [ "$choice" == 1 ]; then
    echo "Running Shell Interface..."
    ./shell_interface.sh
elif [ "$choice" == 2 ]; then
    echo "Running Web Interface..."
    ./web_interface.sh
else
    echo "Invalid choice! Exiting..."
fi