# BTV 13 simples: TV ao vivo e vídeos em uma tela

Este guia configura uma TV Box Android para uma pessoa idosa: poucos ícones, canais gratuitos em um guia no OpenTV, VLC como reserva e vídeos em um cliente para controle remoto. Foi testado em um BTV 13 com Android 11 e processador ARM de 32 bits. Outros aparelhos podem ter menus, pacotes e portas ADB diferentes.

**O que este projeto inclui:** uma lista M3U com 25 canais públicos e temáticos gratuitos selecionados, incluindo novelas, filmes, esporte e documentários. Ela não contém Discovery Channel, Premiere nem promete jogos específicos. URLs de TV podem mudar; o teste automático confirma apenas se a playlist HLS responde naquele momento. Faça a conferência de imagem e som na sua TV depois de instalar.

## 1. Preparar o computador

1. Baixe o [Android SDK Platform-Tools oficial](https://developer.android.com/tools/releases/platform-tools) para seu sistema e extraia o ZIP.
2. Abra um terminal dentro da pasta `platform-tools` e confirme:

```text
adb version
adb devices -l
```

No PowerShell, use `.\adb.exe` no lugar de `adb` se a pasta não estiver no PATH.

## 2. Conectar o BTV

No BTV, abra **Configurações > Opções do desenvolvedor** e habilite a depuração oferecida pelo firmware. Se houver **Depuração por Wi-Fi > Parear dispositivo com código**, mantenha a tela de pareamento aberta. Anote o endereço `IP:PORTA_DE_PAREAMENTO` e o código exibido na TV:

```text
adb pair IP:PORTA_DE_PAREAMENTO
```

Depois, leia na TV a **porta de conexão** (pode ser diferente da porta de pareamento):

```text
adb connect IP:PORTA_DE_CONEXAO
adb devices -l
```

Se não existir depuração por Wi-Fi, tente USB com um cabo e porta que aceitem modo dispositivo. Nem toda porta USB-A de TV Box aceita ADB; não una duas portas USB-A de computadores com um cabo comum. Autorize na TV somente a chave ADB do seu computador.

**Segurança:** use ADB apenas na rede local; não abra essa porta no roteador. Desligue a depuração por Wi-Fi quando terminar a manutenção.

## 3. Registrar o estado antes de mudanças

```text
adb shell getprop ro.build.version.release
adb shell getprop ro.product.cpu.abilist
adb shell pm list packages
adb shell df -h /data
adb shell cmd package resolve-activity --brief -a android.intent.action.MAIN -c android.intent.category.HOME
```

Guarde o nome da atividade HOME original para poder voltar depois. Não publique a saída completa de `getprop`, logs ou identificadores do seu aparelho.

## 4. Instalar somente os aplicativos necessários

- **VLC:** player gratuito da [VideoLAN](https://www.videolan.org/vlc/download-android.html), disponível na Play Store ou nos [APKs oficiais](https://download.videolan.org/pub/videolan/vlc-android/last/). Escolha a arquitetura indicada por `ro.product.cpu.abilist`.
- **Projectivy Launcher:** tela inicial simples. Tente primeiro a [Play Store](https://play.google.com/store/apps/details?id=com.spocky.projengmenu). Se a loja considerar o aparelho incompatível, consulte o [release oficial do desenvolvedor](https://github.com/spocky/miproja1/releases) e confira versão e hash publicados antes de instalar.
- **SmartTube:** cliente de vídeos de código aberto criado para Android TV e controle remoto. O [desenvolvedor](https://github.com/yuliskov/SmartTube) recomenda baixar pelos seus canais e informa que não publica oficialmente em lojas. Neste BTV foi usado o [build independente do F-Droid](https://f-droid.org/en/packages/app.smarttube.fdroid/), compilado do código-fonte e assinado pelo F-Droid; ele **não é o APK assinado pelo desenvolvedor**. O projeto relatou comprometimento de alguns builds antigos: evite sites agregadores, confira a origem e mantenha o Play Protect ativo. O [YouTube pode bloquear clientes que retiram anúncios](https://support.google.com/youtube/answer/12318250?hl=pt-BR); mantenha o app oficial como alternativa.

Se instalar APKs manualmente, confira antes nome, versão, arquitetura, permissões e origem. Em um BTV ARM32, use APK compatível com `armeabi-v7a`. Exemplo:

```text
adb install caminho/do/aplicativo.apk
```

Não conceda acesso ao microfone ao SmartTube se não for usar busca por voz. É possível verificar:

```text
adb shell dumpsys package app.smarttube.fdroid
adb shell pm revoke app.smarttube.fdroid android.permission.RECORD_AUDIO
```

## 5. Colocar os canais em um único lugar

Use o arquivo `config/canais-da-vo.m3u` deste projeto. Ele coloca os canais abertos e de notícias primeiro, seguidos de novelas, esportes, filmes e documentários gratuitos. Para copiar:

```text
adb push config/canais-da-vo.m3u "/sdcard/Download/TV AO VIVO.m3u"
adb shell am broadcast -a android.intent.action.MEDIA_SCANNER_SCAN_FILE -d "file:///sdcard/Download/TV%20AO%20VIVO.m3u"
```

No BTV, abra **VLC > Listas de Reprodução > TV AO VIVO.m3u**. Use setas, **OK** e **Voltar**. Se a lista não aparecer, abra a pasta **memória interna > Download** no VLC e selecione o arquivo. Os canais abertos e de notícias vêm primeiro; novelas, filmes e documentários estão logo depois. A opção **Adicionar um novo servidor** do VLC serve para arquivos em rede (por exemplo, FTP), não para importar canais IPTV.

O script `scripts/check-playlist.ps1` testa os URLs em lote no computador. Ele confere HTTP, formato HLS e se os atalhos da Pluto TV chegam ao domínio `pluto.tv`; gera `reports/playlist-check.json`. No PowerShell:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-playlist.ps1
```

Esse teste não garante imagem ou áudio no BTV. Faça o teste visual quando for conveniente e anote somente os canais que falharem. As URLs da Pluto passam por um redirecionador público de terceiros, que pode parar de funcionar; o aplicativo oficial da Pluto é uma alternativa se for compatível com sua TV.

### Opção de guia de canais: OpenTV

O [OpenTV](https://github.com/opentvproject/opentv) é um player gratuito de código aberto com categorias, favoritos e navegação pelo controle. Ele **não inclui canais próprios**. No BTV 13 testado, a versão 0.11.7 importou os 25 canais desta lista e os organizou por categoria. O usuário confirmou que o guia aparece e que SBT Interior tem imagem e áudio no player interno. O VLC permanece como alternativa.

No Windows, com um único BTV autorizado no ADB, execute na raiz deste projeto:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\instalar-opentv.ps1 -Instalar
```

O script baixa o [APK do release oficial](https://github.com/opentvproject/opentv/releases/tag/v0.11.7), confere o SHA-256 publicado no GitHub e pede confirmação antes de instalar. Depois, no OpenTV, escolha **Escrever na TV em vez disso > URL da lista M3U** e informe:

```text
Nome: TV AO VIVO
URL: https://raw.githubusercontent.com/WingCell/BTV13-Manager/main/config/canais-da-vo.m3u
```

Selecione **Guardar e carregar**. A lista pública é buscada diretamente pelo BTV; o computador não precisa ficar ligado. O guia de programação pode aparecer vazio porque esta lista não traz EPG. Verifique imagem e áudio no seu aparelho. Não informe credenciais de serviços a páginas ou APKs que você não reconheça.

**Ao procurar outras listas:** estar no GitHub não comprova autorização dos sinais. Em 24/10/2026, a branch padrão de [Ramys/Iptv-Brasil-2026](https://github.com/Ramys/Iptv-Brasil-2026) não tinha o arquivo `CanaisBR06`; outra lista do projeto incluía canais pagos e conteúdo adulto. [IPTV-Brazuka](https://github.com/xKzin/IPTV-Brazuka) reunia canais pagos em endereços de terceiros com credenciais expostas. Não importe essas listas inteiras para uma TV usada por crianças ou idosos, nem instale APKs de players oferecidos por sites de arquivos. O [EPG brazil1.xml](https://github.com/globetvapp/epg/blob/main/Brazil/brazil1.xml) citado em fóruns ainda continha programação de dezembro de 2025 na consulta de outubro de 2026. Confira sempre a data da grade antes de adicioná-la.

## 6. Simplificar a tela inicial

Abra o Projectivy e deixe **OpenTV em primeiro, VLC em segundo e SmartTube em terceiro**. Oculte atalhos que confundem a pessoa que usa a TV; ocultar na categoria do Projectivy não desinstala nem desativa aplicativos. Configure o Projectivy como aplicativo de Início nas configurações do Android ou no aviso do próprio launcher. Teste a tecla **Início** e a navegação com as setas do controle. No BTV testado, **Início > OK** abre o OpenTV; o VLC está um cartão à direita.

Para ícones maiores e um fundo simples, abra **Projectivy > Configurações > Aparência > Cartões > Tamanho dos cartões** e aumente dois passos. Escolha um fundo preto e estático. No BTV testado, esses ajustes já foram feitos; para voltar ao tamanho anterior, reduza dois passos no mesmo menu.

Não remova o launcher original, serviços de controle remoto nem apps do sistema. Anote antes a atividade HOME original. Para voltar, selecione o launcher original nas configurações de apps padrão ou use, com o nome que você registrou:

```text
adb shell cmd package set-home-activity PACOTE_ORIGINAL/ATIVIDADE_ORIGINAL
```

No BTV 13 testado, o comando de retorno foi `adb shell cmd package set-home-activity com.bb.launcher2/com.uv.droid.launcher.LauncherActivity`. **Confira no seu próprio aparelho antes de usar.**

## 7. Usar com iPhone

Para transferir arquivos sem computador, o [LocalSend](https://localsend.org/) funciona na rede local e tem versões para iPhone e Android. Instale de lojas/fontes oficiais, permita **Rede Local** no iPhone e mantenha ambos no mesmo Wi-Fi. A transferência entre os dois ainda depende de teste em cada aparelho. Controle ADB direto pelo iPhone requer cliente compatível e depuração por rede ativa; por segurança, não deixe esse acesso ligado permanentemente nem exponha a porta à internet.

## Manutenção

- Se um canal parar, verifique a URL com o script e substitua o item no M3U; depois copie o arquivo atualizado para a TV. Não precisa testar toda a lista manualmente com outra pessoa.
- Guarde pelo menos alguns gigabytes livres. Evite dezenas de apps que iniciam junto com a TV.
- Não faça root, restauração de fábrica ou remova pacotes do sistema para tentar acelerar o aparelho.
- Para futebol, consulte as transmissões gratuitas anunciadas pelos detentores de direitos. O canal Esportes da Pluto não equivale ao Premiere.
