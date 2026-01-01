# ============================================================
# Deterministic PowerShell Profile (managed by WinBootstrap)
# ============================================================

# --- PSReadLine ------------------------------------------------
Import-Module PSReadLine -Force
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -Font "Hack Nerd Font"

# --- Terminal Icons -------------------------------------------
Import-Module Terminal-Icons

# --- Starship Prompt ------------------------------------------
Invoke-Expression (& starship init powershell)
