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

# ---------------------------------------
# 1. Make user owner of backend directory
# ---------------------------------------
$BACKEND_PROJECT_DIR = 'soso-server'
if (Test-Path $BACKEND_PROJECT_DIR) {
    cecho "Making $env:USERNAME the owner of $BACKEND_PROJECT_DIR"

    # Get the current user's security identifier (SID)
    $currentUser = New-Object System.Security.Principal.NTAccount($env:USERNAME)
    $sid = $currentUser.Translate([System.Security.Principal.SecurityIdentifier])

    # Change the owner to the current user
    $acl = Get-Acl $BACKEND_PROJECT_DIR
    $acl.SetOwner($sid)
    Set-Acl $BACKEND_PROJECT_DIR $acl

    if ($LASTEXITCODE -ne 0) {
        errecho "Changing ownership of $BACKEND_PROJECT_DIR failed"
        exit 1
    }
} else {
    errecho "$BACKEND_PROJECT_DIR does not exist"
    exit 1
}

cecho "$env:USERNAME is now the owner of $BACKEND_PROJECT_DIR"

# ----------------------------------------
# 2. Make user owner of frontend directory
# ----------------------------------------
$FRONTEND_PROJECT_DIR = 'soso-client'
if (Test-Path $FRONTEND_PROJECT_DIR) {
    cecho "Making $env:USERNAME the owner of $FRONTEND_PROJECT_DIR"

    # Get the current user's security identifier (SID)
    $currentUser = New-Object System.Security.Principal.NTAccount($env:USERNAME)
    $sid = $currentUser.Translate([System.Security.Principal.SecurityIdentifier])

    # Change the owner to the current user
    $acl = Get-Acl $FRONTEND_PROJECT_DIR
    $acl.SetOwner($sid)
    Set-Acl $FRONTEND_PROJECT_DIR $acl

    if ($LASTEXITCODE -ne 0) {
        errecho "Changing ownership of $FRONTEND_PROJECT_DIR failed"
        exit 1
    }
} else {
    errecho "$FRONTEND_PROJECT_DIR does not exist"
    exit 1
}

cecho "$env:USERNAME is now the owner of $FRONTEND_PROJECT_DIR"
