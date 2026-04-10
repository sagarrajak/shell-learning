#!/bin/bash

# Exercise 4.1 Solution: Calculator Script
# Task: Create a calculator that accepts two numbers and an operator as arguments

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to display usage
usage() {
    echo "Calculator Script"
    echo "Usage: $0 <number1> <operator> <number2>"
    echo ""
    echo "Operators:"
    echo "  +   Addition"
    echo "  -   Subtraction"
    echo "  *   Multiplication"
    echo "  /   Division"
    echo "  %   Modulus"
    echo "  ^   Power"
    echo ""
    echo "Examples:"
    echo "  $0 10 + 5"
    echo "  $0 100 / 3"
    echo "  $0 2 ^ 8"
    exit 1
}

# Function to perform calculation
calculate() {
    local num1="$1"
    local operator="$2"
    local num2="$3"
    local result
    
    case "$operator" in
        +)
            result=$((num1 + num2))
            echo "$num1 + $num2 = $result"
            ;;
        -)
            result=$((num1 - num2))
            echo "$num1 - $num2 = $result"
            ;;
        \*)
            result=$((num1 * num2))
            echo "$num1 * $num2 = $result"
            ;;
        /)
            if [ "$num2" -eq 0 ]; then
                echo -e "${RED}Error: Division by zero!${NC}" >&2
                return 1
            fi
            result=$((num1 / num2))
            local remainder=$((num1 % num2))
            echo "$num1 / $num2 = $result (remainder: $remainder)"
            ;;
        %)
            if [ "$num2" -eq 0 ]; then
                echo -e "${RED}Error: Modulus by zero!${NC}" >&2
                return 1
            fi
            result=$((num1 % num2))
            echo "$num1 % $num2 = $result"
            ;;
        ^)
            # Calculate power
            result=1
            for ((i=0; i<num2; i++)); do
                result=$((result * num1))
            done
            echo "$num1 ^ $num2 = $result"
            ;;
        *)
            echo -e "${RED}Error: Unknown operator '$operator'${NC}" >&2
            return 1
            ;;
    esac
    
    return 0
}

# Check for arguments
if [ $# -ne 3 ]; then
    echo -e "${RED}Error: Invalid number of arguments${NC}"
    usage
fi

num1="$1"
operator="$2"
num2="$3"

# Validate inputs
if ! [[ "$num1" =~ ^-?[0-9]+$ ]]; then
    echo -e "${RED}Error: First argument must be an integer${NC}" >&2
    exit 1
fi

if ! [[ "$num2" =~ ^-?[0-9]+$ ]]; then
    echo -e "${RED}Error: Third argument must be an integer${NC}" >&2
    exit 1
fi

# Display header
echo ""
echo "================================================"
echo "           Simple Calculator"
echo "================================================"
echo ""

# Perform calculation
calculate "$num1" "$operator" "$num2"

exit_code=$?

echo ""
echo "================================================"

exit $exit_code
