# WinApps: language-independent RDP firewall fix + verification.
#
# Why this exists: the upstream oem\install.bat enables the built-in "Remote Desktop"
# firewall rules with
#     Enable-NetFirewallRule -DisplayGroup 'Remote Desktop'
# and falls back to
#     netsh advfirewall firewall set rule group="remote desktop" new enable=Yes
# Both look up the group by its DISPLAY name, which is localized (on Chinese Windows
# the group is named "远程桌面"). The lookup therefore matches nothing, the rules stay
# disabled, and the inbound 3389 SYN is dropped even though TermService is listening on
# 0.0.0.0:3389 - the symptom is "port 3389 closed / connection times out".
#
# The fix below never uses a localized name: it selects the rules by the group resource
# id and by their port filter, and creates an explicit any-profile rule as a last resort.
# Output is intentionally ASCII-only so it renders in any console code page.

$ErrorActionPreference = 'Continue'

function Section($title) {
    Write-Host ''
    Write-Host ('=== ' + $title + ' ===') -ForegroundColor Cyan
}

$tsKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server'
$rdpTcpKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp'

Section 'RDP registry switches (idempotent)'
$denyBefore = (Get-ItemProperty $tsKey).fDenyTSConnections
Set-ItemProperty $tsKey -Name fDenyTSConnections -Value 0
Set-ItemProperty $rdpTcpKey -Name UserAuthentication -Value 1
# RemoteApp needs the program allow list disabled, otherwise only white-listed apps run.
New-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Terminal Server\TSAppAllowList' -Force | Out-Null
Set-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Terminal Server\TSAppAllowList' -Name fDisabledAllowList -Value 1
New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services' -Force | Out-Null
Set-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services' -Name fAllowUnlistedRemotePrograms -Value 1
Write-Host ('fDenyTSConnections: ' + $denyBefore + ' -> ' + (Get-ItemProperty $tsKey).fDenyTSConnections)

Section 'Enable the built-in Remote Desktop rules (no localized names)'
# 1) By group resource id: the same group every display language maps to.
$byGroup = @()
try {
    $byGroup = @(Get-NetFirewallRule -Group '@FirewallAPI.dll,-28752' -ErrorAction Stop)
    if ($byGroup.Count -gt 0) {
        $byGroup | Enable-NetFirewallRule
        Write-Host ('group @FirewallAPI.dll,-28752 : enabled ' + $byGroup.Count + ' rule(s)')
    }
    else {
        Write-Host 'group @FirewallAPI.dll,-28752 : matched no rule' -ForegroundColor Yellow
    }
}
catch {
    Write-Host ('group @FirewallAPI.dll,-28752 : lookup failed - ' + $_.Exception.Message) -ForegroundColor Yellow
}

# 2) By port filter: enable every inbound ACCEPT rule covering TCP/UDP 3389.
function Get-RdpPortRules {
    @(Get-NetFirewallRule -Direction Inbound -Action Allow -ErrorAction SilentlyContinue | Where-Object {
            (($_ | Get-NetFirewallPortFilter).LocalPort -contains '3389')
        })
}
$byPort = Get-RdpPortRules
if ($byPort.Count -gt 0) {
    $byPort | Enable-NetFirewallRule
    $byPort = Get-RdpPortRules
    Write-Host ('port filter 3389 : ' + $byPort.Count + ' rule(s), current state:')
    $byPort | ForEach-Object { Write-Host ('    [' + $_.Enabled + '] profile=' + $_.Profile + ' :: ' + $_.DisplayName) }
}

# 3) Last resort: an explicit rule that ignores both profile and localized names.
$enabledByPort = @($byPort | Where-Object { $_.Enabled -eq 'True' })
if ($enabledByPort.Count -eq 0) {
    Write-Host 'no enabled rule for 3389 after steps 1-2 -> creating an explicit one' -ForegroundColor Yellow
    Get-NetFirewallRule -DisplayName 'WinApps RDP 3389 (any profile)' -ErrorAction SilentlyContinue | Remove-NetFirewallRule
    New-NetFirewallRule -DisplayName 'WinApps RDP 3389 (any profile)' `
        -Direction Inbound -Protocol TCP -LocalPort 3389 -Action Allow -Profile Any | Out-Null
    Write-Host 'created: WinApps RDP 3389 (any profile)'
}

Section 'Network profile'
# Not required for RDP (the built-in rules are profile=Any), but informative: on
# "Public" everything else inbound stays blocked. Set it to Private if you later want
# host-initiated shares (SMB, ping) to work.
Get-NetConnectionProfile | ForEach-Object { Write-Host ('  ' + $_.InterfaceAlias + ' : ' + $_.NetworkCategory) }

Section 'Verification'
# Only restart TermService when needed - it kills active RDP sessions.
$needRestart = ($denyBefore -ne 0)
if (-not $needRestart) { $needRestart = -not (netstat -ano | Select-String ':3389') }
if ($needRestart) {
    Write-Host 'restarting TermService ...'
    Set-Service TermService -StartupType Automatic
    Restart-Service TermService -Force
    Start-Sleep -Seconds 3
}
Get-Service TermService | ForEach-Object { Write-Host ('  TermService = ' + $_.Status) }
$listening = netstat -ano | Select-String ':3389' | Select-Object -First 4
if ($listening) {
    $listening | ForEach-Object { Write-Host ('  ' + $_.Line.Trim()) }
}
else {
    Write-Host '  nothing listening on 3389 - check the RDP switches above and that the guest is Windows Pro/Enterprise' -ForegroundColor Yellow
}
Write-Host ''
Write-Host 'Expect: TCP 0.0.0.0:3389 LISTENING' -ForegroundColor Green
