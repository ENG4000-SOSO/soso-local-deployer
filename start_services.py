import os
import subprocess
import sys
import shutil
import platform


BOLD = '\033[1m'
CYAN = '\033[0;36m'
RED = '\033[0;31m'
END = '\033[0m'


def cecho(message):
    if platform.system() in ['Linux', 'Darwin']:
        print(f"{CYAN}{BOLD}{message}{END}")
    else:
        print(message)


def errecho(message):
    if platform.system() in ['Linux', 'Darwin']:
        print(f"{RED}{BOLD}Error: {message}{END}")
    else:
        print(f"Error: {message}")


def check_command_installed(command, error_message):
    if shutil.which(command) is None:
        errecho(error_message)
        sys.exit(1)


# ----------------------------
# 1. Check if git is installed
# ----------------------------
check_command_installed('git', 'git is not installed')

# -------------------------------
# 2. Check if docker is installed
# -------------------------------
check_command_installed('docker', 'docker is not installed')

# ------------------------------------------------------
# 3. Check if user has privileges to run docker command
# -------------------------------------------------------
if subprocess.call(['docker', 'ps'], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL) != 0:
    errecho('user does not have permission to run docker commands')
    sys.exit(1)

# ------------------------------------------------------
# 4. Clone backend git repo if it does not already exist
# ------------------------------------------------------
BACKEND_PROJECT_DIR = 'soso-server'
BACKEND_REPO_URL = 'https://github.com/ENG4000-SOSO/SOSO-Server.git'
if not os.path.isdir(BACKEND_PROJECT_DIR):
    cecho(f"{BACKEND_PROJECT_DIR} directory not found")
    cecho(f"Cloning {BACKEND_PROJECT_DIR} from git...")

    result = subprocess.run(['git', 'clone', BACKEND_REPO_URL, BACKEND_PROJECT_DIR])
    if result.returncode != 0:
        errecho(f"Cloning {BACKEND_PROJECT_DIR} failed")
        sys.exit(1)

    cecho(f"{BACKEND_PROJECT_DIR} cloned")
else:
    cecho(f"{BACKEND_PROJECT_DIR} directory found, skipping cloning.")

# -------------------------------------------------------
# 5. Clone frontend git repo if it does not already exist
# -------------------------------------------------------
FRONTEND_PROJECT_DIR = 'soso-client'
FRONTEND_REPO_URL = 'https://github.com/ENG4000-SOSO/SOSO-Client.git'
if not os.path.isdir(FRONTEND_PROJECT_DIR):
    cecho(f"{FRONTEND_PROJECT_DIR} directory not found")
    cecho(f"Cloning {FRONTEND_PROJECT_DIR} from git...")

    result = subprocess.run(['git', 'clone', FRONTEND_REPO_URL, FRONTEND_PROJECT_DIR])
    if result.returncode != 0:
        errecho(f"Cloning {FRONTEND_PROJECT_DIR} failed")
        sys.exit(1)

    cecho(f"{FRONTEND_PROJECT_DIR} cloned")
else:
    cecho(f"{FRONTEND_PROJECT_DIR} directory found, skipping cloning.")

# --------------------------------------------------
# 6. Change directory into backend project directory
# --------------------------------------------------
os.chdir(BACKEND_PROJECT_DIR)

cecho(f"Running {BACKEND_PROJECT_DIR}")

# ------------------
# 7. Run the backend
# ------------------
result = subprocess.run(['docker', 'compose', 'up', 'postgres', 'rabbitmq', 'relay-api', '-d', '--build'])

if result.returncode != 0:
    errecho('backend failed to run')
    sys.exit(1)

cecho(f"{BACKEND_PROJECT_DIR} running")

# --------------------------------------------------
# 8. Change directory into frontend project directory
# --------------------------------------------------
os.chdir('..')
os.chdir(FRONTEND_PROJECT_DIR)

# ----------------
# 9. Add .env file
# ----------------
with open('.env', 'w') as env_file:
    env_file.write('NEXT_PUBLIC_BASE_API_URL=http://localhost:5001\n')
    env_file.write('\n')

# --------------------
# 10. Run the frontend
# --------------------
result = subprocess.run(['docker', 'compose', 'up', '-d', '--build'])

if result.returncode != 0:
    errecho('frontend failed to run')
    sys.exit(1)

cecho(f"{FRONTEND_PROJECT_DIR} running")
