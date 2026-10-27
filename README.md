# Roxo Shop v0.7 — Sem AdMob de teste

Fonte Flutter atualizada: o SDK `google_mobile_ads`, os IDs e a lógica de banners/intersticiais foram removidos. Não há anúncios comerciais ou de teste nesta versão. A integração Unity LevelPlay **ainda não foi adicionada**; para ela, precisamos da App Key, das unidades criadas e da validação de elegibilidade/comercialização.

Mantidos: Loja e FortniteDB via WebView, Minha Conta, YouTube e tema preto e roxo.

## Gerar APK para testes no Codemagic

Extraia o ZIP, envie os arquivos para a raiz do GitHub e confirme o commit. Rode o workflow de teste existente. O resultado esperado é `app-debug.apk` na área Artifacts, se o build passar.

**Importante:** ainda não é um APK de produção assinado. A inclusão dos identificadores Unity não é suficiente sem SDK, rede de demanda habilitada, consentimento adequado e aprovação. Verifique direitos comerciais para Fortnite/FortniteDB antes de monetizar.
