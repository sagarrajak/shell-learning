#!/bin/bash

# Exercise 3.1 Solution: User Information Collector
# Task: Create a script that asks for user info, calculates birth year, and prints personalized message

set -euo pipefail

# Configuration
CURRENT_YEAR=$(date +%Y)

# Ask for user information
echo "================================================"
echo "       User Information Collection"
echo "================================================"
echo ""

# Get user name
echo -n "Enter your name: "
read name

# Get user age
echo -n "Enter your age: "
read age

# Validate age
while ! [[ "$age" =~ ^[0-9]+$ ]] || [ "$age" -lt 1 ] || [ "$age" -gt 150 ]; do
    echo "Please enter a valid age (1-150): "
    read age
done

# Get favorite color
echo -n "Enter your favorite color: "
read color

# Calculate birth year
birth_year=$((CURRENT_YEAR - age))

# Get current date and time
current_date=$(date +"%A, %B %d, %Y")
current_time=$(date +"%H:%M:%S")

# Display personalized message
echo ""
echo "================================================"
echo "           Personal Information"
echo "================================================"
echo ""
echo "Name: $name"
echo "Age: $age years old"
echo "Favorite Color: $color"
echo ""
echo "Birth Year: $birth_year"
echo "(Calculated based on current year: $CURRENT_YEAR)"
echo ""
echo "Current Date: $current_date"
echo "Current Time: $current_time"
echo ""
echo "================================================"
echo "Welcome, $name!"
echo ""
echo "Your favorite color is $color."
echo "You were born in $birth_year."
echo "That's $(($CURRENT_YEAR - 1980)) years ago!"
echo ""
echo "Thank you for using this script, $name!"
echo "================================================"

# Additional fun facts
echo ""
echo "Fun Facts about the number $age:"
echo "  - $age in binary is: $(echo "obase=2; $age" | bc)"
echo "  - $age in hex is: $(printf '%x' "$age")"
if [ $((age % 2)) -eq 0 ]; then
    echo "  - $age is an even number"
else
    echo "  - $age is an odd number"
fi
