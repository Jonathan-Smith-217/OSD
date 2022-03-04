<#PSScriptInfo
.VERSION 22.2.25.1
.GUID 55a834b8-513e-4399-bbdb-2e54a1305eee
.AUTHOR David Segura @SeguraOSD
.COMPANYNAME osdcloud.com
.COPYRIGHT (c) 2022 David Segura osdcloud.com. All rights reserved.
.TAGS OSDeploy OSDCloud WinPE OOBE Windows AutoPilot
.LICENSEURI 
.PROJECTURI https://github.com/OSDeploy/OSD
.ICONURI 
.EXTERNALMODULEDEPENDENCIES 
.REQUIREDSCRIPTS 
.EXTERNALSCRIPTDEPENDENCIES 
.RELEASENOTES
Script should be executed in a Command Prompt using the following command
powershell Invoke-Expression -Command (Invoke-RestMethod -Uri sandbox.osdcloud.com)
This is abbreviated as
powershell iex(irm sandbox.osdcloud.com)
#>
<#
.SYNOPSIS
    PSCloudScript at sandbox.osdcloud.com
.DESCRIPTION
    PSCloudScript at sandbox.osdcloud.com
.NOTES
    Version 22.2.25.1
.LINK
    https://raw.githubusercontent.com/OSDeploy/OSD/master/cloudscript/sandbox.ps1
.EXAMPLE
    powershell iex(irm sandbox.osdcloud.com)
#>
[CmdletBinding()]
param()
#----------------------------------------------------------[Initialize]----------------------------------------------------------
Write-Host -ForegroundColor DarkGray "sandbox.osdcloud.com 22.2.25.1"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-Expression -Command (Invoke-RestMethod -Uri functions.osdcloud.com)
#----------------------------------------------------------[Transcript]----------------------------------------------------------
$Transcript = "$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-OSDCloud.log"
$null = Start-Transcript -Path (Join-Path "$env:SystemRoot\Temp" $Transcript) -ErrorAction Ignore
#----------------------------------------------------------[WinPE]---------------------------------------------------------------
if ($env:SystemDrive -eq 'X:') {
    Start-WinPE -OSDCloud
    Write-Host -ForegroundColor Cyan "To start a new PowerShell session, type 'start powershell' and press enter"
    Write-Host -ForegroundColor Cyan "Start-OSDCloud or Start-OSDCloudGUI can be run in the new PowerShell session"
}
#----------------------------------------------------------[OOBE]----------------------------------------------------------------
if ($env:UserName -eq 'defaultuser0') {
    Start-OOBE -Autopilot -Display -Language -DateTime
}
#----------------------------------------------------------[Transcript]----------------------------------------------------------
$null = Stop-Transcript
#----------------------------------------------------------[End]-----------------------------------------------------------------