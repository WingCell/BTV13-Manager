# BTV 13 — lista curta verificável

O arquivo `config/btv13_custom.m3u` contém **10 canais gratuitos**, sem conteúdo adulto. O teste automático de 25/10/2026 obteve 10/10 respostas HLS. Isso confirma o manifesto naquele momento, não imagem e áudio em toda TV. Record e Band são **afiliadas**; Record News, novelas, esportes e Smithsonian são canais gratuitos da Pluto TV. A lista não inclui TV Globo, Discovery Channel ou Premiere, pois não foi confirmado sinal gratuito e autorizado para eles.

No BTV desta configuração, o OpenTV continua usando o fornecedor **TV AO VIVO** com 29 canais. A lista curta foi copiada para `/sdcard/Download/BTV13_ESSENCIAIS.m3u` e conferida por SHA-256; **não foi importada como segundo fornecedor**, para não duplicar canais na tela da avó. Pode ser usada em outro aparelho, ou como substituta da lista grande se você decidir simplificar.

URL pública da lista curta:

```text
https://raw.githubusercontent.com/WingCell/BTV13-Manager/main/config/btv13_custom.m3u
```

## Copiar pelo computador

Use ADB apenas na rede local e veja a porta atual com `adb devices -l`; a porta de depuração Wi-Fi não é sempre 5555. Na raiz do projeto, execute **um** dos scripts abaixo passando o endereço `IP:PORTA` já autorizado:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\setup_btv13.ps1 -Serial 'IP:PORTA'
```

```bash
bash scripts/setup_btv13.sh IP:PORTA
```

Ambos validam o formato, fazem backup se já existir uma cópia da lista curta, copiam o M3U para `Download` e conferem o tamanho. O PowerShell foi executado neste BTV; o Bash não estava disponível no computador Windows para teste de execução. Nenhum script altera o fornecedor ativo do OpenTV. Se quiser importar esta lista em outro BTV, abra **OpenTV > Definições > Fornecedores > Adicionar fornecedor** e use a URL pública acima. Não mantenha duas listas com os mesmos canais se isso atrapalhar a navegação.

## Add-ons e jogos

A aba **Add-ons (Stremio)** do OpenTV pede URL de manifesto, não arquivo JSON local. `https://v3-cinemeta.strem.io/manifest.json` é manifesto oficial de metadados; `https://torrentio.strem.fun/manifest.json` responde como complemento comunitário de fontes torrent. Nenhum deles fornece os canais ao vivo solicitados. Cinemeta e Public Domain Movies foram testados no OpenTV deste BTV e a seção Filmes continuou vazia; por isso a aba segue sem add-ons. Não foi configurado Torrentio.

O Snes9x EX+ já contém três jogos homebrew gratuitos (Bucket, Rockfall e BLT). Não há pacote de dez jogos comerciais: um arquivo em GitHub, No-Intro ou Archive.org não prova licença de distribuição. O gamepad ainda precisa ser conectado e testado.

## Verificação rápida

1. Abra o OpenTV pelo Projectivy e confirme que o fornecedor principal **TV AO VIVO** continua disponível.
2. Se importar a lista curta em outro aparelho, confira imagem e áudio em um canal de interesse; o teste HTTP não substitui a reprodução real.
3. Conecte o gamepad antes de testar os jogos no Snes9x.
