#!/bin/bash

### This script prints system info ###

echo "Welcome to bash script."
echo

# Displaying system uptime
echo "###################"
echo "System Uptime:"
uptime
echo

# Memory Utilization
echo "###################"
echo "Memory Utilization:"
free -m
echo

# Disk Utilization
echo "###################"
echo "Disk Utilization:"
df -h
