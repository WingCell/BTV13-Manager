# Revisão da proposta recebida em 25/10/2026

## Canais

Os dez URLs propostos usam apenas dois hosts. `Resolve-DnsName` retornou `DNS_ERROR_RCODE_NAME_ERROR` para **ambos**: `play.plus.mz.globo.com` e `cdn.jmvstream.com.br`. Assim, nenhum dos dez passou pelo primeiro requisito de conexão neste computador. Não há evidência de que o primeiro seja um endpoint oficial da Globo nem de que o segundo esteja autorizado a retransmitir Discovery ou Premiere. A lista validada `config/btv13_custom.m3u` e o fornecedor ativo de 29 canais no BTV não foram alterados.

Um `HEAD 200` isolado não comprova um canal assistível: é preciso resolver DNS, obter um manifesto HLS com `GET`, conferir segmentos e testar imagem e áudio no aparelho. Também não comprova autorização para redistribuir o sinal.

## Add-ons Stremio no OpenTV

`https://v3-cinemeta.strem.io/manifest.json` retornou manifesto com recursos de catálogo e metadados. `https://torrentio.strem.fun/manifest.json` retornou manifesto com recurso de stream, **sem catálogo**. O endereço com `?sort=seeders_desc&limit=50` não foi confirmado como configuração aceita pelo serviço; não deve ser apresentado como otimização validada. Os menus “Perfil Atual”, “País” e “Prefer Dubbed” também não foram confirmados na versão do OpenTV instalada. Cinemeta já havia sido testado no aparelho sem preencher a seção Filmes. Nenhum add-on foi instalado nesta revisão.

## Jogos e automação

O repositório `retro-games/snes`, indicado para o download, respondeu **404** na API do GitHub. “No-Intro” descreve a identificação de uma ROM; não concede licença de distribuição. O script Python não verifica hashes, aceita pacote parcial após falhas e usa `:` no nome de arquivo de Zelda, caractere inválido no Windows. Portanto, não foi executado e nenhum jogo comercial foi baixado.

O Bash proposto usa porta ADB fixa `5555`, embora a depuração Wi-Fi deste BTV use porta variável; procura a palavra `device` até no cabeçalho de `adb devices`; contém caminhos fictícios; assume `unzip`; remove o ZIP; e presume o nome da atividade Android. O script seguro já entregue em `scripts/setup_btv13.sh` seleciona o dispositivo pelo serial, valida a lista, faz backup e confere a cópia. Ele mantém o fornecedor ativo.

**Estado após a revisão:** Projectivy, OpenTV com 29 canais e Snes9x com três jogos homebrew permanecem como estavam. A lista curta de dez canais, validada anteriormente, segue disponível para replicação.
