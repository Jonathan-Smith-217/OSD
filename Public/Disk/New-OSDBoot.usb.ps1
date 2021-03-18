function New-OSDBoot.usb {
    [CmdletBinding()]
    param (
        [ValidateLength(0,11)]
        [string]$BootLabel = 'USBBoot',

        [ValidateLength(0,32)]
        [string]$DataLabel = 'USBData'
    )

    #=======================================================================
    #	Start the Clock
    #=======================================================================
    $osdbootStartTime = Get-Date
    #=======================================================================
    #	Set Variables
    #=======================================================================
    $ErrorActionPreference = 'Stop'
    $MinimumSizeGB = 8
    $MaximumSizeGB = 1800
    #=======================================================================
    #	Block
    #=======================================================================
    Block-NonAdmin
    Block-WindowsMajorLt10
    Block-PowerShellVersionLt5
    Block-WindowsReleaseIdLt1703
    #=======================================================================
    #	Disable Autorun
    #=======================================================================
    Set-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer' -Name NoDriveTypeAutorun -Type DWord -Value 0xFF -ErrorAction SilentlyContinue
    #=======================================================================
    #	Select-USBDisk
    #   Select a USB Disk
    #=======================================================================
    $SelectUSBDisk = Select-USBDisk -MinimumSizeGB $MinimumSizeGB -MaximumSizeGB $MaximumSizeGB
    #=======================================================================
    #	Select-USBDisk
    #   Select a USB Disk
    #=======================================================================
    if (-NOT ($SelectUSBDisk)) {
        Write-Warning "No USB Drives that met the required criteria were detected"
        Write-Warning "MinimumSizeGB: $MinimumSizeGB"
        Write-Warning "MaximumSizeGB: $MaximumSizeGB"
        Break
    }
    #=======================================================================
    #	Get-USBDisk
    #   At this point I have the Disk object in $GetUSBDisk
    #=======================================================================
    $GetUSBDisk = Get-USBDisk -Number $SelectUSBDisk.Number
    #=======================================================================
    #	Clear-Disk
    #   Prompt for Confirmation
    #=======================================================================
    if (($GetUSBDisk.NumberOfPartitions -eq 0) -and ($GetUSBDisk.PartitionStyle -eq 'RAW')) {
        #Disk has already been Cleared
        #Cannot clear a Disk that has not been Initialized
    }
    else {
        $GetUSBDisk | Clear-Disk -RemoveData -RemoveOEM -Confirm:$true
    }
    #=======================================================================
    #	Get-USBDisk
    #	Run another Get-Disk to make sure that things are ok
    #=======================================================================
    $GetUSBDisk = Get-USBDisk -Number $SelectUSBDisk.Number | Where-Object {($_.NumberOfPartitions -eq 0) -and ($_.PartitionStyle -eq 'RAW')}

    if (-NOT ($GetUSBDisk)) {
        Write-Warning "Something went very very wrong in this process"
        Break
    }
    #=======================================================================
    #	-lt 2TB
    #=======================================================================
    if ($GetUSBDisk.SizeGB -lt 1800) {
        $GetUSBDisk | Initialize-Disk -PartitionStyle MBR

        $DataDisk = $GetUSBDisk | New-Partition -Size ($GetUSBDisk.Size - 2GB) -AssignDriveLetter | `
        Format-Volume -FileSystem NTFS -NewFileSystemLabel $DataLabel
        
        $BootDisk = $GetUSBDisk | New-Partition -UseMaximumSize -IsActive -AssignDriveLetter | `
        Format-Volume -FileSystem FAT32 -NewFileSystemLabel $BootLabel
    }
    #=======================================================================
    #	-ge 2TB
    #   This is not working as expected and will probably not be bootable
    #   So leaving it in here for historic purposes
    #=======================================================================
<#     if ($GetUSBDisk.SizeGB -gt 1800) {
        $GetUSBDisk | Initialize-Disk -PartitionStyle GPT
        $DataDisk = $GetUSBDisk | New-Partition -Size ($GetUSBDisk.Size - 2GB) -AssignDriveLetter | `
        Format-Volume -FileSystem NTFS -NewFileSystemLabel $DataLabel

        $BootDisk = $GetUSBDisk | New-Partition -GptType "{c12a7328-f81f-11d2-ba4b-00a0c93ec93b}" -UseMaximumSize -AssignDriveLetter | `
        Format-Volume -FileSystem FAT32 -NewFileSystemLabel $BootLabel
    } #>
    #=======================================================================
    #	Complete
    #=======================================================================
    $osdbootEndTime = Get-Date
    $osdbootTimeSpan = New-TimeSpan -Start $osdbootStartTime -End $osdbootEndTime
    Write-Host -ForegroundColor DarkGray    "========================================================================="
    Write-Host -ForegroundColor Yellow      "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $($MyInvocation.MyCommand.Name) " -NoNewline
    Write-Host -ForegroundColor Cyan        "Completed in $($osdbootTimeSpan.ToString("mm' minutes 'ss' seconds'"))"
    #=======================================================================
    #	Return
    #=======================================================================
    Return (Get-USBDisk -Number $SelectUSBDisk.Number)
    #=======================================================================
}