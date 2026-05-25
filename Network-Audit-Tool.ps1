$Host.UI.RawUI.WindowTitle = "Network Audit Tool v1.0"

# Funções
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
    Show-Status "Coletando informacoes de Rede..." "INFO"
    ipconfig
    Show-Status "Consulta finalizada" "OK"
    Wait-Return
}

function Test-ConnectionTarget {
    Show-Section "TESTE DE CONECTIVIDADE"
    $target = Read-Host "Digite o IP ou dominio"
    Show-Status "Testando conexao com $target..." "INFO"
    ping $target
    Show-Status "Teste finalizado" "OK"
    Wait-Return
}

function Show-Ports {
    Show-Section "PORTAS ABERTAS"
    Show-Status "Coletando portas em escuta..." "INFO"
    netstat -an | findstr LISTENING
    Show-Status "Verificacao concluida" "OK"
    Wait-Return
}

function Active-Connections {
  Show-Section "CONEXÕES ATIVAS"
  Show-Status "Verificando conexoes TCP ativas." "INFO"
  Get-NetTCPConnection
  Show-Status "Verificacao concluida" "OK"
  Wait-Return
}

function Scan-NetworkHosts {
    Show-Section "SCANNER DE HOSTS"
    $base = Read-Host "Digite a rede base (Ex: 192.168.0)"
    Show-Status "Escaneando hosts da rede..." "WARNING"
    Start-Sleep -Milliseconds 700
    for ($i = 1; $i -le 20; $i++) {
        $ip = "$base.$i"
        if (Test-Connection -ComputerName $ip -Count 1 -Quiet) {
            try {
              $hostname = [System.Net.Dns]::GetHostByAddress($ip).HostName 
            }
        catch {
          $hostname = "Unknownn"
        }
        
        Write-Host "[ONLINE] " -NoNewLine -ForegroundColor Green
        Write-Host "$ip " -NoNewLine -ForegroundColor White
        Write-Host "| $hostname" -ForegroundColor DarkGray
        } else {
        Write-Host "[OFFLINE] " -NoNewLine -ForegroundColor DarkGray
        Write-Host "$ip" -ForegroundColor DarkGray
        }
    }
    Show-Status "Escaneamento finalizado" "OK"
    Wait-Return
}

function Info-DNS { 
  Show-Section "CONSULTA DNS"
  $domain = Read-Host "Digite o dominio. Ex: google.com"
  Show-Status "Consultando DNS para $domain..." "INFO"
  nslookup $domain
  Show-Status "Consulta DNS finalizada" "OK"
  Wait-Return
}

    function Auditoria-Completa {
        Show-Section "AUDITORIA COMPLETA"

        Show-Section "IP LOCAL"
        Show-Status "Coletando informacoes de IP local..." "INFO"
        ipconfig

        Show-Section "PORTAS E CONEXOES"
        Show-Status "Coletando portas e conexoes..." "INFO"
        netstat -an

        Show-Section "CONSULTA DNS"
        $domain = Read-Host "Digite um dominio para consulta DNS"
        nslookup $domain

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
    Write-Host "[*] Gerando relatorio..." -ForegroundColor Yellow

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
  Show-Status "Carregando as informacoes da Tool"
  Write-Host "Network Audit Tool v1.0"
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

    Show-Status "Gerando relatorio HTML..." "INFO"

    $date = Get-Date
    $computer = $env:COMPUTERNAME
    $user = $env:USERNAME

    $ipInfo = ipconfig | Out-String
    $ports = netstat -an | findstr LISTENING | Out-String
    $connections = Get-NetTCPConnection | Out-String

    $html = @"
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <title>Network Audit Report</title>
    <style>
        body {
            background-color: #0d1117;
            color: #c9d1d9;
            font-family: Consolas, monospace;
            margin: 40px;
        }

        h1 {
            color: #58a6ff;
        }

        h2 {
            color: #79c0ff;
            border-bottom: 1px solid #30363d;
            padding-bottom: 6px;
        }

        .info {
            background-color: #161b22;
            border: 1px solid #30363d;
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 25px;
        }

        pre {
            background-color: #161b22;
            border: 1px solid #30363d;
            padding: 15px;
            border-radius: 8px;
            overflow-x: auto;
            white-space: pre-wrap;
        }

        .ok {
            color: #3fb950;
        }
    </style>
</head>
<body>

    <h1>Network Audit Report</h1>

    <div class="info">
        <p><strong>Computador:</strong> $computer</p>
        <p><strong>Usuario:</strong> $user</p>
        <p><strong>Data:</strong> $date</p>
        <p class="ok"><strong>Status:</strong> Relatorio gerado com sucesso</p>
    </div>

    <h2>Informacoes de IP</h2>
    <pre>$ipInfo</pre>

    <h2>Portas Abertas</h2>
    <pre>$ports</pre>

    <h2>Conexoes TCP</h2>
    <pre>$connections</pre>

</body>
</html>
"@

    $html | Out-File -FilePath $file -Encoding UTF8

    Show-Status "Relatorio HTML gerado com sucesso" "OK"
    Write-Host "Local: $file" -ForegroundColor Cyan

    Start-Process $file

    Wait-Return
}

function Show-Banner {

    Clear-Host

    Write-Host ""
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host "          NETWORK AUDIT TOOL             " -ForegroundColor Cyan
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "   Infrastructure | Security | Audit" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "-----------------------------------------" -ForegroundColor DarkGray
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

    Write-Host ""

    Menu-Option "0" "Sair" "Red"
    Write-Host ""

}

do {
    Show-Banner
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
        0 { Write-Host "Encerrando..." -ForegroundColor Yellow }
        default {
            Write-Host "[ERRO] Opcao invalida." -ForegroundColor Red
            Pause
        }
    }

} while ($opcao -ne 0)