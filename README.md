# hermes-vps-atalho

Cria o atalho **Hermes** na Área de Trabalho (Windows). Ao clicar, ele abre um túnel SSH até a VPS e abre o chat do Hermes no navegador (`http://localhost:19119/chat`).

## Instalar (PowerShell, sem admin)

```powershell
irm https://raw.githubusercontent.com/mmoraes8801/hermes-vps-atalho/main/install.ps1 | iex
```

No fim, o instalador mostra uma chave pública (já copiada). Ela precisa ser autorizada na VPS uma vez:

```bash
echo '<chave>' | ssh agatha@187.127.8.203 'cat >> ~/.ssh/authorized_keys'
```

Nenhum segredo fica neste repositório: a chave privada é gerada no próprio notebook.
