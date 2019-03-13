$InventoryActionStatus = Get-WmiObject -Namespace "root\ccm\invagt" -Query "select * from InventoryActionStatus where InventoryActionID = '{00000000-0000-0000-0000-000000000001}'" | Remove-WmiObject

$RunInventory = Invoke-WMIMethod -Namespace "root\ccm" -Class "SMS_CLIENT" -Name TriggerSchedule "{00000000-0000-0000-0000-000000000001}"