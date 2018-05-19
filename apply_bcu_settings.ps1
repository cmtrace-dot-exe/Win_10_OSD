############################################################################################################
### HP BCU Settings Configuration Script
### olearym
### Changelog: 	2018-05-01
############################################################################################################

# Test for powershell version, populate $PSScriptRoot if version < 3 
	if ($PSVersionTable.PSVersion.major -lt 3) {$PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent}

# Run the HP BIOS Configuration Utility and feed it a settings *.txt file titled the same as the client's WMI model name. 
# Per the above, if your client's CSProduct name is "HP ProDesk 600 G2 SFF", name your settings file "HP ProDesk 600 G2 SFF.txt" 
# Create the same for each model you intend to configure.
# Place each model's settings file and BiosConfigUtility64.exe at the root of the same directory as this script. 

	$apply = & "$PSScriptRoot\BiosConfigUtility64.exe" $('/set:' + $("`"$PSScriptRoot" + '\' + "$($(get-wmiobject Win32_ComputerSystemProduct name).name)" + ".txt`""))

	exit $apply.exitcode