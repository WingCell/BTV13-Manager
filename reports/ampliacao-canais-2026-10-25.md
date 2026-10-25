# Ampliação dos canais — 25/10/2026

Objetivo: acrescentar canais gratuitos úteis ao fornecedor único `TV AO VIVO` do OpenTV, preservando os 29 canais anteriores e sem conteúdo adulto.

## Fontes selecionadas

| Canal | Evidência de origem | URL HLS | Resultado |
| --- | --- | --- | --- |
| RedeTV! Mais (afiliada de Umuarama/PR) | O [site da emissora](https://portalredetvmais.com.br/ao-vivo/) incorpora um [player JMV](https://player.jmvstream.com/avj/qTr6LshWvckU3RnoBsXK8HzmQx4TrJ) que contém exatamente o endereço HLS abaixo. É **RedeTV! Mais**, não o sinal principal de São Paulo. | `https://cdn.live.br1.jmvstream.com/webtv/AVJ-15235/playlist/playlist.m3u8` | GET 200, HLS H.264/AAC 720p, lista de segmentos 200 e primeiro trecho `.ts` 200 com dados. |
| TV Câmara | O endereço pertence ao domínio oficial `camara.gov.br`; a [TV Câmara](https://www.camara.leg.br/tv) transmite publicamente. Este canal já estava em uma lista anterior e havia sido retirado quando seu DNS falhou. | `https://stream3.camara.gov.br/tv1/manifest.m3u8` | GET 200, HLS H.264/AAC 1080p; listas de áudio/vídeo 200 e primeiros trechos `.mp4` 200 com dados. |

O teste `scripts/check-playlist.ps1` passou em **31/31** manifestos. Resultado: `reports/playlist-check.json`. SHA-256 da lista com 31 canais: `ff2031d1c154b014de1002ce374d1ffc0dec211c7673211e0b866dc8925041b1`. A mesma lista foi copiada ao BTV e seu hash foi conferido. No OpenTV 0.11.7, usei o ícone **Atualizar** no canto superior direito do guia (não há esse botão na tela Fornecedores); depois, `RedeTV Mais` e `TV Câmara` apareceram na categoria **TV aberta** do fornecedor existente `TV AO VIVO`. Os testes de rede e a presença no guia não provam por si só imagem e som na televisão. A confirmação audiovisual dos dois canais ainda é pendente.

## Fontes rejeitadas nesta rodada

- A IA consultada na conversa indicada pelo usuário repetiu `globo.globo.com` e inventou `record.globo.com` e `redetv.globo.com`; as duas primeiras consultas não retornaram endereço IP. Mesmo depois de uma correção direta, ela propôs outro subdomínio da Globo para a RedeTV!. Nenhum foi usado.
- A [página oficial da RedeTV!](https://www.redetv.uol.com.br/aovivo/) contém um manifesto CloudFront e dois endereços UOL, mas os respectivos subdomínios não resolveram nos testes. Não os coloquei na lista.
- Um endereço de CNN Brasil via CloudFront respondeu HLS, mas não encontrei vínculo entre **aquele endereço exato** e o [player oficial da CNN](https://www.cnnbrasil.com.br/ao-vivo/); também usa variantes HEVC. Não foi adicionado.
- Discovery Channel e Premiere continuam sem fonte aberta autorizada comprovada. A TV Globo é disponibilizada gratuitamente pelo Globoplay onde houver cobertura; não foi encontrado manifesto aberto confiável para o OpenTV. [Ajuda Globo](https://ajuda.globo.com/article/Sobre-os-Produtos-Globo-e-parceiros).

## Backup e reversão

A lista anterior está em `backups/canais-da-vo-antes-redetv-camara-2026-10-25.m3u`, SHA-256 `0f28dda67fcb6cf28ba29a2b269acbd9a580c4f132f6abfb8b713b697111a57a`. Para desfazer a ampliação, restaure esse arquivo em `config/canais-da-vo.m3u`, publique-o no GitHub e toque no ícone **Atualizar** do guia de TV ao vivo do OpenTV. O backup anterior do aparelho também permanece em `backups/BTV13-backup-before-proposal.zip`.

