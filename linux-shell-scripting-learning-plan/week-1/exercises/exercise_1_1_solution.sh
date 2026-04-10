#!/bin/bash

# Exercise 1.1 Solution: Directory Structure Creation
# Task: Create a directory structure for a web application

set -euo pipefail

# Configuration
BASE_DIR="${HOME}/webapp"

echo "Creating web application directory structure..."
echo "Base directory: $BASE_DIR"
echo ""

# Create main directories
mkdir -p "${BASE_DIR}/config"
mkdir -p "${BASE_DIR}/logs"
mkdir -p "${BASE_DIR}/scripts"
mkdir -p "${BASE_DIR}/public/css"
mkdir -p "${BASE_DIR}/public/js"
mkdir -p "${BASE_DIR}/public/images"

echo "Created main directories:"

# Create sample configuration file
cat > "${BASE_DIR}/config/app.conf" <<'EOF'
# Application Configuration
APP_NAME="My Web Application"
APP_VERSION="1.0.0"
ENVIRONMENT="development"

# Server Settings
HOST="0.0.0.0"
PORT=8080

# Database Settings
DB_HOST="localhost"
DB_PORT=3306
DB_NAME="webapp_db"

# Logging
LOG_LEVEL="INFO"
LOG_FILE="/var/log/webapp.log"
EOF

echo "  config/app.conf"

# Create sample log files
touch "${BASE_DIR}/logs/access.log"
touch "${BASE_DIR}/logs/error.log"
touch "${BASE_DIR}/logs/debug.log"

echo "  logs/access.log"
echo "  logs/error.log"
echo "  logs/debug.log"

# Create sample script
cat > "${BASE_DIR}/scripts/start.sh" <<'EOF'
#!/bin/bash
# Web Application Startup Script

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${SCRIPT_DIR}/../config"

echo "Starting web application..."
echo "Configuration directory: $CONFIG_DIR"

# Load configuration
if [ -f "${CONFIG_DIR}/app.conf" ]; then
    source "${CONFIG_DIR}/app.conf"
    echo "Loaded configuration for $APP_NAME v$APP_VERSION"
else
    echo "Error: Configuration file not found"
    exit 1
fi

echo "Starting server on ${HOST}:${PORT}..."
echo "Server started successfully!"
EOF

chmod +x "${BASE_DIR}/scripts/start.sh"

echo "  scripts/start.sh"

# Create sample public files
cat > "${BASE_DIR}/public/index.html" <<'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Web Application</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <h1>Welcome to Web Application</h1>
    <script src="js/app.js"></script>
</body>
</html>
EOF

echo "  public/index.html"

cat > "${BASE_DIR}/public/css/style.css" <<'EOF'
/* Main Stylesheet */
body {
    font-family: Arial, sans-serif;
    margin: 0;
    padding: 20px;
}

h1 {
    color: #333;
}
EOF

echo "  public/css/style.css"

cat > "${BASE_DIR}/public/js/app.js" <<'EOF'
// Main Application JavaScript
console.log('Web Application Loaded');

document.addEventListener('DOMContentLoaded', function() {
    console.log('DOM is ready');
});
EOF

echo "  public/js/app.js"

# Create a placeholder image file
touch "${BASE_DIR}/public/images/placeholder.png"
echo "  public/images/placeholder.png"

echo ""
echo "Directory structure created successfully!"
echo ""
echo "Structure:"
if command -v tree >/dev/null 2>&1; then
    tree -L 3 "$BASE_DIR"
else
    find "$BASE_DIR" -type f -o -type d | sort | head -30
fi

echo ""
echo "Total files created: $(find "$BASE_DIR" -type f 2>/dev/null | wc -l)"
echo "Total directories created: $(find "$BASE_DIR" -type d 2>/dev/null | wc -l)"
