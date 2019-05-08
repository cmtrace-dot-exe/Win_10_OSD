############################################################################################################
### HP TPM Update Script - SP82407 
### olearym
### Changelog: 	2018-05-01
### This script updates the Infineon SLB 9655 and SLB 9656 chips found in the following HP models:
###		HP EliteBook Revolve 810 G2
###		HP EliteOne 800 G1 Touch AiO
###		HP ProBook 450 G1
###		HP ProBook 640 G1
###		HP ProDesk 400 G1 DM
###		HP ProDesk 600 G1 SFF
###		HP ProDesk 600 G1 TWR
###		HP ZBook 15
###		HP ZBook 17
############################################################################################################

# Declare Central Log Location
	$LogLoc = "\\YOUR_LOG_PATH_HERE\upload$\Results\HP_OSD_TPM\$($env:computername).log"
	
# Capture OwnerAuthFull value from registry
	$OwnerAuth = Get-ItemProperty -path HKLM:\System\CurrentControlSet\Services\TPM\WMI\Admin -name "OwnerAuthFull" | select-object -ExpandProperty OwnerAuthFull

# Create TPM backup XML file on the fly using the above value
	NEW-ITEM -Path "$PSScriptRoot" -Name "$($env:computername).tpm" -ItemType "File" -force | OUT-NULL
	ADD-CONTENT -path "$PSScriptRoot\$($env:computername).tpm" -Value $('<?xml version="1.0" encoding="UTF-8"?>')
	ADD-CONTENT -path "$PSScriptRoot\$($env:computername).tpm" -Value $('<tpmOwnerData>')
	ADD-CONTENT -path "$PSScriptRoot\$($env:computername).tpm" -Value $('<tpmInfo manufacturerId="1229346816"/>')
	ADD-CONTENT -path "$PSScriptRoot\$($env:computername).tpm" -Value $('<ownerAuth>' + $OwnerAuth + '</ownerAuth>')
	ADD-CONTENT -path "$PSScriptRoot\$($env:computername).tpm" -Value $('</tpmOwnerData>')

# Apply TPM Update and log to central location	
	& cmd /c "$PSScriptRoot\IFXTPMUpdate_TPM12_v0434.com" /update /pwdfile:"$PSScriptRoot\$($env:computername).tpm" /logfile:"$LogLoc" 
	
# Securely delete previously created TPM backup XML file
	$sdelete = & "$PSScriptRoot\sdelete.exe" "$PSScriptRoot\$($env:computername).tpm" /accepteula 
	