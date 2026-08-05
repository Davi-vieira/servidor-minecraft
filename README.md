# 🎮 Servidor Minecraft PaperMC — Automatizado com Amazon Q

![Minecraft](https://img.shields.io/badge/Minecraft-1.21.4-green?style=flat&logo=minecraft)
![PaperMC](https://img.shields.io/badge/PaperMC-1.21.4--150-blue?style=flat)
![Java](https://img.shields.io/badge/Java-21-orange?style=flat&logo=openjdk)
![Ubuntu](https://img.shields.io/badge/Ubuntu-24.04_LTS-E95420?style=flat&logo=ubuntu)
![Shell](https://img.shields.io/badge/Shell-Script-black?style=flat&logo=gnubash)

Projeto de servidor Minecraft completo, com instalação automatizada via scripts Shell, suporte a Java e Bedrock (celular/console), autenticação, proteção de terreno e túnel de rede sem precisar abrir portas no roteador.

> **Este projeto foi desenvolvido com o auxílio do [Amazon Q Developer](https://aws.amazon.com/q/developer/)**, a IA da AWS integrada ao VS Code. Toda a lógica dos scripts, configurações e otimizações foram criadas em conjunto com a IA, o que acelerou muito o desenvolvimento e me ensinou boas práticas de Shell scripting e administração de servidores Linux.

---

## 📋 O que este projeto faz

- Instala e configura um servidor Minecraft **PaperMC** do zero em um servidor Linux (Ubuntu 24.04)
- Baixa automaticamente todos os plugins necessários via API/GitHub
- Configura o servidor como um **serviço systemd** (inicia automaticamente com o sistema)
- Suporta jogadores **Java (PC)** e **Bedrock (celular/console)** ao mesmo tempo
- Usa **Playit.gg** como túnel de rede — sem precisar de IP fixo ou abrir portas no roteador
- Otimizado para rodar em hardware limitado (notebook antigo, 4–8GB RAM)

---

## 🏗️ Arquitetura do Projeto

```
servidor mine/
├── install.sh          # Script mestre de instalação (executa tudo)
├── setup-server.sh     # Baixa PaperMC e todos os plugins automaticamente
├── start.sh            # Inicia o servidor com flags JVM otimizadas (Aikar's Flags)
├── update-system.sh    # Atualiza o sistema e instala dependências (Java 21, wget, jq...)
├── minecraft.service   # Arquivo de serviço systemd
├── server.properties   # Configurações do servidor
└── novos mods/         # Plugins adicionais (LuckPerms, VoiceChat, GravesX)
```

---

## ⚙️ Tecnologias e Ferramentas

| Tecnologia | Função |
|---|---|
| **PaperMC** | Engine do servidor Minecraft (fork otimizado do Spigot) |
| **GeyserMC** | Permite jogadores Bedrock (celular/console) conectarem |
| **Floodgate** | Autenticação automática para jogadores Bedrock |
| **AuthMe** | Sistema de login/senha para jogadores Java (modo offline) |
| **GriefPrevention** | Proteção de terreno contra griefing |
| **LuckPerms** | Sistema de cargos e permissões |
| **GravesX** | Cria túmulo com os itens ao morrer |
| **SetHome** | Sistema de casas (/sethome, /home) |
| **Simple Voice Chat** | Chat de voz por proximidade |
| **Playit.gg** | Túnel de rede (sem IP fixo, sem abrir portas) |
| **systemd** | Gerenciamento do servidor como serviço do sistema |
| **Java 21** | Runtime do servidor |
| **Ubuntu 24.04 LTS** | Sistema operacional do servidor |

---

## 🚀 Como Instalar

### Pré-requisitos
- Ubuntu Server 24.04 LTS
- Acesso root/sudo
- Conexão com a internet
- Mínimo 2GB de RAM (recomendado 4GB+)
- Mínimo 10GB de espaço em disco

### Versões suportadas

| Software | Versão |
|---|---|
| Minecraft Java | 1.21.4 |
| Minecraft Bedrock | 1.21.x (via GeyserMC) |
| PaperMC | 1.21.4 build 150 |
| Java | 21 (OpenJDK) |
| Ubuntu | 24.04 LTS |

### Instalação em 1 comando

```bash
git clone https://github.com/Davi-vieira/servidor-minecraft.git
cd servidor-minecraft
chmod +x install.sh
sudo ./install.sh
```

O script `install.sh` vai automaticamente:
1. Atualizar o sistema e instalar Java 21
2. Criar o usuário `minecraft` no sistema
3. Baixar o PaperMC e todos os plugins via `setup-server.sh`
4. Copiar os arquivos para `/home/minecraft/minecraft-server/`
5. Registrar e habilitar o serviço systemd

### Gerenciar o servidor

```bash
sudo systemctl start minecraft    # Iniciar
sudo systemctl stop minecraft     # Parar
sudo systemctl restart minecraft  # Reiniciar
sudo journalctl -u minecraft -f   # Ver logs em tempo real
```

---

## 🧠 Como foi desenvolvido com Amazon Q

Este projeto foi criado do zero usando o **Amazon Q Developer** no VS Code. O processo foi:

1. **Descrevi o objetivo** para a IA: queria um servidor Minecraft que rodasse automaticamente no Linux, suportasse Java e Bedrock, e fosse fácil de instalar
2. **A IA gerou os scripts** Shell com boas práticas: tratamento de erros (`set -e`), retry em downloads, detecção automática de RAM, flags JVM otimizadas
3. **Iteramos juntos** — quando algo não funcionava (ex: API do PaperMC retornando versão inválida), eu reportava o erro e a IA corrigia e explicava o motivo
4. **Aprendi no processo** — entendi como funciona systemd, Aikar's Flags para JVM, e como o GeyserMC faz a ponte entre os dois protocolos do Minecraft

> Usar Amazon Q foi como ter um sênior de DevOps do lado explicando cada decisão técnica enquanto escrevia o código.

---

## 🔧 Destaques Técnicos

### Detecção automática de RAM (`start.sh`)
O script detecta a RAM total do sistema e aloca 60% para a JVM, com limites mínimo (1GB) e máximo (4GB):

```bash
TOTAL_RAM_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
RECOMMENDED_RAM=$((TOTAL_RAM_MB * 60 / 100))
```

### Aikar's Flags — JVM otimizada para Minecraft
Flags especiais para o G1GC que reduzem pausas de garbage collection e melhoram a performance do servidor:

```bash
java -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 ...
```

### Download com retry e validação (`setup-server.sh`)
Todos os downloads verificam o tamanho do arquivo para garantir que não baixou um HTML de erro:

```bash
if [ "$size" -gt 10000 ]; then
    echo "OK"
fi
```

### Reinício automático em caso de crash (`start.sh`)
Se o servidor travar, ele reinicia automaticamente após 10 segundos — tanto pelo script quanto pelo systemd (`Restart=on-failure`).

---

## 🔌 Como Conectar ao Servidor

### Configurar o Playit.gg (túnel de rede)
Após rodar o `install.sh`, configure o túnel:
```bash
# O agente do Playit.gg inicia junto com o servidor
# Acesse https://playit.gg e faça login
# Seu endereço será gerado automaticamente (ex: xxxx.gl.joinmc.link)
```

### Conectar no servidor

**Java (PC):**
```
Endereço: SEU_ENDERECO:25565
```

**Bedrock (celular/console):**
```
Endereço: SEU_ENDERECO
Porta: 19132
```

Jogadores Java precisam se registrar com `/register <senha> <senha>` na primeira vez.
Jogadores Bedrock entram automaticamente via Floodgate (sem senha).

### Virar admin após instalar
```bash
# Pare o serviço e inicie manualmente para acessar o console
sudo systemctl stop minecraft
cd /home/minecraft/minecraft-server
sudo -u minecraft bash start.sh

# No console do servidor, digite:
op SEU_NICK

# Depois no jogo:
/lp user SEU_NICK parent set dono
```

---

## 📁 Arquivos não incluídos no repositório

Por segurança e tamanho, os seguintes arquivos **não estão no repositório**:
- Arquivos `.jar` (PaperMC e plugins) — baixados automaticamente pelo `setup-server.sh`
- `authme-config.yml` — contém configurações sensíveis
- `floodgate-config.yml` — contém chave de criptografia
- `infos.txt` — contém endereço do servidor

---

## 📚 O que aprendi com este projeto

- Administração de servidores Linux (Ubuntu Server)
- Criação e gerenciamento de serviços com **systemd**
- Shell scripting avançado (funções, tratamento de erros, cores no terminal)
- Consumo de APIs REST via `curl` + `jq` em Shell
- Otimização de JVM para aplicações Java de longa duração
- Redes: como funciona um túnel de rede (Playit.gg) e a diferença entre os protocolos Java e Bedrock do Minecraft
- Uso prático de **IA generativa (Amazon Q)** no desenvolvimento

---

## 👤 Autor

Desenvolvido por **Davi** — com Amazon Q Developer 🤖

[![LinkedIn](https://img.shields.io/badge/LinkedIn-blue?style=flat&logo=linkedin)](https://linkedin.com/in/davi-vieira-sousa-740706343)
[![GitHub](https://img.shields.io/badge/GitHub-black?style=flat&logo=github)](https://github.com/Davi-vieira)
