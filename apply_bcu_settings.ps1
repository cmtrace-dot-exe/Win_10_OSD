############################################################################################################
### HP BCU Settings Configuration Script
### olearym
### Changelog: 	2018-05-19
############################################################################################################

# Test for powershell version, populate $PSScriptRoot if version < 3 
	if ($PSVersionTable.PSVersion.major -lt 3) {$PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent}

# The following runs the HP BIOS Configuration Utility and feeds it a settings *.txt file titled the same as the client's WMI model name. 
# Per the above, if your client's CSProduct name is "HP ProDesk 600 G2 SFF", name your settings file "HP ProDesk 600 G2 SFF.txt" 
# Create the same for each model you intend to configure.
# Place each model's settings file and the BiosConfigUtility files at the root of the same directory as this script. 
# 
# You can modify the below string with the following BiosConfigUtility flags to match the needs of your environment:
#
#		/get:"filename"        			Saves the system BIOS settings to the given file.
#										If filename is not provided, output is to console.
#		/set:"filename"        			Applies system BIOS setting changes from the provided
#										configuration file.
#		/verbose               			(With Set) Display details about each setting such as
#										failure code and reason.
#		/warningaserr          			(With Set) Any settings skipped due to warnings
#										will cause return error code 13.
#		/setdefaults           			Sets BIOS settings to their default values.
#		/cpwdfile:"filename"   			Specifies a file with the current BIOS Setup Password.
#										Use HPQPswd.exe to create the password file.
#		/npwdfile:"filename"   			Specifies a file with a new password to set.
#										To remove the password, use /nspwdfile:"".
#										Use HPQPswd.exe to create the password file.
#		/getvalue:"setting"    			Retrieves and displays the value of the given setting.
#		/setvalue:"setting","value"		Applies the new value to the given setting.
#		/unicode               			Checks for Unicode password support and exits with
#										return code.
#		/l or /log             			Generates log files in Logs subfolder.
#		/logpath:"file path"   			Saves the logs to the given file path
#		/? or /help            			Displays this help message.

	if ($([System.Environment]::Is64BitOperatingSystem)) {
		$apply = & "$PSScriptRoot\BiosConfigUtility64.exe" $('/set:' + $("`"$PSScriptRoot" + '\' + "$($(get-wmiobject Win32_ComputerSystemProduct name).name)" + ".txt`""))
	}
	else {
		$apply = & "$PSScriptRoot\BiosConfigUtility.exe" $('/set:' + $("`"$PSScriptRoot" + '\' + "$($(get-wmiobject Win32_ComputerSystemProduct name).name)" + ".txt`""))
	}
	
	exit $apply.exitcode