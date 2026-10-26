# Revisão da proposta Stremio/Globo/Discovery/Premiere — 25/10/2026

## Resultado no BTV

- **Stremio Android TV 1.10.4 ARM 32 bits (`com.stremio.one`) instalado para teste**, com autorização do usuário. Fonte: [download oficial](https://www.stremio.com/downloads), APK `com.stremio.one-1.10.4-31048580-armeabi-v7a.apk`, 91.635.880 bytes, SHA-256 `e18a5405bb53e12a903ff477457318b8f8d3c8e1995e0a4c3ff5d8893d1ccf0b`. ZIP íntegro, 25 bibliotecas nativas `armeabi-v7a`; manifesto: minSdk 24, targetSdk 36. O BTV tem API 30 e ABI `armeabi-v7a`. A instalação e a primeira abertura passaram. O firmware não anuncia `android.software.leanback`, mas isso não impediu o sideload.
- O idioma foi definido como **Português (Brasil)**. A tela inicial apresenta QR Code e exige entrar numa conta Stremio para prosseguir; **catálogo e reprodução ainda não foram testados**. Não foi criada conta nem inserida senha. O app aparece automaticamente na seção **Aplicativos de TV** do Projectivy, após OpenTV. O Projectivy continua como tela inicial e o OpenTV mantém 31 + 60 canais.
- O manifesto do APK solicita: Internet, estado da rede, microfone, notificações, início após ligar, serviço em primeiro plano para reprodução, wake lock, identificador de publicidade e acesso à grade de TV. O Android confirmou `RECORD_AUDIO: granted=false`. A Play Store [declara coleta opcional de e-mail/interações e IDs do dispositivo para análise](https://play.google.com/store/apps/datasafety?id=com.stremio.one). O app permaneceu em segundo plano com cerca de **144 MiB PSS** após voltar ao Projectivy; foi encerrado após o teste para liberar RAM, sem desinstalar.

## O que na proposta procede

O OpenTV 0.11.7 não cria catálogo de filmes a partir dos complementos Stremio. Seu [código sincroniza VOD apenas para fornecedor Xtream](https://github.com/opentvproject/opentv/blob/v0.11.7/app/src/main/java/app/opentv/data/repo/CatalogRepository.kt#L646-L650). As fontes atuais são M3U de TV ao vivo; **Filmes** mostra “Sem filmes”. Add-ons nessa versão só procuram URLs diretas para um filme que já existe no catálogo, após obter IMDb via TMDB. O [cliente não usa `catalog` do manifesto e ignora respostas sem URL direta](https://github.com/opentvproject/opentv/blob/v0.11.7/app/src/main/java/app/opentv/data/remote/StremioClient.kt#L24-L70). Portanto, Stremio oficial separado é uma alternativa tecnicamente mais coerente para avaliar filmes e séries; não os torna automaticamente gratuitos ou disponíveis.

## O que na proposta não foi confirmado ou está errado

- `globo.globo.com` não retornou registro A na consulta DNS; `cdn.jmvstream.com.br` retornou “nome DNS não existe”. Esses endereços já haviam falhado em tentativas anteriores. Não foram adicionados ao OpenTV. Um IP direto hipotético não comprova retransmissão autorizada nem contorna validação de host/TLS.
- O menu “Gerenciador de Listas” não existe na interface observada do OpenTV 0.11.7; o menu real é **Definições > Fornecedores**.
- Cinemeta organiza metadados; Torrentio é complemento comunitário de fontes, e Debrid exige serviço/chave próprios. A proposta de Torrentio para títulos comerciais atuais não demonstrou direitos de transmissão, estabilidade, idioma nem reprodução neste BTV. O Stremio [declara que conteúdo vem dos add-ons](https://addons.stremio.com/); não há garantia de iniciar um filme popular em 10 segundos. Nenhum Torrentio ou Debrid foi configurado no Stremio instalado.
- Os URLs de Globo, Discovery e Premiere alegados como “oficiais” não foram comprovados. Eles permanecem **pendentes** no objetivo original. Não trocar as fontes funcionais por esses URLs.

## Próximos passos

1. Se o usuário decidir usar uma conta Stremio, fazer login pelo QR Code **diretamente no aparelho/iPhone**, sem enviar credenciais no chat. Verificar depois a navegação com controle, o catálogo e uma fonte gratuita/autorizada de teste. Não presumir filmes comerciais gratuitos a partir de metadados.
2. Manter microfone negado; avaliar se o app ou suas opções iniciam serviço após ligar e se o uso de RAM compensa para o BTV. Se não trouxer conteúdo útil/licenciado ou dificultar a navegação da avó, desinstalar apenas `com.stremio.one` com autorização; OpenTV e Projectivy permanecem.
3. Testar imagem e áudio de canais novos escolhidos pela família. Para Globo/Discovery/Premiere, exigir fonte licenciada e reproduzível; a meta original segue incompleta.

