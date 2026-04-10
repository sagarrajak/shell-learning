#!/usr/bin/bash

set -euo pipefail


BASE_DIR="${HOME}/webserver"

echo "=========== creating files for webserver ==========="
echo "Base directory is $BASE_DIR"



echo "=== creating folders ===== "

mkdir -p "${BASE_DIR}/config"
mkdir -p "${BASE_DIR}/logs"
mkdir -p "${BASE_DIR}/scripts"
mkdir -p "${BASE_DIR}/public/html"
mkdir -p "${BASE_DIR}/public/css"
mkdir -p "${BASE_DIR}/public/js"



echo "Created main directories"

echo "==== creating config files ===="

cat > "${BASE_DIR}/config/app.config" << 'EOF'
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

echo "== config created === ${BASE_DIR}/config/app.config"

BASE_LOGS="${BASE_DIR}/logs"

touch "${BASE_LOGS}/access.log"
touch "${BASE_LOGS}/error.log"
touch "${BASE_LOGS}/info.log"


cat > "${BASE_DIR}/public/html/index.html" << 'EOF'
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


if [ "$(command -v tree)" ]; then
    tree -L 3 "$BASE_DIR"
fi


if [ "$(command -v find)" ]; then
   find "$BASE_DIR" -type f -o -type d | sort | head 30
fi
