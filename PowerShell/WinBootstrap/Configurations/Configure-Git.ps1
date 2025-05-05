### Git ###

if ($null -eq $Key) {
    Write-Host "The variable 'Key' does not exist or has no value assigned. Skipping Git Configuration" -ForegroundColor Yellow
} else {

#Git config
git config --global user.name "$env:UserName"
git config --global user.email "$env:UserName@localhost"

#Copy SSH keys
Write-Host `n"Copying SSH Keys for $env:UserName."`n -ForegroundColor Green
$CurrentGitUser = $env:UserName
$SSHLocalFolder = "C:\Users\$CurrentGitUser\.ssh"

If(!(test-path -PathType container $SSHLocalFolder)) {
    New-Item -ItemType Directory -Path $SSHLocalFolder      
}

#Create Git folder for all users
$Users = (Get-ChildItem C:\Users).Name

ForEach($User in $Users) {

    New-Item -Path "C:\Users\$User\" -Name "Git" -ItemType "directory" -ErrorAction SilentlyContinue
    
}

$Encrypted = "76492d1116743f0423413b16050a5345MgB8AE8AcQBCADAARgBmAEQAbgBrAEMAaAA3AE4AdwBPAEMAQQBFADQATAB0AEEAPQA9AHwANAAxADYANgA3AGIANwBmADMAZAA1ADMAZgBmADcAYQBiAGEAYQA1AGYAZQBkADkANwAwADUAMgA5ADgAYgBjADUAOQAwADgAYgAxADgAYQA1ADUANABhAGIAYQAyADEAZQAxADIANQBkAGUAMAAxADIAYgAzADAAYgBlAGYAZgA3AGEAMwAyAGEAZQAwAGMANQBmADUANgBmADEAYwA0AGYAMwAxADEAMAA4AGQAMwAyAGEAMwBmADcANgAwADEA"
#Decryption key ($Key) must be included in the script that is calling this script.
$Password = ConvertTo-SecureString $Encrypted -Key $Key

$Credential = New-Object System.Management.Automation.PsCredential("_svcScript", $Password)

New-PSDrive -name "X" -PSProvider FileSystem -Root \\xfiles\Automation -Persist -Credential $Credential

#Copy-Item -Path X:\Ansible\Keys\Windows\.ssh\* -Destination $SSHLocalFolder -Recurse -Force

$sourceFolder = "X:\Ansible\Keys\Windows\.ssh"
$destinationFolder = "$SSHLocalFolder"

# Get all files in the source folder
$Files = Get-ChildItem -Path $sourceFolder -File

# Copy each file to the destination folder
Foreach ($File in $Files) {
    Copy-Item -Path $File.FullName -Destination $destinationFolder -Recurse
}

Write-Host "Files copied successfully!"

Remove-PSDrive -name "X" -Force

#Secure SSH keys

$sshPath = "$env:USERPROFILE\.ssh"

    # Ensure only the owner has access to SSH folder
    icacls $sshPath /inheritance:r /grant:r "$env:USERNAME:(OI)(CI)F"
    
    # Secure all private keys in the folder
    Get-ChildItem -Path $sshPath -Filter "id_*" | ForEach-Object {
        icacls $_.FullName /inheritance:r /grant:r "$env:USERNAME:F"
    }
    
Write-Host "All SSH keys and folder permissions secured."    

#Clone Public repositories

If(!(Test-Path -PathType container C:\Users\$User\Git\Public)) {

    New-Item -ItemType Directory -Path C:\Users\$User\Git\Public

} 

$ErrorActionPreference = "SilentlyContinue"

#Public Repositories
Set-Location -Path C:\Users\$User\Git\Public

git clone git@github.com:rtdevx/homelab.git
git config --global --add safe.directory C:/Users/$env:UserName/Git/Public/homelab

git clone git@github.com:rtdevx/dotfiles.git
git config --global --add safe.directory C:/Users/$env:UserName/Git/Public/dotfiles

git clone git@github.com:rtdevx/rtdevx.github.io.git
git config --global --add safe.directory C:/Users/$env:UserName/Git/Public/rtdevx.github.io

$ErrorActionPreference = "Continue"

}