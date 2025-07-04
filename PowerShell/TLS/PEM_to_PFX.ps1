<#

.SYNOPSIS
    Bulk convert of PEM to PFX.
    
.DESCRIPTION
    Bulk convert of PEM to PFX.
     
.USAGE
    PS> ./PEM_to_PFX

    Drop .pem file(s) to $PEMIN folder and run the script. .cer and .pfx files will be generated and moved to $PFXOUT. 
    .key is a private portion and will be removed.

    !!! Please remove .pem files manually from $PEMIN folder !!!

    Password will be generated randomly and displayed in the console at the end.
 
.NOTES
    - Import .pfx to Local User Store instead of leaving files behind
    - Distribute new .pfx to a number of remote machines as and when required? (DEFAULT: LOCAL MACHINE!) ;)

#>

$binpath = [System.IO.Path]::GetDirectoryName($myInvocation.MyCommand.Definition)
#OpenSSL 1.1 executable
$OpenSSL = "E:\tools\openssl-1.1\x64\bin\openssl.exe"
#Input and output files
$PEMIN = "$binpath\PEM IN"
$PFXOUT = "$binpath\PFX OUT"

#Generate Strong Password for .pfx certificate
$Passwd = GenerateStrongPassword (16)

Clear-Host ; Write-Host "Your certificate details: `n"

#Cleanup $PFXOUT folder to remove old .pfx files
Remove-Item –path "$PFXOUT\*"

$files = Get-ChildItem "$binpath\PEM IN\*.pem"

#Setting ErrorActionPreference to silentlycontinue - otherwise internal OpenSSL errors are being displayed despite all working OK
$ErrorActionPreference='silentlycontinue'

foreach ($file in $files) {

    $outfile = $file.FullName
    #Get-Content $file.FullName | Where-Object { ($_ -match ".pem" -and $_ -notmatch ".key") } | Set-Content $outfile

    #Extract Private key
    & $OpenSSL @("rsa", "-in", "$outfile", "-out", "$outfile.key", "-passout", "pass:$Passwd")
    $keyfile = "$outfile.key"

    #Extract Public key    
    & $OpenSSL @("x509", "-outform", "der", "-in", "$outfile", "-out", "$outfile.crt")
    $certfile = "$outfile.crt"

    #Get certificate information (Thumbprint, Serial, Expiry Date) from .cer files to $PFXOUT\Certinfo.txt
    $certfilename = [System.IO.Path]::GetFileName($certfile)
    $certinfo = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 "$certfile"
    $thumbprint = $certinfo.Thumbprint
    $serialnumber = $certinfo.SerialNumber
    $notafter = $certinfo.NotAfter
    Write-Host "$certfilename, Thumbprint: $thumbprint, Serial: $serialnumber, Expiry: $notafter"
    Write-Host ("$certfilename, Thumbprint: $thumbprint, Serial: $serialnumber, Expiry: $notafter" | Out-File -FilePath "$PFXOUT\Certinfo.txt" -Append)

    #Create .pfx    
    & $OpenSSL @("pkcs12", "-export", "-out", "$outfile.pfx", "-inkey", "$outfile.key", "-in", "$file", "-passin", "pass:$Passwd", "-passout", "pass:$Passwd")
    $pfxfile = "$outfile.pfx"
        
        #Move PFX file to $PFXOUT folder

        If(!(test-path -PathType container $PFXOUT)) {

            New-Item -ItemType Directory -Path $PFXOUT

        }

            Move-Item $certfile "$PFXOUT"
            Move-Item $pfxfile "$PFXOUT"            
}

#Cleanup Private Keys from $PEMIN
Remove-Item –path "$PEMIN\*" -exclude *.pem

#Write-Host "Your .pfx password is: $Passwd" `n
Write-Host "Your .pfx password is: " `n ; Write-Host "$Passwd" -ForegroundColor Red `n

Write-Host "!!! Please remove .pem files manually from $PEMIN folder !!!" -ForegroundColor DarkRed -BackgroundColor Yellow

####FUNCTIONS####

#Generate Strong Password
Function GenerateStrongPassword ([Parameter(Mandatory=$true)][int]$PasswordLenght) {

    Add-Type -AssemblyName System.Web
    $PassComplexCheck = $false
        do {
            $newPassword=[System.Web.Security.Membership]::GeneratePassword($PasswordLenght,1)
            If ( ($newPassword -cmatch "[A-Z\p{Lu}\s]") `
            -and ($newPassword -cmatch "[a-z\p{Ll}\s]") `
            -and ($newPassword -match "[\d]") `
            -and ($newPassword -match "[^\w]")
            )
        {

            $PassComplexCheck=$True

        }
    } 
    
    While ($PassComplexCheck -eq $false)
    return $newPassword
}

####FUNCTIONS END####