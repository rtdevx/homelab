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

If(!(Test-Path -PathType container $SSHLocalFolder)) {

$Encrypted = "76492d1116743f0423413b16050a5345MgB8AE8AcQBCADAARgBmAEQAbgBrAEMAaAA3AE4AdwBPAEMAQQBFADQATAB0AEEAPQA9AHwANAAxADYANgA3AGIANwBmADMAZAA1ADMAZgBmADcAYQBiAGEAYQA1AGYAZQBkADkANwAwADUAMgA5ADgAYgBjADUAOQAwADgAYgAxADgAYQA1ADUANABhAGIAYQAyADEAZQAxADIANQBkAGUAMAAxADIAYgAzADAAYgBlAGYAZgA3AGEAMwAyAGEAZQAwAGMANQBmADUANgBmADEAYwA0AGYAMwAxADEAMAA4AGQAMwAyAGEAMwBmADcANgAwADEA"
#Decryption key ($Key) must be included in the script that is calling this script.
$Password = ConvertTo-SecureString $Encrypted -Key $Key

$Credential = New-Object System.Management.Automation.PsCredential("_svcScript", $Password)

New-PSDrive -name "X" -PSProvider FileSystem -Root \\xfiles\Automation -Persist -Credential $Credential

Copy-Item -Path X:\Ansible\Keys\Windows\.ssh\* -Destination $SSHLocalFolder -Recurse

Remove-PSDrive -name "X" -Force

#Secure SSH keys

    Get-Item $SSHLocalFolder -Force | ForEach-Object { $_.Attributes = $_.Attributes -bor "Hidden" }
    Get-Item $SSHLocalFolder -Force | ForEach-Object { $_.Attributes = $_.Attributes -bor "ReadOnly" }
    Get-Item $SSHLocalFolder\* -Force | ForEach-Object { $_.Attributes = $_.Attributes -bor "ReadOnly" }

    #Set Key File Variable:
    New-Variable -Name PKFile -Value "$SSHLocalFolder\id_rsa_git"

    #Remove Inheritance:
    Icacls $PKFile /c /t /Inheritance:d

    #Set Ownership to Owner:
    #Key's within $env:UserProfile:
    Icacls $PKFile /c /t /Grant ${env:UserName}:F

    #Key's outside of $env:UserProfile:
    TakeOwn /F $PKFile
    Icacls $PKFile /c /t /Grant:r ${env:UserName}:F

    #Remove All Users, except for Owner:
    Icacls $PKFile /c /t /Remove:g Administrator "Authenticated Users" BUILTIN\Administrators BUILTIN Everyone System Users

    #Verify:
    Icacls $PKFile

    #Remove Variable:
    Remove-Variable -Name PKFile

} else { Write-Host ".ssh folder already exist. Skipping" -ForegroundColor Yellow }

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