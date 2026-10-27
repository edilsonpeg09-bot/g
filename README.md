# Roxo Shop v0.6 — pacote unificado para Samsung (preparação)

**NÃO É APK ASSINADO, NEM VERSÃO COM MONETIZAÇÃO ATIVA.** É o código-fonte Flutter para gerar APK de teste no Codemagic. Nenhum arquivo de chave de assinatura está incluído.

## Incluído
- Loja oficial do Fortnite e FortniteDB na WebView, com botão de atualizar e alternativa para navegador.
- Abas Minha Conta / Ajustes, tema preto e roxo, dragão, YouTube.
- Banners e anúncios intersticiais de teste do AdMob.
- IDs comerciais de aplicativo e banner mantidos separados no código, **mas desativados** por padrão.
- Intersticial comercial **não foi cadastrado**: campo vazio, não substitua por identificador imaginado.
- Total de V-Bucks gastos e notificação diária real **não disponíveis**.

## Para testar
Envie conteúdo extraído deste ZIP à raiz do GitHub, substituindo arquivos correspondentes. No Codemagic, execute workflow `Roxo Shop - Android APK de teste`, obtendo `app-debug.apk`. **Não submeta esse APK de depuração à Samsung.**

## O que falta para publicar na Galaxy Store
1. Confirmar direito de uso comercial do conteúdo da Epic e permissão para apresentar FortniteDB em app monetizado. A política padrão da Epic para fan content exige uso **não comercial** (https://legal.epicgames.com/epicgames/fan-art-policy).
2. Concluir Seller Portal e, se necessário, Commercial Seller status e verificações adicionais exigidas pela Samsung.
3. Testar WebView em aparelhos Samsung reais; alguns sites podem recusar exibição.
4. Criar chave de assinatura Android segura; configurar `signingConfigs.release` e fazer `flutter build apk --release` com assinatura de distribuição (ou AAB com a opção de assinatura correspondente da loja).
5. Criar política de privacidade e página de suporte, revisar declarações de dados/consentimento, verificar app-ads.txt e aprovação AdMob.
6. **Somente após as autorizações e aprovações**, configurar produção em uma compilação controlada. A ativação exige **AMBOS**: variável ambiente `ENABLE_LIVE_ADS=true` no script de Manifest E `--dart-define=ENABLE_LIVE_ADS=true` no Flutter. Não habilitar antes disso. Nunca trafegue anúncios reais enquanto testa manualmente.
7. O formato intersticial comercial exige um ID AdMob adicional e avaliação do posicionamento. Atualmente permanece desativado em produção.

## Observações
- A distribuição pela Samsung não garante geração de receita.
- Este pacote foi revisado estaticamente, sem Flutter SDK/Android SDK local para compilar ou validar.
- AdMob e as políticas dos sites/da Epic podem impor restrições independentes da aprovação da Samsung.
