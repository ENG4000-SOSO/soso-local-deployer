BOLD='\033[1m'
CYAN='\033[0;36m'
RED='\033[0;31m'
END='\033[0m'

cecho() {
    echo -e "${CYAN}${BOLD}${*}${END}"
}

errecho() {
    echo -e "${RED}${BOLD}Error: ${*}${END}"
}

# ----------------------------
# 1. Check if git is installed
# ----------------------------
if ! [ -x "$(command -v git)" ]; then
    errecho "git is not installed" >&2
    exit 1
fi

# -------------------------------
# 2. Check if docker is installed
# -------------------------------
if ! [ -x "$(command -v docker)" ]; then
    errecho "docker is not installed" >&2
    exit 1
fi

# ------------------------------------------------------
# 3. Check if user has privileges to run docker commands
# ------------------------------------------------------
docker ps > /dev/null 2>&1 # Run docker ps and ignore stout and stderr
if ! [ $? -eq 0 ]; then
    errecho "user does not have permission to run docker commands"
    exit 1
fi

# ------------------------------------------------------
# 4. Clone backend git repo if it does not already exist
# ------------------------------------------------------
BACKEND_PROJECT_DIR='soso-server'
BACKEND_REPO_URL='https://github.com/ENG4000-SOSO/SOSO-Server.git'
if [ ! -d "$BACKEND_PROJECT_DIR" ]; then
    cecho "$BACKEND_PROJECT_DIR directory not found"
    cecho "Cloning $BACKEND_PROJECT_DIR from git..."

    # Clone the git repo
    git clone $BACKEND_REPO_URL $BACKEND_PROJECT_DIR

    if ! [ $? -eq 0 ]; then
        errecho "Cloning $BACKEND_PROJECT_DIR failed"
        exit 1
    fi

    cecho "$BACKEND_PROJECT_DIR cloned"
else
    cecho "$BACKEND_PROJECT_DIR directory found, skipping cloning."
fi

# -------------------------------------------------------
# 5. Clone frontend git repo if it does not already exist
# -------------------------------------------------------
FRONTEND_PROJECT_DIR='soso-client'
FRONTEND_REPO_URL='https://github.com/ENG4000-SOSO/SOSO-Client.git'
if [ ! -d "$FRONTEND_PROJECT_DIR" ]; then
    cecho "$FRONTEND_PROJECT_DIR directory not found"
    cecho "Cloning $FRONTEND_PROJECT_DIR from git..."

    # Clone the git repo
    git clone $FRONTEND_REPO_URL $FRONTEND_PROJECT_DIR

    if ! [ $? -eq 0 ]; then
        errecho "Cloning $FRONTEND_PROJECT_DIR failed"
        exit 1
    fi

    cecho "$FRONTEND_PROJECT_DIR cloned"
else
    cecho "$FRONTEND_PROJECT_DIR directory found, skipping cloning."
fi

# --------------------------------------------------
# 6. Change directory into backend project directory
# --------------------------------------------------
cd $BACKEND_PROJECT_DIR

cecho "Running $BACKEND_PROJECT_DIR"

# ------------------
# 7. Run the backend
# ------------------
docker compose up postgres rabbitmq relay-api -d --build

if ! [ $? -eq 0 ]; then
    errecho 'backend failed to run'
    exit 1
fi

cecho "$BACKEND_PROJECT_DIR running"

# --------------------------------------------------
# 8. Change directory into frontend project directory
# --------------------------------------------------
cd ..
cd $FRONTEND_PROJECT_DIR

# ----------------
# 9. Add .env file
# ----------------
echo 'NEXT_PUBLIC_BASE_API_URL=http://localhost:5001' > .env
echo '' >> .env

# --------------------
# 10. Run the frontend
# --------------------
docker compose up -d --build

if ! [ $? -eq 0 ]; then
    errecho 'frontend failed to run'
    exit 1
fi

cecho "$FRONTEND_PROJECT_DIR running"
