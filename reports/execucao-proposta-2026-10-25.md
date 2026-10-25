# Execução da proposta recebida — 25/10/2026

## Backup anterior às mudanças

- [Backup local](../backups/BTV13-backup-before-proposal.zip): lista de 29 canais extraída do BTV, lista curta anterior, APKs OpenTV 0.11.7 e Projectivy 4.72, três jogos homebrew originais e instruções de recuperação. SHA-256 do ZIP: `396660eea66aeb6ce0eca9792f93e5ba59bdad9e920c1e29769d20b1f55779e0`.
- Cópia adicional da lista principal no BTV: `/sdcard/Download/BTV13-Backup/canais-da-vo.m3u`. Hash local e remoto: `0f28dda67fcb6cf28ba29a2b269acbd9a580c4f132f6abfb8b713b697111a57a`.
- Dados privados de aplicativos não puderam ser exportados por ADB comum. A lista ativa, as preferências e o launcher não foram substituídos.

## Canais da proposta

O M3U de dez entradas foi montado separadamente em `work/btv13-proposta-10-canais.m3u`. O teste `HEAD` exigido pelo texto proposto terminou com **0/10 HTTP 200**; todos os URLs falharam em DNS. No próprio BTV, `ping` retornou `unknown host` para os dois domínios usados: `play.plus.mz.globo.com` e `cdn.jmvstream.com.br`. Assim, a lista não foi importada nem copiada como fonte ativa. O fornecedor **TV AO VIVO**, com 29 canais, permanece ativo.

O domínio `cdn.live.br1.jmvstream.com` usado por alguns canais existentes é diferente de `cdn.jmvstream.com.br`; o funcionamento de um não valida os caminhos do outro. Mesmo quando há HTTP 200, isso não prova reprodução, licença ou estabilidade.

**Nova hipótese de DNS/User-Agent recebida depois:** consultas diretas a `1.1.1.1` e `8.8.8.8` também retornaram “nome DNS não existe” para ambos os domínios. O BTV já mostrava `net.dns2=8.8.8.8` e `net.dns3=8.8.4.4`. Portanto, não alterei o DNS. Acrescentar `?ua=Mozilla/5.0` ao URL não muda o cabeçalho HTTP `User-Agent` do player e, sobretudo, não resolve um domínio inexistente; a nova lista não foi importada.

**Nova proposta de filtrar iptv-org Brasil:** baixei `https://iptv-org.github.io/iptv/countries/br.m3u` em 25/10/2026 (HTTP 200, 398 entradas) e reproduzi o filtro por nomes sugerido. Ele selecionou **23 entradas**, não dez. Não houve correspondência para os nomes exatos “TV Globo SP”, “Discovery Channel”, “Premiere Clubes” e “Canção Nova”. A lista continha Discovery Kids e Discovery World marcados como geobloqueados, que não são Discovery Channel; não havia qualquer entrada com “Premiere”. “Record” selecionou onze variantes, inclusive Record News e afiliadas. Não importei o resultado. O projeto iptv-org se descreve como coleção de links públicos enviados por usuários, cuja autorização é presumida pelos mantenedores, não verificada individualmente para cada sinal.

**Novo URL `globo.globo.com`:** o endereço `https://globo.globo.com/servlets/playlist.m3u8?channel=TV_GLOBO_SP` falhou em DNS no computador e no BTV. Consultas diretas a `1.1.1.1` e `8.8.8.8` retornaram apenas a indicação negativa da zona `globo.com`, sem IP para o subdomínio. Assim, não houve resposta HLS nem justificativa para adicioná-lo ao OpenTV. A Globo informa que TV Globo ao vivo pode ser acessada gratuitamente pelo Globoplay onde disponível, mediante Conta Globo; essa opção não valida o URL M3U apresentado. Os links de Discovery e Premiere repetiram o domínio `cdn.jmvstream.com.br`, já sem resolução DNS, e não há IP a usar diretamente.

## Stremio no OpenTV 0.11.7

- Verifiquei na interface que a aba **Definições > Add-ons (Stremio)** aceita URLs de manifesto.
- Adicionei Cinemeta. A aba Filmes continuou em “Sem filmes”. Adicionei Torrentio sem parâmetros; o resultado continuou igual. Ambos foram removidos após o teste, deixando a aba de add-ons como estava.
- No computador, o catálogo público do Cinemeta respondeu HTTP 200. O URL `https://torrentio.strem.fun/manifest.json?sort=seeders_desc&limit=50` devolveu exatamente o mesmo manifesto que o URL simples; isso não confirma a otimização afirmada.
- O código do OpenTV mostra que **Filmes** lê o catálogo VOD do fornecedor IPTV. Os add-ons Stremio são consultados para fontes de reprodução de um filme já presente, e a busca de ID depende da configuração de TMDB. O fornecedor M3U atual não fornece catálogo VOD. Alterar idioma ou acrescentar Torrentio não cria filmes nessa aba.
- A aba **Me** do aparelho mostrou apenas perfis; não encontrei as opções “País: Brasil” ou “Prefer Dubbed” descritas na proposta.

## Jogos SNES

- O repositório `retro-games/snes` proposto respondeu 404, então o script que baixa jogos comerciais não foi executado.
- A variante seguinte apontou para `snes9x/snes9x/snes/super-mario-world.sfc`; a API do GitHub também retornou 404 para esse caminho. O repositório do emulador não foi tratado como fonte de jogos licenciados.
- Baixei sete jogos homebrew diretamente do repositório `retrobrews/snes-games`, conferi tamanho e SHA-256 e copiei para `/sdcard/Games/SNES/` sem sobrescrever os três existentes.
- O BTV agora contém **10 arquivos de jogos homebrew**, total aproximado de 9,5 MB. O script [`instalar-homebrew-snes.ps1`](../scripts/instalar-homebrew-snes.ps1) foi executado em modo `-VerifyOnly` e conferiu **10/10 hashes** no aparelho.
- Não foram distribuídas ROMs comerciais. O controle de videogame ainda não foi conectado, então não há teste de jogabilidade com gamepad.

## Estado final desta execução

Projectivy e OpenTV continuam instalados. Deixei o BTV na tela inicial do Projectivy. A lista principal de 29 canais foi novamente extraída e seu hash permaneceu idêntico ao backup; os dez canais propostos não passaram no teste DNS. Os add-ons de teste foram removidos. Snes9x EX+ tem dez jogos homebrew, aguardando teste com gamepad. Não executei o Bash fornecido na proposta porque usa caminhos fictícios, presume porta ADB fixa e pode remover o ZIP antes de verificar a extração.
