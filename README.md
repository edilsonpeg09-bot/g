# Roxo Shop v0.8 — integração Unity LevelPlay (código-fonte para teste)

Este projeto mantém as telas Loja, Salve o Mundo (FortniteDB), Minha Conta e Ajustes. O antigo AdMob não foi reincorporado.

## O que mudou
- Plugin oficial Flutter `unity_levelplay_mediation ^9.4.0`.
- IDs do LevelPlay (App Key, Banner e Intersticial) configurados.
- Adaptador Unity Ads 5.15.0 e dependências Google Play Services de identificação (não é AdMob).
- Banner fixo, fora da WebView, e intersticial em transições naturais (máximo uma vez a cada cinco minutos e quatro mudanças de aba).
- `ENABLE_LEVELPLAY_ADS` desativado por padrão; workflow de **teste** o ativa.

## Importante antes dos testes
1. Adicione o celular em LevelPlay > Dispositivos de teste e use o modo de testes para evitar impressões inválidas.
2. Confirme o cumprimento de COPPA, LGPD, GDPR/EEA e consentimento de anúncios aplicável antes de qualquer distribuição ampla. Este protótipo **não implementa uma CMP**.
3. Tenha autorização para monetização do conteúdo Fortnite e de terceiros. O acesso via WebView pode ter restrições de terceiros.
4. Compile no Codemagic com o workflow `roxo-shop-unity-v08-teste`. O APK gerado é **debug**, não é APK assinado para publicação.
5. A versão do plugin requer Kotlin 2.0+; `preparar_android.py` ajusta o Kotlin em projetos gerados com `settings.gradle.kts`.
6. Se o build falhar ou as classes de Flutter plugin mudarem, conferir a saída do Codemagic e ajustar antes de distribuir. Não houve compilação validada neste ambiente.

## Compilar sem habilitar anúncios
`flutter build apk --debug` (a flag assume `false`).

## Compilar no ambiente de teste
`flutter build apk --debug --dart-define=ENABLE_LEVELPLAY_ADS=true`

## Publicação
O projeto original não traz keystore de produção nem Android configurado. Antes de publicar, integrar consentimento/privacidade, criar assinatura de release, validar conteúdo e testar APK em aparelho. Não suba senhas, keystores ou credenciais privadas ao GitHub.
