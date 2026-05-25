# Funções
function Show-IP {
  ipconfig
  Write-Host""
  Pause
  Clear-Host

}

function Test-ConnectionTarget {
  $target = Read-Host "Digite o IP ou Domínio"
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
  $base = Read-host "Digite a rede base. Ex: 192.168.0"

  Write-Host "Escaneando hosts ativos em $base.1 até $base.254..." -ForegroundColor Yellow

  for ($i =1; $i -le 254; $i++){
    $ip = "$base.$i"

    if (Test-Connection -ComputerName $ip -Count 1 -Quiet){
      Write-Host "[ONLINE] $ip" -ForegroundColor Green
    } else {
      Write-Host "[OFFLINE] $ip" -ForegroundColor DarkGray
    }
  }
  Write-Host""
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

function Auditoria-Completa{
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

do {

Show-Banner

Write-Host "[1] Mostrar IP Local" -ForegroundColor Green
Write-Host "[2] Testar Conexao (Ping)" -ForegroundColor Green
Write-Host "[3] Ver portas abertas" -ForegroundColor Green
Write-Host "[4] Ver conexoes ativas" -ForegroundColor Green
Write-Host "[5] Scanner de hosts da rede" -ForegroundColor Green
Write-Host "[6] Informacoes DNS" -ForegroundColor Green
Write-Host "[7] Auditoria completa" -ForegroundColor Green
Write-Host ""
Write-Host "[0] Sair" -ForegroundColor Red
Write-Host ""
$opcao = Read-Host "Escolha uma Opcao"




switch ($opcao){
  1 {
      Show-IP
  }

  2 {
      Test-ConnectionTarget
  }

  3 { 
      Show-Ports
  }

  4 {
      Active-Connections
  }

  5 {
      Scan-NetworkHosts
  }

  6 {
      Info-DNS
  }

  7 {
      Auditoria-Completa
  }

  0 {
    Write-Host ""
    Write-Host "Encerrando Ferramenta..." -ForegroundColor Yellow
  }
      default {
            Write-Host ""
            Write-Host "[ERRO] Opcao invalida." -ForegroundColor Red
            Pause
    }
}
} while ($opcao -ne 0)