############################################################################################################################
### Automated deletion of ConfigMgr duplicate computer records
### Fields requiring modification are contained in [BRACKETS] below
### olearym
### Changelog: 	2019-02-28:	Added logging and email notification
###				2019-03-01: Added logging notation if script runs without duplicate computers present in the SCCM database
###				2019-10-30: Sanitized for public release
############################################################################################################################
	
	$LogFile = "[YOURLOGFILEHERE].log"
	$SiteCode = "[CM1]"
	$SiteServerAddress = "[SITE SERVER ADDRESS]"
	
	Import-Module $(Join-Path $(Split-Path $ENV:SMS_ADMIN_UI_PATH) ConfigurationManager.psd1)

	$null = New-PSDrive -Name "$SiteCode" -PSProvider "AdminUI.PS.Provider\CMSite" -Root "$SiteServerAddress" -Description "SCCM Site" -ErrorAction SilentlyContinue
	
	cd "$($SiteCode):"

	# Set actionTaken flag for logging purposes
	$actionTaken = $FALSE
	
	# Logwriting Function
		
		Function LogWrite ([string]$logstring) {
			c:
			Add-content -path "$Logfile" -value "$logstring"
		}
		
	# email function
	
		function sendmail($subject, $body) {
			$EmailFrom = "[EMAIL ORIGIN]"
			$EmailTo = "[EMAIL DESTINATION]"
			$EmailBody = $body
			$EmailSubject = $subject
			$SMTPServer = "[SMTP SERVER ADDRESS]"
		 
			Send-MailMessage -From $EmailFrom -To $EmailTo -Subject $subject -body $EmailBody -SmtpServer $SMTPServer
		}	

	# Generate alpha sorted array of unique duplicate computer names from SCCM "Duplicate Computer Names" query

		$duplicateComputersUnique = invoke-cmquery -name "duplicate computer names" | sort-object -property name -unique | select-object -expandproperty name

	# Loop through duplicate computer name list & recursively loop through all SCCM device objects associated with that name. Take action on records where Client Presence = FALSE

		foreach ($computer in $duplicateComputersUnique) {
			cd "$($SiteCode):"
			Get-CMDevice -name $computer | % {			
				if ($_.IsClient -eq $False) {
					
					# Remove bunk SCCM device record
						
						Remove-CMResource -ResourceID $_.ResourceID -force
					
					# email log data 	
						$subjectString = "A duplicate computer record for device $($_.name) has been deleted from the SCCM database."
			
						$body = "A duplicate computer record for device $($_.name) was deleted from the SCCM database at $(get-date).`n`nThis action was performed by a script located at [PATH TO SCRIPT]\deleteDuplicateComputerRecord.ps1.`n`nThis information has also been logged to $LogFile."
						
						sendmail $subjectString $body

					# Write action to log
							
						logwrite $(get-date), $subjectString
						
					# Modify and revert changes to associated AD object in order to trigger an AD Delta Discovery update
					
						$ADdescriptionMod = "This field was modified by a script written by [YOUR NAME HERE] to address duplicate computer records in SCCM. If you are reading this, please contact him as soon as possible. $(get-date -format o)"
						$ComputerDn = ([ADSISEARCHER]"sAMAccountName=$($_.name)$").FindOne().Path
						$ADComputer = [ADSI]$ComputerDn
						$ADComputer.description = $ADdescriptionMod
						$ADComputer.SetInfo()
						
						$ADdescriptionMod = $null
						$ADComputer = [ADSI]$ComputerDn
						$ADComputer.description.Remove("$($ADComputer.description)")
						$ADComputer.SetInfo()						
						
					# Flip actionTaken flag to TRUE
						
						$actionTaken = $TRUE
				}
			}
		}
		
	# Record that no action was taken if script has run without duplicate computers present in the SCCM database
	
		if ($actionTaken -eq $FALSE) {logwrite $(get-date), "A task sequence has completed without duplicate computers present in the SCCM database."}
		
		remove-PSDrive -Name $SiteCode