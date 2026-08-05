# Changelog

Todas as mudanças importantes deste projeto serão documentadas aqui.

---

## [v1.0.0] - 2026-08-05

### Lançamento inicial

- Instalação automatizada em 1 comando via `install.sh`
- Download automático do PaperMC via API oficial (v2)
- Download automático de plugins via GitHub Releases: GeyserMC, Floodgate, AuthMe, Playit.gg
- Suporte simultâneo a jogadores Java (PC) e Bedrock (celular/console)
- Detecção automática de RAM — aloca 60% da RAM total para a JVM
- Aikar's Flags para otimização do G1GC
- Reinício automático em caso de crash (script + systemd)
- Serviço systemd com proteções de segurança (`NoNewPrivileges`, `PrivateTmp`)
- `server.properties` otimizado para hardware limitado
- `.gitignore` protegendo arquivos sensíveis e `.jar`
- Licença MIT
