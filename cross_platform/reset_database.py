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

# --------------------------------------------------
# 5. Change directory into backend project directory
# --------------------------------------------------
os.chdir(BACKEND_PROJECT_DIR)

cecho("Running postgres and rabbitmq...")

# ---------------------------------------------------
# 6. Run postgres and rabbit,mq as a docker container
# ---------------------------------------------------
result = subprocess.run(['docker', 'compose', 'up', 'postgres', 'rabbitmq', '-d', '--build'])

if result.returncode != 0:
    errecho('postgres and rabbitmq failed to run')
    sys.exit(1)

cecho("postgres and rabbitmq running")

cecho("Creating virtual environment...")

# ----------------------------------------------------------
# 7. Get python and pip executables from virtual environment
# ----------------------------------------------------------
if os.name != 'nt':
    pip_executable = os.path.join('venv', 'bin', 'pip')
    python_executable = os.path.join('venv', 'bin', 'python')
else:
    pip_executable = os.path.join('venv', 'Scripts', 'pip.exe')
    python_executable = os.path.join('venv', 'Scripts', 'python.exe')

# --------------------------------------------------
# 8. Create virtual environment if it does not exist
# --------------------------------------------------
if not os.path.isdir("venv"):
    result = subprocess.run([sys.executable, '-m', 'venv', 'venv'])

    if result.returncode != 0:
        errecho('Failed to create virtual environment')
        sys.exit(1)

    cecho("Virtual environment created")

    cecho("Installing dependencies into the virtual environment...")

    # ------------------------------------------------
    # 9. Install dependencies into virtual environment
    # ------------------------------------------------
    result = subprocess.run([pip_executable, 'install', '-r', 'requirements.txt'])

    if result.returncode != 0:
        errecho('Failed install dependencies into the virtual environment')
        sys.exit(1)

    cecho("Dependencies installed into the virtual environment")

    cecho(f"Installing {BACKEND_PROJECT_DIR} as pip package...")

    # -----------------------------------------
    # 10. Install each service as a pip package
    # -----------------------------------------
    result = subprocess.run([pip_executable, 'install', '-e', '.'])
    if result.returncode != 0:
        errecho(f"Failed to install {BACKEND_PROJECT_DIR} as pip package")
        sys.exit(1)

    cecho(f"{BACKEND_PROJECT_DIR} installed as pip package")
else:
    cecho("venv folder detected, skipping creation of virtual environment")

cecho("Cleaning database...")

# ------------------------------------
# 11. Execute database cleaning script
# ------------------------------------
result = subprocess.run([python_executable, './database_scripts/cleanup.py'])

if result.returncode != 0:
    errecho('Failed to run database cleaning script')
    sys.exit(1)

cecho("Database cleaned")

cecho("Stopping postgres and rabbitmq containers...")

# ----------------------------------
# 11. Stop postgres docker container
# ----------------------------------
result = subprocess.run(['docker', 'compose', 'down'])

if result.returncode != 0:
    errecho('postgres and rabbitmq containers failed to stop')
    sys.exit(1)

cecho("postgres and rabbitmq containers stopped")
