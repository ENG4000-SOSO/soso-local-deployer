# Define colors
$BOLD = "`e[1m"
$CYAN = "`e[0;36m"
$RED = "`e[0;31m"
$END = "`e[0m"

# Function to print colored messages
function cecho {
    param (
        [string]$Message
    )
    Write-Host "$CYAN$BOLD$Message$END"
}

function errecho {
    param (
        [string]$Message
    )
    Write-Host "$RED$BOLD Error: $Message$END"
}

# -------------------------------
# 1. Check if docker is installed
# -------------------------------
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    errecho "docker is not installed"
    exit 1
}

# ------------------------------------------------------
# 2. Check if user has privileges to run docker commands
# ------------------------------------------------------
try {
    docker ps | Out-Null
} catch {
    errecho "user does not have permission to run docker commands"
    exit 1
}

# ---------------------------------------------------------------
# 3. Change directory into backend project directory if it exists
# ---------------------------------------------------------------
$BACKEND_PROJECT_DIR = 'soso-server'
if (Test-Path $BACKEND_PROJECT_DIR) {
    Set-Location $BACKEND_PROJECT_DIR

    cecho "Stopping $BACKEND_PROJECT_DIR..."

    # -------------------
    # 4. Stop the backend
    # -------------------
    docker-compose down
    
    cecho "$BACKEND_PROJECT_DIR stopped"
} else {
    cecho "$BACKEND_PROJECT_DIR directory not found, skipping."
}

# ------------------------------
# 5. Go back to parent directory
# ------------------------------
Set-Location ..

# ---------------------------------------------------------------
# 6. Change directory into frontend project directory if it exists
# ---------------------------------------------------------------
$FRONTEND_PROJECT_DIR = 'soso-client'
if (Test-Path $FRONTEND_PROJECT_DIR) {
    Set-Location $FRONTEND_PROJECT_DIR

    cecho "Stopping $FRONTEND_PROJECT_DIR..."

    # --------------------
    # 6. Stop the frontend
    # --------------------
    docker-compose down
    
    cecho "$FRONTEND_PROJECT_DIR stopped"
} else {
    cecho "$FRONTEND_PROJECT_DIR directory not found, skipping."
}
