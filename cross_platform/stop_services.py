import os
import subprocess
import sys


BOLD = '\033[1m'
CYAN = '\033[0;36m'
RED = '\033[0;31m'
END = '\033[0m'


def cecho(message):
    print(f"{CYAN}{BOLD}{message}{END}")


def errecho(message):
    print(f"{RED}{BOLD}Error: {message}{END}")


def check_command_installed(command, error_message):
    if subprocess.call(['which', command], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL) != 0:
        errecho(error_message)
        sys.exit(1)


# -------------------------------
# 1. Check if docker is installed
# -------------------------------
check_command_installed('docker', 'docker is not installed')

# ------------------------------------------------------
# 2. Check if user has privileges to run docker commands
# ------------------------------------------------------
if subprocess.call(['docker', 'ps'], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL) != 0:
    errecho('user does not have permission to run docker commands')
    sys.exit(1)

# ---------------------------------------------------------------
# 3. Change directory into backend project directory if it exists
# ---------------------------------------------------------------
BACKEND_PROJECT_DIR = 'soso-server'
if os.path.isdir(BACKEND_PROJECT_DIR):
    os.chdir(BACKEND_PROJECT_DIR)

    cecho(f"Stopping {BACKEND_PROJECT_DIR}...")

    # -------------------
    # 4. Stop the backend
    # -------------------
    subprocess.run(['docker', 'compose', 'down'])

    cecho(f"{BACKEND_PROJECT_DIR} stopped")
else:
    cecho(f"{BACKEND_PROJECT_DIR} directory not found, skipping.")

# ------------------------------
# 5. Go back to parent directory
# ------------------------------
os.chdir('..')

# ----------------------------------------------------------------
# 6. Change directory into frontend project directory if it exists
# ----------------------------------------------------------------
FRONTEND_PROJECT_DIR = 'soso-client'
if os.path.isdir(FRONTEND_PROJECT_DIR):
    os.chdir(FRONTEND_PROJECT_DIR)

    cecho(f"Stopping {FRONTEND_PROJECT_DIR}...")

    # --------------------
    # 7. Stop the frontend
    # --------------------
    subprocess.run(['docker', 'compose', 'down'])

    cecho(f"{FRONTEND_PROJECT_DIR} stopped")
else:
    cecho(f"{FRONTEND_PROJECT_DIR} directory not found, skipping.")
