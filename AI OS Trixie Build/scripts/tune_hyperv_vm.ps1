param(
  [string]$VmName = "Project-Infi-ARIS-Trixie-CoGOS",
  [string]$MemoryStartupBytes = "6GB",
  [int]$ProcessorCount = 4,
  [string]$StatusPath = "E:\project-infi\AI OS Trixie Build\output\hyperv-v12-tune-status.txt"
)

$ErrorActionPreference = "Stop"

function Convert-MemorySize {
  param([string]$Value)
  if ($Value -match '^\s*(\d+)\s*GB\s*$') { return [int64]$matches[1] * 1GB }
  if ($Value -match '^\s*(\d+)\s*MB\s*$') { return [int64]$matches[1] * 1MB }
  if ($Value -match '^\s*\d+\s*$') { return [int64]$Value }
  throw "Invalid memory size: $Value. Use bytes, MB, or GB, for example 2147483648, 2048MB, or 2GB."
}

function Assert-Administrator {
  $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
  $principal = New-Object Security.Principal.WindowsPrincipal($identity)
  if (-not $principal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
    throw "Run this script from an elevated PowerShell window so Hyper-V settings can be changed."
  }
}

Assert-Administrator
Import-Module Hyper-V

$vm = Get-VM -Name $VmName
$wasRunning = $vm.State -eq "Running"

if ($wasRunning) {
  Stop-VM -Name $VmName -TurnOff -Force
}

$memoryBytes = Convert-MemorySize $MemoryStartupBytes
Set-VMProcessor -VMName $VmName -Count $ProcessorCount | Out-Null
Set-VMMemory -VMName $VmName -DynamicMemoryEnabled $false -StartupBytes $memoryBytes | Out-Null

if ($wasRunning) {
  Start-VM -Name $VmName | Out-Null
}

Get-VM -Name $VmName |
  Select-Object Name, State, Generation, MemoryStartup, DynamicMemoryEnabled, ProcessorCount |
  Format-List |
  Out-File -Encoding utf8 $StatusPath

Write-Host "Tuned Hyper-V VM: $VmName"
Write-Host "Processors: $ProcessorCount"
Write-Host "Fixed startup memory: $MemoryStartupBytes"
