import os
import subprocess
import sys
import platform


BOLD = '\033[1m'
CYAN = '\033[0;36m'
RED = '\033[0;31m'
END = '\033[0m'


def cecho(message):
    print(f"{CYAN}{BOLD}{message}{END}")


def errecho(message):
    print(f"{RED}{BOLD}Error: {message}{END}")


# Helper function to change ownership of a directory
def change_ownership(directory):
    if os.path.isdir(directory):
        user = os.getenv('SUDO_USER') or os.getenv('USER')
        cecho(f"Making {user} the owner of {directory}")

        if platform.system() in ['Linux', 'Darwin']:  # Unix-like systems
            result = subprocess.run(['sudo', 'chown', '-R', f'{user}:', directory], stdout=subprocess.PIPE, stderr=subprocess.PIPE)

            if result.returncode != 0:
                errecho(f"Changing ownership of {directory} failed: {result.stderr.decode()}")
                sys.exit(1)
            else:
                cecho(f"{user} is now the owner of {directory}")
        else:
            cecho(f"Skipping ownership change on Windows for {directory}")
    else:
        errecho(f"{directory} does not exist")
        sys.exit(1)


# ---------------------------------------
# 1. Make user owner of backend directory
# ---------------------------------------
BACKEND_PROJECT_DIR = 'soso-server'
change_ownership(BACKEND_PROJECT_DIR)

# ----------------------------------------
# 2. Make user owner of frontend directory
# ----------------------------------------
FRONTEND_PROJECT_DIR = 'soso-client'
change_ownership(FRONTEND_PROJECT_DIR)
