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

# ---------------------------------------
# 1. Make user owner of backend directory
# ---------------------------------------
BACKEND_PROJECT_DIR='soso-server'
if [ -d "$BACKEND_PROJECT_DIR" ]; then
    cecho "Making $USER the owner of $BACKEND_PROJECT_DIR"

    sudo chown -R $USER: $BACKEND_PROJECT_DIR/

    if ! [ $? -eq 0 ]; then
        errecho "Cloning $BACKEND_PROJECT_DIR failed"
        exit 1
    fi
else
    errecho "$BACKEND_PROJECT_DIR does not exist"
    exit 1
fi

cecho "$USER is now the owner of $BACKEND_PROJECT_DIR"

# ----------------------------------------
# 2. Make user owner of frontend directory
# ----------------------------------------
FRONTEND_PROJECT_DIR='soso-client'
if [ -d "$FRONTEND_PROJECT_DIR" ]; then
    cecho "Making $USER the owner of $FRONTEND_PROJECT_DIR"

    sudo chown -R $USER: $FRONTEND_PROJECT_DIR/

    if ! [ $? -eq 0 ]; then
        errecho "Cloning $FRONTEND_PROJECT_DIR failed"
        exit 1
    fi
else
    errecho "$FRONTEND_PROJECT_DIR does not exist"
    exit 1
fi

cecho "$USER is now the owner of $FRONTEND_PROJECT_DIR"
