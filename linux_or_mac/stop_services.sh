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

# -------------------------------
# 1. Check if docker is installed
# -------------------------------
if ! [ -x "$(command -v docker)" ]; then
    errecho "docker is not installed" >&2
    exit 1
fi

# ------------------------------------------------------
# 2. Check if user has privileges to run docker commands
# ------------------------------------------------------
docker ps > /dev/null 2>&1 # Run docker ps and ignore stout and stderr
if ! [ $? -eq 0 ]; then
    errecho "user does not have permission to run docker commands"
    exit 1
fi

# ---------------------------------------------------------------
# 3. Change directory into backend project directory if it exists
# ---------------------------------------------------------------
BACKEND_PROJECT_DIR='soso-server'
if [ -d "$BACKEND_PROJECT_DIR" ]; then
    cd $BACKEND_PROJECT_DIR
else
    cecho "$BACKEND_PROJECT_DIR directory not found, skipping."
fi

cecho "Stopping $BACKEND_PROJECT_DIR..."

# -------------------
# 4. Stop the backend
# -------------------
docker compose down

cecho "$BACKEND_PROJECT_DIR stopped"

# ---------------------------------------------------------------
# 5. Change directory into backend project directory if it exists
# ---------------------------------------------------------------
FRONTEND_PROJECT_DIR='soso-client'
if [ -d "$FRONTEND_PROJECT_DIR" ]; then
    cd ..
    cd $FRONTEND_PROJECT_DIR
else
    cecho "$FRONTEND_PROJECT_DIR directory not found, skipping."
fi

cecho "Stopping $FRONTEND_PROJECT_DIR..."

# --------------------
# 6. Stop the frontend
# --------------------
docker compose down

cecho "$FRONTEND_PROJECT_DIR stopped"
