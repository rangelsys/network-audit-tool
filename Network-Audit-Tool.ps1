# Funções
function Show-IP {
  ipconfig
  Write-Host""
  Pause
  Clear-Host

}

function Test-ConnectionTarget {
  $target = Read-Host "Digite o IP ou Dominio"
  ping $target
  Write-Host""
  Pause
  Clear-Host
}

function Show-Ports {
  netstat -an
  Write-Host""
  Pause
  Clear-Host
}

function Active-Connections {
  Get-NetTCPConnection
  Write-Host""
  Pause
  Clear-Host
}

function Scan-NetworkHosts {

    $base = Read-Host "Digite a rede base (Ex: 192.168.0)"

    Write-Host ""
    Write-Host "Escaneando hosts da rede..." -ForegroundColor Yellow
    Write-Host ""

    for ($i = 1; $i -le 20; $i++) {

        $ip = "$base.$i";

        if (Test-Connection -ComputerName $ip -Count 1 -Quiet) {

            Write-Host "[ONLINE]  $ip" -ForegroundColor Green
        }

        else {

            Write-Host "[OFFLINE] $ip" -ForegroundColor DarkGray
        }
    }

    Write-Host ""
    Pause
    Clear-Host
}

function Info-DNS { 
  $domain = Read-Host "Digite o dominio. Ex: google.com"
  nslookup $domain
  Write-Host""
  Pause
  Clear-Host
}

function Auditoria-Completa {
    Write-Host "Executando auditoria completa..." -ForegroundColor Yellow

    Write-Host "`n[IP LOCAL]" -ForegroundColor Cyan
    ipconfig

    Write-Host "`n[PORTAS / CONEXOES]" -ForegroundColor Cyan
    netstat -an

    Write-Host "`n[DNS]" -ForegroundColor Cyan
    $domain = Read-Host "Digite um dominio para consulta DNS"
    nslookup $domain
  Write-Host""
  Pause    
  Clear-Host
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