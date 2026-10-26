# Lista ampliada para o BTV 13 — 25/10/2026

## Resultado instalado

- O fornecedor **TV AO VIVO** conserva seus **31 canais**. Seu arquivo está em `config/canais-da-vo.m3u`; uma cópia anterior a esta operação foi salva em `backups/canais-da-vo-antes-grand-2026-10-25.m3u` (SHA-256 `ff2031d1c154b014de1002ce374d1ffc0dec211c7673211e0b866dc8925041b1`).
- O fornecedor separado **MAIS CANAIS** foi cadastrado no OpenTV 0.11.7 com `config/btv13_extras.m3u`: **60 canais novos**. O guia oferece **Fonte > TV AO VIVO**, **MAIS CANAIS** e **Todas as fontes**. **Limitação confirmada:** após fechar e abrir o OpenTV, o filtro volta a **Todas as fontes**; portanto, a grade de 91 aparece ao iniciar enquanto a segunda fonte estiver instalada. O usuário escolheu manter os 91 canais disponíveis no aplicativo.
- `config/btv13_grand.m3u` contém os **91 canais combinados** e serve para reproduzir a configuração em outro aparelho. Não foi importado como segundo fornecedor no BTV atual, pois duplicaria os 31 da lista principal.
- Cópias dos dois novos arquivos foram guardadas no BTV em `/sdcard/Download/BTV13-Backup/`, com hashes SHA-256 conferidos: lista combinada `1029c70e16dc19d8257afc5fc6a957fb8826d472acd9e11274bca2c6ae6671a5` e extras `d9dd88b9f9a1163f0f3463642af6230e3fe9dc0b237c9713230b1add38faf42b`. O OpenTV usa os URLs públicos; esses arquivos locais servem como cópia de recuperação.
- Dois candidatos novos foram descartados por HTTP 404: BabyFirst Brazil e Pluto TV Karaoke por Stingray.

## Origem e validação

A lista brasileira do [iptv-org](https://iptv-org.github.io/iptv/countries/br.m3u) continha 398 entradas nesta captura. O script `scripts/filtrar_m3u.py` preserva as 31 entradas existentes e seleciona apenas novos IDs da Pluto TV via `https://jmp2.uk/plu-...`, removendo nomes de conteúdo adulto ou inadequado para esta seleção. `scripts/validar_urls_grand.ps1` faz GET com User-Agent, exige HTTP 200, MIME HLS e corpo `#EXTM3U`, e aceita o redirecionador apenas quando o destino é `*.pluto.tv`. Resultado completo: `reports/btv13-grand-validacao.json` — **91/93** candidatos passaram, incluindo os 31 antigos.

O URL curto da Pluto permanece na lista; o redirecionamento pode gerar um endereço de sessão temporário a cada abertura. Isso evita gravar um token expirável no M3U, mas ainda depende do redirecionador e da disponibilidade da Pluto. HTTP 200 no manifesto **não garante** reprodução audiovisual contínua no BTV, nem licença para canais pagos de outras origens. Os canais novos aparecem no guia; a confirmação de imagem e som deles ainda deve ser feita na TV conforme os preferidos da família.

## Por que não há 500 canais nem os sinais pagos pedidos

O limite de 500 é um teto, não prova de que 500 fontes úteis estejam disponíveis. A própria lista de Brasil tinha 398 entradas. Parte delas usa IPs sem identificação do transmissor, endereços HTTP, bloqueio geográfico, tokens expirantes ou retransmissões de canais de assinatura sem autorização comprovada. A lista continha nomes como Globo, GloboNews, ESPN e SporTV, mas os respectivos endereços não passaram pela exigência conjunta de origem autorizada, estabilidade e compatibilidade. Discovery Channel e Premiere também não foram obtidos como sinais gratuitos e autorizados. Não foram anunciados como canais entregues.

Um 200 no manifesto não comprova a origem do sinal, a decodificação no BTV ou imagem e áudio durante um jogo. O caminho confiável para Discovery, ESPN, SporTV e Premiere continua sendo um serviço licenciado que conceda acesso ao aparelho; se exigir aplicativo próprio ou DRM, não se deve prometer uso dentro do OpenTV.

## Reproduzir em outro BTV

1. Instalar OpenTV compatível e importar `config/btv13_grand.m3u` **por URL HTTP(S)**. A versão 0.11.7 instalada apresenta **URL da lista M3U** e pede “a ligação http completa”; não foi encontrado seletor de arquivo local nem o menu “Gerenciador de Listas” citado no roteiro externo.
2. Para reproduzir exatamente esta organização, adicionar dois fornecedores: `config/canais-da-vo.m3u` como **TV AO VIVO** e `config/btv13_extras.m3u` como **MAIS CANAIS**. Os URLs públicos estão no repositório `WingCell/BTV13-Manager` em `raw.githubusercontent.com`.
3. No guia, escolher **Fonte > TV AO VIVO** para a avó; trocar para **MAIS CANAIS** quando quiser os extras. O OpenTV 0.11.7 não persiste essa escolha ao reiniciar o aplicativo: a grade volta a **Todas as fontes**. Testar na televisão alguns favoritos por imagem, som e estabilidade, sem presumir que todos os 91 foram testados visualmente.

## Reverter a ampliação

No OpenTV, ir a **Definições > Fornecedores > MAIS CANAIS > Remover** e confirmar. Isso remove apenas a fonte extra e seus canais; o fornecedor **TV AO VIVO** permanece. O arquivo original de 31 canais também está preservado no backup acima. Remover um fornecedor pode apagar favoritos e estado associados àquela fonte; não remover **TV AO VIVO** para reverter esta etapa.

