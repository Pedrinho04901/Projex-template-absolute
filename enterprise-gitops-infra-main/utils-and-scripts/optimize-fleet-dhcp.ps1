<#
.SYNOPSIS
    Projex Absolute Utility: Automa??o de Resili?ncia Local.
    Objetivo: Eliminar DNS est?tico/manual e for?ar as m?quinas a herdar o DHCP Inteligente da rede.
#>

Write-Host "?? Verificando adaptadores de rede ativos no Windows..." -ForegroundColor Cyan
$interfaces = Get-NetAdapter | Where-Object {$_.Status -eq "Up"}

foreach ($interface in $interfaces) {
    Write-Host "? Convertendo interface [$($interface.Name)] para usar DNS via DHCP..." -ForegroundColor Yellow
    
    # Executa a limpeza do DNS manual e for?a a busca autom?tica via roteador
    Set-DnsClientServerAddress -InterfaceAlias $interface.Name -ResetServerAddresses -ErrorAction SilentlyContinue
}

Write-Host "?? Limpando o cache antigo de DNS (Flushing DNS)..." -ForegroundColor Cyan
Clear-DnsClientCache

Write-Host "? Sucesso! A m?quina agora herda o ecossistema de DNS indestrut?vel da rede." -ForegroundColor Green
