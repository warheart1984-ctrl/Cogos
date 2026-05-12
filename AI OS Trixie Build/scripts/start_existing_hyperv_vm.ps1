param(
  [string]$VmName = "Project-Infi-ARIS-Trixie-CoGOS",
  [string]$StatusPath = "E:\project-infi\AI OS Trixie Build\output\hyperv-start.txt",
  [string]$MemoryStartupBytes = "6GB",
  [int]$ProcessorCount = 4
)

$ErrorActionPreference = "Stop"

function Convert-MemorySize {
  param([string]$Value)
  if ($Value -match '^\s*(\d+)\s*GB\s*$') { return [int64]$matches[1] * 1GB }
  if ($Value -match '^\s*(\d+)\s*MB\s*$') { return [int64]$matches[1] * 1MB }
  if ($Value -match '^\s*\d+\s*$') { return [int64]$Value }
  throw "Invalid memory size: $Value. Use bytes, MB, or GB, for example 2147483648, 2048MB, or 2GB."
}

try {
  Import-Module Hyper-V

  $vm = Get-VM -Name $VmName
  if ($vm.State -ne "Running") {
    $memoryBytes = Convert-MemorySize $MemoryStartupBytes
    Set-VMProcessor -VMName $VmName -Count $ProcessorCount | Out-Null
    Set-VMMemory -VMName $VmName -DynamicMemoryEnabled $false -StartupBytes $memoryBytes | Out-Null
    Start-VM -Name $VmName
  }

  Get-VM -Name $VmName |
    Select-Object Name, State, Generation, MemoryStartup, ProcessorCount |
    Format-List |
    Out-File -Encoding utf8 $StatusPath

  Start-Process vmconnect.exe -ArgumentList "localhost", $VmName
} catch {
  ("ERROR: " + $_.Exception.Message) | Out-File -Encoding utf8 $StatusPath
  throw
}
