$Host.UI.RawUI.WindowTitle = "Network Audit Tool v1.0"

# Funções 
Function Show-Loading {
  param(
    [string]$Message = "Carregando",
    [int]$Seconds = 2
  )

  Write-Host ""
  Write-Host "[*] $Message" -NoNewLine -ForegroundColor Yellow

  for ($i = 0; $i -lt $Seconds; $i++ ){
    Start-Sleep -Milliseconds 500
    Write-Host "." -NoNewLine -ForegroundColor Yellow
    Start-Sleep -Milliseconds 500
    Write-host "." -NoNewLine -ForegroundColor Yellow
  }

  Write-Host ""

}

function Menu-Option {
  param (
    [string]$Number,
    [string]$Text,
    [string]$Color = "Cyan"
  )

  Write-Host "[$Number] " -NoNewLine -ForegroundColor $Color
  Write-Host $Text -ForegroundColor White
}

function Show-Section {
  param([string]$Title)

    Write-Host ""
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host "          $Title" -ForegroundColor Cyan
    Write-Host "=========================================" -ForegroundColor Cyan

}

  function Show-Status {
    param(
        [string]$Message,
        [string]$Type = "INFO"
    )

    if ($Type -eq "OK") {
        Write-Host "[OK] $Message" -ForegroundColor Green
    }
    elseif ($Type -eq "WARNING") {
        Write-Host "[WARNING] $Message" -ForegroundColor Yellow
    }
    elseif ($Type -eq "ERROR") {
        Write-Host "[ERROR] $Message" -ForegroundColor Red
    }
    else {
        Write-Host "[*] $Message" -ForegroundColor Gray
    }
}

function Wait-Return {
    Write-Host ""
    Pause
}

function Show-IP {
    Show-Section "IP LOCAL"
    Show-Loading "Coletando informacoes de Rede" 2
    ipconfig
    Write-Host ""
    Show-Status "Consulta finalizada" "OK"
    Wait-Return
}

function Test-ConnectionTarget {
    Show-Section "TESTE DE CONECTIVIDADE"
    $target = Read-Host "Digite o IP ou dominio"
    Show-Loading "Testando conexao com $target" 2
    ping $target
    Write-Host ""
    Show-Status "Teste finalizado" "OK"
    Wait-Return
}

function Show-Ports {
    Show-Section "PORTAS ABERTAS"
    Show-Loading "Coletando portas em escuta" 2
    netstat -an | findstr LISTENING
    Write-Host ""
    Show-Status "Verificacao concluida" "OK"
    Wait-Return
}

function Active-Connections {
  Show-Section "CONEXÕES ATIVAS"
  Show-Loading "Verificando conexoes TCP ativas" 2
  Get-NetTCPConnection
  Write-Host ""
  Show-Status "Verificacao concluida" "OK"
  Wait-Return
}

function Scan-NetworkHosts {

    Show-Section "SCANNER DE HOSTS"

    $localIP = (Get-NetIPAddress -AddressFamily IPv4 |
        Where-Object {
            $_.IPAddress -notlike "127.*" -and
            $_.IPAddress -notlike "169.254.*" -and
            $_.PrefixOrigin -ne "WellKnown"
        } |
        Select-Object -First 1 -ExpandProperty IPAddress)

    $base = ($localIP -split "\.")[0..2] -join "."

    Show-Status "Rede detectada automaticamente: $base.0/24" "OK"
    Show-Status "Escaneando hosts de $base.1 ate $base.20" "WARNING"

    for ($i = 1; $i -le 20; $i++) {

          $ip = "$base.$i"
          $percent = [int](($i / 20) * 100)

          Write-Host "[SCAN] " -NoNewline -ForegroundColor Yellow
          Write-Host "$ip " -NoNewline -ForegroundColor White
          Write-Host "($percent%)" -ForegroundColor DarkGray

          $ping = Test-Connection -ComputerName $ip -Count 1 -ErrorAction SilentlyContinue

        if ($ping) {

            try {
                $hostname = [System.Net.Dns]::GetHostByAddress($ip).HostName
            }
            catch {
                $hostname = "Unknown"
            }

            $time = $ping.ResponseTime

            Write-Host "[ONLINE]  " -NoNewline -ForegroundColor Green
            Write-Host "$ip " -NoNewline -ForegroundColor White
            Write-Host "| $hostname " -NoNewline -ForegroundColor DarkGray
            Write-Host "| ${time}ms" -ForegroundColor Cyan
        }
        else {
            Write-Host "[OFFLINE] " -NoNewline -ForegroundColor DarkGray
            Write-Host "$ip" -ForegroundColor DarkGray
        }
    }

    Show-Status "Escaneamento finalizado" "OK"
    Wait-Return
}

