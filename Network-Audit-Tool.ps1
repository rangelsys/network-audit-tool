# Funções
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
            Write-Host "[ONLINE]  $ip" -ForegroundColor Green
        }
        else {
            Write-Host "[OFFLINE] $ip" -ForegroundColor DarkGray
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

    Pause
}

function Show-Banner {

    Clear-Host

    Write-Host ""
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host "          NETWORK AUDIT TOOL             " -ForegroundColor Cyan
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "     Infrastructure | Security | Audit" -ForegroundColor DarkGray
    Write-Host ""
}

function Show-Menu {
    Write-Host "[1] Mostrar IP local" -ForegroundColor White
    Write-Host "[2] Testar conexao (Ping)" -ForegroundColor White
    Write-Host "[3] Ver portas abertas" -ForegroundColor White
    Write-Host "[4] Ver conexoes ativas" -ForegroundColor White
    Write-Host "[5] Scanner de hosts" -ForegroundColor White
    Write-Host "[6] Consulta DNS" -ForegroundColor White
    Write-Host "[7] Auditoria completa" -ForegroundColor White
    Write-Host "[8] Exportar auditoria para TXT" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "[0] Sair" -ForegroundColor Red
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
        0 { Write-Host "Encerrando..." -ForegroundColor Yellow }
        default {
            Write-Host "[ERRO] Opcao invalida." -ForegroundColor Red
            Pause
        }
    }

} while ($opcao -ne 0)