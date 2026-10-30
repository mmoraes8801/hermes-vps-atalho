# Instalador do atalho "Hermes": abre tunel SSH para a VPS e o chat do Hermes no navegador.
# Uso: irm https://raw.githubusercontent.com/mmoraes8801/hermes-vps-atalho/main/install.ps1 | iex
$ErrorActionPreference = 'Stop'
$VpsHost = '187.127.8.203'
$VpsUser = 'agatha'
$LocalPort = 19119

if (-not (Get-Command ssh.exe -ErrorAction SilentlyContinue)) {
    Write-Host 'OpenSSH Client nao encontrado. Instalando (pede permissao de administrador)...'
    Start-Process powershell -Verb RunAs -Wait -ArgumentList '-NoProfile -Command "Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0"'
    $env:Path += ";$env:WINDIR\System32\OpenSSH"
}

$sshDir = Join-Path $env:USERPROFILE '.ssh'
$key = Join-Path $sshDir 'hermes_vps'
New-Item -ItemType Directory -Force $sshDir | Out-Null
if (-not (Test-Path $key)) {
    # Chave sem senha: o atalho precisa abrir sem perguntar nada
    & ssh-keygen.exe -q -t ed25519 -N '""' -C "$env:USERNAME-hermes" -f $key
}

$appDir = Join-Path $env:LOCALAPPDATA 'HermesVPS'
New-Item -ItemType Directory -Force $appDir | Out-Null
$launcher = Join-Path $appDir 'hermes.ps1'
@"
`$url = 'http://localhost:$LocalPort/chat'
`$open = Test-NetConnection localhost -Port $LocalPort -InformationLevel Quiet -WarningAction SilentlyContinue
if (-not `$open) {
    Start-Process ssh.exe -WindowStyle Hidden -ArgumentList '-N','-i','$key','-o','BatchMode=yes','-o','StrictHostKeyChecking=accept-new','-o','ExitOnForwardFailure=yes','-o','ServerAliveInterval=30','-L','${LocalPort}:127.0.0.1:9119','$VpsUser@$VpsHost'
    for (`$i = 0; `$i -lt 20 -and -not `$open; `$i++) {
        Start-Sleep -Milliseconds 500
        `$open = Test-NetConnection localhost -Port $LocalPort -InformationLevel Quiet -WarningAction SilentlyContinue
    }
}
if (`$open) { Start-Process `$url }
else {
    Add-Type -AssemblyName PresentationFramework
    [System.Windows.MessageBox]::Show('Nao consegui conectar na VPS. Verifique a internet ou se a chave ja foi autorizada.', 'Hermes') | Out-Null
}
"@ | Set-Content -Encoding UTF8 $launcher

$lnk = Join-Path ([Environment]::GetFolderPath('Desktop')) 'Hermes.lnk'
$sc = (New-Object -ComObject WScript.Shell).CreateShortcut($lnk)
$sc.TargetPath = 'powershell.exe'
$sc.Arguments = "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$launcher`""
$sc.IconLocation = 'shell32.dll,13'
$sc.Save()

$pub = Get-Content "$key.pub"
try { Set-Clipboard $pub } catch {}
Write-Host ''
Write-Host 'Atalho "Hermes" criado na Area de Trabalho.' -ForegroundColor Green
Write-Host 'Ultimo passo (so na primeira vez): mande esta chave para o Marcelo autorizar (ja esta copiada):' -ForegroundColor Yellow
Write-Host $pub