function Info-DNS { 
  Show-Section "CONSULTA DNS"
  $domain = Read-Host "Digite o dominio. Ex: google.com"
  Show-Loading "Consultando DNS para $domain" 2
  nslookup $domain
  Write-Host ""
  Show-Status "Consulta DNS finalizada" "OK"
  Wait-Return
}

    function Auditoria-Completa {
        Show-Section "AUDITORIA COMPLETA"

        Show-Section "IP LOCAL"
        Show-Loading "Coletando informacoes de IP local" 2
        ipconfig

        Show-Section "PORTAS E CONEXOES"
        Show-Loading "Coletando portas e conexoes" 2
        netstat -an

        Show-Section "CONSULTA DNS"
        $domain = Read-Host "Digite um dominio para consulta DNS"
        nslookup $domain

        Write-Host ""
        Show-Status "Auditoria completa finalizada" "OK"
        Wait-Return
  } 

function Export-AuditReport {

    $folder = "$PSScriptRoot\reports"

    if (!(Test-Path $folder)) {
        New-Item -ItemType Directory -Path $folder | Out-Null
    }

    $file = "$folder\network-audit-report.txt"

    Write-Host ""
    Show-Loading "[*] Gerando relatorio" 2

    $content = @()

    $content += "NETWORK AUDIT TOOL - RELATORIO"
    $content += "Gerado em: $(Get-Date)"
    $content += ""

    $content += "[IP LOCAL]"
    $content += ipconfig

    $content += ""
    $content += "[PORTAS ABERTAS]"
    $content += netstat -an

    $content += ""
    $content += "[CONEXOES ATIVAS]"
    $content += Get-NetTCPConnection

    $content | Out-File -FilePath $file -Encoding utf8

    Write-Host "[OK] Relatorio gerado com sucesso!" -ForegroundColor Green
    Write-Host "Local: $file" -ForegroundColor Cyan
}

function InfoTool {
  Show-Section "INFO TOOL"
  Show-Loading "Carregando as informacoes da Tool" 2
  Write-Host "Network Audit Tool v1.1"
  Write-Host "Developed by rangelsys"
  Wait-Return
}

function Export-HtmlReport {

    Show-Section "EXPORTAR RELATORIO HTML"

    $folder = "$PSScriptRoot\reports"

    if (!(Test-Path $folder)) {
        New-Item -ItemType Directory -Path $folder | Out-Null
    }

    $file = "$folder\network-audit-report.html"

    Show-Loading "Gerando relatorio HTML" 2

    $date = Get-Date
    $computer = $env:COMPUTERNAME
    $user = $env:USERNAME
    $os = Get-CimInstance Win32_OperatingSystem
    $cpu = Get-CimInstance Win32_Processor
    $ramGB = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)

    $ipInfo = ipconfig | Out-String
    $ports = netstat -an | findstr LISTENING | Out-String
    $connections = Get-NetTCPConnection | Out-String

    $sensitivePorts = @{
    21   = "FTP"
    22   = "SSH"
    23   = "Telnet"
    80   = "HTTP"
    135  = "RPC"
    139  = "NetBIOS"
    443  = "HTTPS"
    445  = "SMB"
    3306 = "MySQL"
    3389 = "RDP"
    5432 = "PostgreSQL"
    5900 = "VNC"
}

$listeningPorts = Get-NetTCPConnection -State Listen |
    Select-Object -ExpandProperty LocalPort -Unique

$sensitiveHtml = ""

foreach ($port in $sensitivePorts.Keys) {
    if ($listeningPorts -contains $port) {
        $service = $sensitivePorts[$port]

        $level = "warning"

        if ($port -eq 23 -or $port -eq 3389 -or $port -eq 5900) {
            $level = "danger"
        }

        $sensitiveHtml += "<span class='badge $level'>Porta $port - $service</span>"
    }
}

