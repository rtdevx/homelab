<#
.SYNOPSIS
    Configures Git, SSH, and GitHub access for the current user.

.DESCRIPTION
    - Ensures a Git workspace folder exists under $HOME\git
    - Configures global Git identity (user.name, user.email)
    - Ensures an SSH keypair exists (~/.ssh/id_ed25519)
    - Ensures GitHub CLI (gh) is authenticated
    - Uploads SSH public key to GitHub if not already present
    - Downloads SSH config into ~/.ssh/config
    - Secures ~/.ssh and key files with appropriate ACLs
    - Clones configured repositories into $HOME\git
#>

Write-Host "=== Setup-GitHub ==="

# ------------------------------------------------------------
# 1. Ensure Git is available
# ------------------------------------------------------------

function Test-Git {
    try {
        git --version | Out-Null
        return $true
    } catch {
        return $false
    }
}

if (-not (Test-Git)) {
    Write-Error "Git is not available on PATH. Ensure winget installed Git before running Setup-GitHub."
    return
}

# ------------------------------------------------------------
# 2. Configure Git identity
# ------------------------------------------------------------

Write-Host "Configuring Git global identity..."

$gitUserName  = $env:UserName
$gitUserEmail = "$($env:UserName)@localhost"

git config --global user.name  $gitUserName
git config --global user.email $gitUserEmail

Write-Host "Git user.name  = $gitUserName"
Write-Host "Git user.email = $gitUserEmail"

# ------------------------------------------------------------
# 3. Ensure Git workspace folder
# ------------------------------------------------------------

$GitRoot = Join-Path $HOME "git"

if (-not (Test-Path $GitRoot)) {
    Write-Host "Creating Git workspace at $GitRoot"
    New-Item -ItemType Directory -Path $GitRoot | Out-Null
} else {
    Write-Host "Git workspace already exists at $GitRoot"
}

# ------------------------------------------------------------
# 4. Ensure SSH keypair exists
# ------------------------------------------------------------

$sshPath = Join-Path $HOME ".ssh"
$keyPath = Join-Path $sshPath "id_ed25519"
$pubKeyPath = "$keyPath.pub"

if (-not (Test-Path $sshPath)) {
    Write-Host "Creating SSH directory at $sshPath"
    New-Item -ItemType Directory -Path $sshPath | Out-Null
}

if (-not (Test-Path $keyPath)) {
    Write-Host "Generating SSH keypair (ed25519)..."
    ssh-keygen -t ed25519 -C "$gitUserEmail" -f $keyPath -N "" | Out-Null
} else {
    Write-Host "SSH key already exists at $keyPath"
}

if (-not (Test-Path $pubKeyPath)) {
    Write-Error "Public key $pubKeyPath is missing. Check SSH key generation."
    return
}

# ------------------------------------------------------------
# 5. Ensure GitHub CLI (gh) is available and authenticated
# ------------------------------------------------------------

function Test-Gh {
    try {
        gh --version | Out-Null
        return $true
    } catch {
        return $false
    }
}

if (-not (Test-Gh)) {
    Write-Error "GitHub CLI (gh) is not available on PATH. Ensure winget installed gh before running Setup-GitHub."
    return
}

Write-Host "Checking GitHub CLI authentication status..."
gh auth status 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "GitHub CLI is not authenticated. Launching interactive login..."
    gh auth login --git-protocol ssh --web
    if ($LASTEXITCODE -ne 0) {
        Write-Error "GitHub CLI authentication failed. Aborting Setup-GitHub."
        return
    }
} else {
    Write-Host "GitHub CLI is already authenticated."
}

# ------------------------------------------------------------
# 6. Ensure SSH public key is uploaded to GitHub
# ------------------------------------------------------------

Write-Host "Checking if SSH key is already uploaded to GitHub..."

$pubKeyContent = (Get-Content $pubKeyPath -Raw).Trim()

$existingKeysJson = gh ssh-key list --json title,key 2>$null
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($existingKeysJson)) {
    $existingKeys = @()
} else {
    $existingKeys = $existingKeysJson | ConvertFrom-Json
}

$alreadyUploaded = $false
foreach ($k in $existingKeys) {
    if ($k.key.Trim() -eq $pubKeyContent) {
        $alreadyUploaded = $true
        Write-Host "SSH key already uploaded to GitHub with title '$($k.title)'."
        break
    }
}

if (-not $alreadyUploaded) {
    $keyTitle = $env:COMPUTERNAME
    Write-Host "Uploading SSH key to GitHub with title '$keyTitle'..."
    gh ssh-key add $pubKeyPath --title $keyTitle
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to upload SSH key to GitHub."
        return
    }
}

# ------------------------------------------------------------
# 7. Download SSH config
# ------------------------------------------------------------

$sshConfigPath = Join-Path $sshPath "config"
$sshConfigUrl  = "https://raw.githubusercontent.com/rtdevx/dotfiles/refs/heads/main/ssh/config"

Write-Host "Downloading SSH config from $sshConfigUrl to $sshConfigPath..."

try {
    Invoke-WebRequest -Uri $sshConfigUrl -OutFile $sshConfigPath -UseBasicParsing -ErrorAction Stop
    Write-Host "SSH config downloaded."
} catch {
    Write-Warning "Failed to download SSH config: $($_.Exception.Message)"
}

# ------------------------------------------------------------
# 8. Secure .ssh folder and key files
# ------------------------------------------------------------

Write-Host "Securing .ssh folder and key files..."

try {
    # Remove inheritance and grant full control to the current user on .ssh
    icacls $sshPath /inheritance:r /grant:r "$env:UserName:(OI)(CI)F" | Out-Null

    # Private key: full control for user only
    icacls $keyPath /inheritance:r /grant:r "$env:UserName:F" | Out-Null

    # Public key: read for user
    icacls $pubKeyPath /inheritance:r /grant:r "$env:UserName:R" | Out-Null

    # SSH config: read/write for user
    if (Test-Path $sshConfigPath) {
        icacls $sshConfigPath /inheritance:r /grant:r "$env:UserName:RW" | Out-Null
    }

    Write-Host "SSH permissions configured."
} catch {
    Write-Warning "Failed to fully configure SSH permissions: $($_.Exception.Message)"
}

# ------------------------------------------------------------
# 9. Clone repositories
# ------------------------------------------------------------

$repos = @(
    "git@github.com:rtdevx/homelab.git"
    # Add more repositories here as needed
)

foreach ($repo in $repos) {
    $name = ($repo -split "/")[-1].Replace(".git","")
    $target = Join-Path $GitRoot $name

    if (Test-Path $target) {
        Write-Host "Repository '$name' already exists at $target"
        continue
    }

    Write-Host "Cloning $repo into $target..."
    git clone $repo $target
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "Failed to clone $repo"
    }
}

Write-Host "=== Setup-GitHub completed ==="
