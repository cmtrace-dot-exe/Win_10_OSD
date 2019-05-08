############################################################################################################
### HP TPM Update Script - SP82133 
### olearym
### Changelog: 	2018-05-01
### This script updates the Infineon SLB 9660 chip found in the following HP models:
###		HP EliteBook Revolve 810 G3
###		HP ProBook 450 G2
############################################################################################################

Function LogWrite ([string]$logstring) {
	Add-content $Logfile -value $logstring
}

# Set log file path
	$LogFile = "\\YOUR_LOG_PATH_HERE\HP_OSD_TPM\$env:computername.log"

# Test for powershell version, populate $PSScriptRoot if version < 3 
	if ($PSVersionTable.PSVersion.major -lt 3) {$PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent}
	
# Collect TPM WMI Data
	$TPM = Get-WmiObject -Namespace root\cimv2\security\microsofttpm -Class Win32_Tpm

# Clear TPM
	
	logwrite $(get-date), "Attempting to clear TPM."
	$TPM.clear()
	#logwrite $(get-date), "Clear TPM result:", $ClearTPM.exitcode
	
# Apply TPM Update
	
	logwrite $(get-date), "Attempting to update TPM."
	
	$TPMConvert = start-process "IFXTPMUpdate_TPM12_v0443.com" -WorkingDirectory "$PSScriptRoot" -argumentlist $("/update /logfile:\\YOUR_LOG_PATH_HERE\HP_OSD_TPM\$("$env:computername" + '_SP82133').log") -wait -passthru
		
	logwrite $(get-date), "Conversion result:", $TPMConvert.exitcode
	
	exit $TPMConvert.exitcode