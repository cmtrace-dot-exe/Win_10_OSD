############################################################################################################
### HP TPM Update Script - SP87753 
### olearym
### Changelog: 	2018-05-29
### This script updates the Infineon SLB9670 TPM chip found in the following (and so, so many more) HP models:
###		HP Elite x2 1012 G1
###		HP Elite x2 1012 G2
###		HP ProBook 450 G3
###		HP ProBook 450 G4
###		HP ProBook 450 G5
###		HP ProBook 640 G2
###		HP ProDesk 400 G2 MINI
###		HP ProDesk 400 G3 DM
###		HP ProDesk 600 G2 DM
###		HP ProDesk 600 G2 SFF
###		HP ProDesk 600 G3 DM
###		HP ProDesk 600 G3 SFF
###		HP ProOne 600 G2
###		HP ProOne 600 G2 21.5-in Non-Touch AiO
###		HP ZBook 17 G4
############################################################################################################

	Function LogWrite ([string]$logstring) {
		Add-content $Logfile -value $logstring
	}

# Test for powershell version, populate $PSScriptRoot if version < 3 
	if ($PSVersionTable.PSVersion.major -lt 3) {$PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent}

# Set log file path
	$LogFile = "\\YOUR_LOG_PATH_HERE\upload$\results\HP_OSD_TPM\$env:computername.log"
	
# Collect TPM WMI Data
	$TPM = Get-WmiObject -Namespace root\cimv2\security\microsofttpm -Class Win32_Tpm

#Check to see if update is necessary. Perform update if so, exit if not.
	if ($Tpm.ManufacturerVersion -notlike "7.63*")
		{
		# Select appropriate TPM update file
			If ($tpm.SpecVersion -Like "2.0*") {
				logwrite $(get-date), "Initial TPM version is 2.0"
				Write-output "Initial TPM version is 2.0"
				$tpmspec = "TPM20_"+$Tpm.ManufacturerVersion+"*_TPM20*"
				#$tpmspec = "TPM20_"+$Tpm.ManufacturerVersion+"*_TPM12*"
				write-output $tpmspec
				$filename = Get-Childitem -Path "$PSScriptRoot" -Filter $tpmspec
			}
			If ($tpm.SpecVersion -Like "1.2*") {
				logwrite $(get-date), "Initial TPM version is 1.2"
				Write-output "Initial TPM version is 1.2"
				$tpmspec = "TPM12_"+$Tpm.ManufacturerVersion+"*_TPM20*"
				$filename = Get-Childitem -Path "$PSScriptRoot" -Filter $tpmspec
			}
				
			logwrite $(get-date), "TPM Conversion will be attempted with file", $filename.name
			
		# Apply TPM Update
			$TPMConvert = start-process "TPMConfig64.exe" -WorkingDirectory "$PSScriptRoot" -argumentlist $("-s -f$($filename.name)") -wait -passthru
				
			logwrite $(get-date), "Conversion result:", $TPMConvert.exitcode
			
			if ($($TPMConvert.exitcode -eq 0) -or $($TPMConvert.exitcode -eq 3010)) {exit 0}
			else {exit $TPMConvert.exitcode}
		}
	else
		{
			logwrite $(get-date), "TPM already up to date. No update necessary."
			exit 0
		}