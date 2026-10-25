# Roxo Shop — APK de teste Android

**Estado:** projeto-fonte Flutter, ainda **não compilado nem validado**. O arquivo APK não está incluído.

Contém: identidade com dragão roxo, banner gráfico da marca, 3 abas, filtros de missões fictícias, banner de anúncios **oficial de teste**. Não conecta dados reais da loja nem alertas e não gera dinheiro.

## Gerar o APK no Windows

1. Instale Flutter SDK e Android Studio com Android SDK; confirme com `flutter doctor`.
2. Extraia este ZIP, abra um terminal **na pasta que contém pubspec.yaml**.
3. Execute estes comandos, um por vez:

```powershell
flutter create --platforms=android --org com.roxoshop .
python preparar_android.py
flutter pub get
dart run flutter_launcher_icons
flutter build apk --debug
```

Se o comando `python` não existir no Windows, use `py preparar_android.py`.

4. Encontre `build/app/outputs/flutter-apk/app-debug.apk`; renomeie uma **cópia** para `RoxoShop-teste.apk` se quiser.
5. Instale arrastando o APK para o BlueStacks, ou conecte o telefone com depuração USB e execute `flutter install`.

## AdMob

O projeto usa **somente** IDs oficiais de TESTE Android do Google, inclusive no Manifest. O ID real do aplicativo (`ca-app-pub-2459248219163601~9796068658`) e do banner (`ca-app-pub-2459248219163601/4839255446`) **não estão ativos**. Nenhuma receita é gerada. Não use anúncios comerciais até verificar aprovação, conformidade legal/política de conteúdo e autorização comercial da Epic. Consulte: https://legal.epicgames.com/epicgames/fan-art-policy

## Publicação

Antes de publicar são necessários: fontes de dados autorizadas e funcionais, permissão/licença de uso comercial para quaisquer recursos do Fortnite, política de privacidade, consentimento sobre anúncios quando aplicável, testes Android, e assinatura release/App Bundle.

A identidade do dragão foi criada para este protótipo. O nome Roxo Shop ainda precisa de verificação de disponibilidade e marcas.

## Gerar APK online no Codemagic

1. Crie um repositório **privado** no GitHub (por exemplo, `roxo-shop`) e envie **todos os arquivos da raiz deste projeto** ao nível principal do repositório; `pubspec.yaml` e `codemagic.yaml` devem aparecer lado a lado na página inicial do repositório.
2. No Codemagic, selecione o repositório e a branch `main`, abra `codemagic.yaml` e clique em **Check for configuration files**.
3. Selecione o workflow **Roxo Shop - Android APK de teste** e inicie o build.
4. Ao finalizar com sucesso, baixe o APK em **Artifacts**. Esse é um APK de testes, sem anúncios comerciais.

O workflow cria a pasta Android automaticamente; não é preciso enviá-la ao GitHub. Se houver erros de versão de Flutter, Gradle ou plugins, será necessário revisar o log da compilação.
