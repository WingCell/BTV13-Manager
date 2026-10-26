# Stremio no BTV 13 — filmes, séries e animes (26/10/2026)

## Estado de partida

- Stremio oficial Android TV 1.10.4 (`com.stremio.one`), ARM 32 bits, já autenticado pelo usuário.
- Complementos preexistentes: Cinemeta, YouTube, WatchHub, Public Domain Movies, OpenSubtitles v3, OpenSubtitles e Local Files.
- OpenTV, Projectivy, VLC e as listas de canais não foram alterados nesta etapa.

## Testes no aparelho

| Item | Resultado observado |
| --- | --- |
| BestCine 13.0.0 | Instalado temporariamente para teste. O catálogo recebeu HTTP 403 no Stremio do BTV; não exibiu filmes. Foi removido da conta após o teste. |
| FenixFlix 1.2.8 | Instalado por URL de manifesto na conta Stremio. Catálogos de filmes e séries carregaram no BTV; a série inclui animes como One Piece e Black Clover. |
| Filme Metrópolis (1927) | Duas fontes FenixFlix legendadas apareceram. O player Exo falhou; ao alternar para o VLC interno, o usuário confirmou imagem e som. |
| Série O Mentalista S01E01 | Quatro fontes dubladas anunciadas na API e três cartões FenixFlix visíveis na TV. O usuário confirmou imagem e áudio, sem anúncio no teste breve. |
| Anime One Piece S01E01 | Doze fontes na API, incluindo cinco rotuladas dubladas e sete legendadas. A TV exibiu fontes dubladas; o usuário confirmou imagem e áudio sem anúncio no teste breve. |

O FenixFlix não exigiu cadastro adicional nem apresentou fonte torrent nos episódios amostrados. Esses testes não verificam todas as temporadas, filmes, anúncios futuros ou estabilidade dos servidores.

Na tela inicial Projectivy, o Stremio aparece como primeiro aplicativo na seção **Aplicativos de TV**. OpenTV continua instalado com as 97 entradas das fontes `TV AO VIVO` e `MAIS CANAIS`.

## Direitos e segurança

O diretório público e o manifesto do FenixFlix não apresentam prova de licença para distribuir os títulos comerciais. O Stremio informa que complementos comunitários são operados por terceiros. O usuário foi informado dessa incerteza e escolheu manter o FenixFlix disponível. Não foi instalado APK do complemento; a conta Stremio armazena o endereço do serviço remoto. Não forneça credenciais pessoais ao complemento ou às páginas de origem dos vídeos.

Manifesto usado: `https://fenixflix.fenixhub.online/manifest.json`. Para remover, abra **Stremio > Add-ons > Instalado > FenixFlix > Desinstalar**. O BestCine de teste já foi removido; os complementos preexistentes permanecem.

Fontes: [descrição do FenixFlix](https://stremio-addons.net/addons/fenixflix), [ajuda oficial sobre complementos comunitários](https://stremio.zendesk.com/hc/en-us/articles/360021348391-How-to-install-uninstall-Add-ons), [protocolo oficial dos links Stremio](https://github.com/Stremio/stremio-addon-sdk/blob/master/docs/deep-links.md).

