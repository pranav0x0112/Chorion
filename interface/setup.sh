#!/bin/bash

echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y

echo "Installing required packages..."
sudo apt install -y python3 python3-pip python3-venv git

echo "Setting up a virtual environment..."
python3 -m venv venv
source venv/bin/activate

echo "Installing Python dependencies..."
pip install --upgrade pip
pip install -r ../py/requirements.txt

echo "Setup complete! To activate the virtual environment, run: source venv/bin/activate"
