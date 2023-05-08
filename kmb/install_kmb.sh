#!/bin/bash

# This script installs the Kernel Module Builder and Tester application with the alias name "kmb".

# Set the installation directory
INSTALL_DIR=/usr/local/bin

# Copy the script to the installation directory
cp /src/kernelmodbuilder.sh $INSTALL_DIR

# Create an alias in bashrc
echo "alias kmb='$INSTALL_DIR/kernelmodbuilder.sh'" >> ~/.bashrc

# Apply the changes to the current session
source ~/.bashrc

# Display a message to the user
echo "Kernel Module Builder and Tester has been installed with the alias name 'kmb'. To use the application, type 'kmb' in your terminal."
