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

# ----------------------------
# 1. Check if git is installed
# ----------------------------
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    errecho "git is not installed"
    exit 1
}

# -------------------------------
# 2. Check if docker is installed
# -------------------------------
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    errecho "docker is not installed"
    exit 1
}

# ------------------------------------------------------
# 3. Check if user has privileges to run docker commands
# ------------------------------------------------------
try {
    docker ps | Out-Null
} catch {
    errecho "user does not have permission to run docker commands"
    exit 1
}

# ------------------------------------------------------
# 4. Clone backend git repo if it does not already exist
# ------------------------------------------------------
$BACKEND_PROJECT_DIR = 'soso-server'
$BACKEND_REPO_URL = 'https://github.com/ENG4000-SOSO/SOSO-Server.git'
if (-not (Test-Path $BACKEND_PROJECT_DIR)) {
    cecho "$BACKEND_PROJECT_DIR directory not found"
    cecho "Cloning $BACKEND_PROJECT_DIR from git..."

    # Clone the git repo
    git clone $BACKEND_REPO_URL $BACKEND_PROJECT_DIR

    if ($LASTEXITCODE -ne 0) {
        errecho "Cloning $BACKEND_PROJECT_DIR failed"
        exit 1
    }

    cecho "$BACKEND_PROJECT_DIR cloned"
} else {
    cecho "$BACKEND_PROJECT_DIR directory found, skipping cloning."
}

# -------------------------------------------------------
# 5. Clone frontend git repo if it does not already exist
# -------------------------------------------------------
$FRONTEND_PROJECT_DIR = 'soso-client'
$FRONTEND_REPO_URL = 'https://github.com/ENG4000-SOSO/SOSO-Client.git'
if (-not (Test-Path $FRONTEND_PROJECT_DIR)) {
    cecho "$FRONTEND_PROJECT_DIR directory not found"
    cecho "Cloning $FRONTEND_PROJECT_DIR from git..."

    # Clone the git repo
    git clone $FRONTEND_REPO_URL $FRONTEND_PROJECT_DIR

    if ($LASTEXITCODE -ne 0) {
        errecho "Cloning $FRONTEND_PROJECT_DIR failed"
        exit 1
    }

    cecho "$FRONTEND_PROJECT_DIR cloned"
} else {
    cecho "$FRONTEND_PROJECT_DIR directory found, skipping cloning."
}

# --------------------------------------------------
# 6. Change directory into backend project directory
# --------------------------------------------------
Set-Location $BACKEND_PROJECT_DIR

cecho "Running $BACKEND_PROJECT_DIR"

# ------------------
# 7. Run the backend
# ------------------
docker-compose up postgres rabbitmq relay-api -d --build

if ($LASTEXITCODE -ne 0) {
    errecho 'backend failed to run'
    exit 1
}

cecho "$BACKEND_PROJECT_DIR running"

# --------------------------------------------------
# 8. Change directory into frontend project directory
# --------------------------------------------------
Set-Location ..

Set-Location $FRONTEND_PROJECT_DIR

# ----------------
# 9. Add .env file
# ----------------
'NEXT_PUBLIC_BASE_API_URL=http://localhost:5001' | Out-File -FilePath .env -Encoding utf8
'' | Out-File -FilePath .env -Append -Encoding utf8

# --------------------
# 10. Run the frontend
# --------------------
docker-compose up -d --build

if ($LASTEXITCODE -ne 0) {
    errecho 'frontend failed to run'
    exit 1
}

cecho "$FRONTEND_PROJECT_DIR running"
