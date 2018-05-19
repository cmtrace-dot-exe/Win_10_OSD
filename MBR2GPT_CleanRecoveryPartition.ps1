############################################################################################################
### Windows 10 Recovery Partition Correction Script
### olearym
### Changelog: 	2018-05-13
############################################################################################################

# Test for powershell version, populate $PSScriptRoot if version < 3 
	if ($PSVersionTable.PSVersion.major -lt 3) {$PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent}

# Find and store the operating system partition as an object
	$osPart = $(get-partition -driveletter $($env:SystemDrive).Trim(':'))
	 
# Set target size for new recovery partition
	$rePartTargetSize = 472907776

# Remove all partitions on OS Drive that are missing boot, active & system flags, provided they are under 1GB in size.
	get-partition -DiskNumber $osPart.DiskNumber | % {if ((-not $_.IsBoot) -and (-not $_.IsActive) -and (-not $_.IsSystem) -and ($_.Size -lt 1073741824)) {Remove-Partition -InputObject $_ -confirm:$false}}

# Resize OS Partition
	Resize-partition -InputObject $osPart -Size $($(Get-PartitionSupportedSize -InputObject $osPart).SizeMax - $rePartTargetSize) 

# Create and format new recovery partition
	$rePartNew = $(New-Partition -DiskNumber $osPart.DiskNumber -usemaximumsize)
	format-volume -partition $rePartNew -FileSystem NTFS -NewFileSystemLabel "Recovery" 

# Apply correct ID number to new recovery partition
	NEW-ITEM -Path "$PSScriptRoot" -Name "DISKPART.txt" -ItemType "File" -force | OUT-NULL
	ADD-CONTENT -path "$PSScriptRoot\DISKPART.txt" -Value $('SELECT DISK ' + $($rePartNew.DiskNumber))
	ADD-CONTENT -path "$PSScriptRoot\DISKPART.txt" -Value $('SELECT PARTITION ' + $($rePartNew.PartitionNumber))
	ADD-CONTENT -path "$PSScriptRoot\DISKPART.txt" -Value "SET ID=27 OVERRIDE"
	& DISKPART /S "$PSScriptRoot\DISKPART.txt"