if ($sensitiveHtml -eq "") {
    $sensitiveHtml = "<span class='badge ok'>Nenhuma porta sensivel detectada</span>"
}

    $html = @"
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <title>Network Audit Report</title>
<style>
    body {
        background: #0d1117;
        color: #c9d1d9;
        font-family: Consolas, monospace;
        margin: 0;
        padding: 40px;
    }

    .container {
        max-width: 1100px;
        margin: auto;
    }

    .header {
        background: linear-gradient(135deg, #161b22, #0d1117);
        border: 1px solid #30363d;
        border-radius: 12px;
        padding: 25px;
        margin-bottom: 25px;
    }

    h1 {
        color: #58a6ff;
        margin: 0;
    }

    .subtitle {
        color: #8b949e;
        margin-top: 8px;
    }

    .grid {
        display: grid;
        grid-template-columns: repeat(3, 1fr);
        gap: 15px;
        margin-bottom: 25px;
    }

    .card {
        background: #161b22;
        border: 1px solid #30363d;
        border-radius: 10px;
        padding: 15px;
    }

    .label {
        color: #8b949e;
        font-size: 13px;
    }

    .value {
        color: #f0f6fc;
        font-size: 16px;
        margin-top: 5px;
    }

    h2 {
        color: #79c0ff;
        border-bottom: 1px solid #30363d;
        padding-bottom: 6px;
    }

    pre {
        background: #161b22;
        border: 1px solid #30363d;
        padding: 15px;
        border-radius: 10px;
        overflow-x: auto;
        white-space: pre-wrap;
    }

    .ok {
        color: #3fb950;
    }

    .badge {
    display: inline-block;
    padding: 8px 12px;
    margin: 5px;
    border-radius: 999px;
    font-weight: bold;
    font-size: 13px;
}

.badge.ok {
    background: #12391f;
    color: #3fb950;
    border: 1px solid #238636;
}

.badge.warning {
    background: #3d2f00;
    color: #f2cc60;
    border: 1px solid #d29922;
}

.badge.danger {
    background: #3d1117;
    color: #ff7b72;
    border: 1px solid #f85149;
}

</style>
</head>
<body>
<div class="container">

    <div class="header">
        <h1>Network Audit Report</h1>
        <div class="subtitle">Infrastructure / Security / Audit</div>
    </div>

    <div class="grid">
        <div class="card">
            <div class="label">Computador</div>
            <div class="value">$computer</div>
        </div>

        <div class="card">
            <div class="label">Usuario</div>
            <div class="value">$user</div>
        </div>

        <div class="card">
            <div class="label">Sistema</div>
            <div class="value">$($os.Caption)</div>
        </div>

        <div class="card">
            <div class="label">Arquitetura</div>
            <div class="value">$($os.OSArchitecture)</div>
        </div>

        <div class="card">
            <div class="label">Processador</div>
            <div class="value">$($cpu.Name)</div>
        </div>

        <div class="card">
            <div class="label">RAM</div>
            <div class="value">$ramGB GB</div>
        </div>
    </div>

    <h2>Informacoes de IP</h2>
    <pre>$ipInfo</pre>

    <h2>Portas Sensiveis Detectadas</h2>
    <div class="card">
      $sensitiveHtml
    </div>

    <h2>Portas Abertas</h2>
    <pre>$ports</pre>

    <h2>Conexoes TCP</h2>
    <pre>$connections</pre>

</div>
</body>
</html>
"@

    $html | Out-File -FilePath $file -Encoding UTF8

    Show-Status "Relatorio HTML gerado com sucesso" "OK"
    Write-Host "Local: $file" -ForegroundColor Cyan

    Start-Process $file

    Wait-Return
}

function System-Info {
    Show-Section "INFORMACOES DO SISTEMA"

    Show-Loading "Coletando informacoes do sistema" 2

    $os = Get-CimInstance Win32_OperatingSystem
    $cpu = Get-CimInstance Win32_Processor
    $ramGB = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
    Write-Host ""
    Write-Host "Computador: $env:COMPUTERNAME" -ForegroundColor White
    Write-Host "Usuario: $env:USERNAME" -ForegroundColor White
    Write-Host "Sistema: $($os.Caption)" -ForegroundColor White
    Write-Host "Versao: $($os.Version)" -ForegroundColor White
    Write-Host "Arquitetura: $($os.OSArchitecture)" -ForegroundColor White
    Write-Host "Processador: $($cpu.Name)" -ForegroundColor White
    Write-Host "Memoria RAM: $ramGB GB" -ForegroundColor White

    Write-Host ""
    Show-Status "Consulta finalizada" "OK"
    Wait-Return
}

function Show-AnimatedBanner {
    Clear-Host

    $lines = @(
        "=========================================",
        "          NETWORK AUDIT TOOL",
        "=========================================",
        "  Infrastructure | Security | Audit",
        "========================================="
    )

    foreach ($line in $lines) {
        Write-Host $line -ForegroundColor Cyan
        Start-Sleep -Milliseconds 120
    }

    Write-Host ""
}

function Show-Menu {
    Menu-Option "1" "Mostrar IP Local"
    Menu-Option "2" "Testar Conexao ( Ping )"
    Menu-Option "3" "Ver portas abertas"
    Menu-Option "4" "Ver conexoes ativas"
    Menu-Option "5" "Scanner de Hosts"
    Menu-Option "6" "Consulta DNS"
    Menu-Option "7" "Auditoria Completa"

    Menu-Option "8" "Exportar auditoria para TXT" "Yellow"
    Menu-Option "9" "Sobre a Ferramenta" "Magenta"
    Menu-Option "10" "Exportar relatorio HTML" "Magenta"
    Menu-Option "11" "Informacoes do Sistema" "Magenta"

    Write-Host ""

    Menu-Option "0" "Sair" "Red"
    Write-Host ""

}

do {
    Show-AnimatedBanner
    Show-Menu

    $opcao = Read-Host "Escolha uma opcao"

    switch ($opcao) {
        1 { Show-IP }
        2 { Test-ConnectionTarget }
        3 { Show-Ports }
        4 { Active-Connections }
        5 { Scan-NetworkHosts }
        6 { Info-DNS }
        7 { Auditoria-Completa }
        8 { Export-AuditReport }
        9 { InfoTool }
        10 {Export-HtmlReport}
        11 {System-Info}
        0 { Write-Host "Encerrando..." -ForegroundColor Yellow }
        default {
            Write-Host "[ERRO] Opcao invalida." -ForegroundColor Red
            Pause
        }
    }

} while ($opcao -ne 0)