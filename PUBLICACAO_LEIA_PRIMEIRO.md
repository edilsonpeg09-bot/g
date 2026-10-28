# Roxo Shop v0.8 — preparação de publicação

Este pacote **não é um APK final nem comprova autorização para monetizar**.

## O que já foi testado pelo desenvolvedor
- App abre no Android; banner e intersticial foram vistos no aparelho.
- Fluxo de teste utiliza Unity LevelPlay.

## O que ainda precisa ser concluído antes de liberar produção
1. Implementar e testar coleta/gerenciamento de consentimento adequado (CMP quando exigida), política de privacidade e opções de recusa/alteração de preferências; verificar requisitos de menores/idade e COPPA.
2. Validar regras de monetização, permissão para usar sites de terceiros e marcas Fortnite/Epic, e rede Unity Ads em produção; desativar dispositivos/modos de teste adequadamente.
3. Criar keystore permanente, guardá-lo com backup seguro e cadastrar no Codemagic em **Code signing identities > Android keystores**, com referência `roxo_shop_release`. Não enviar o keystore ou senhas para GitHub.
4. Verificar se o identificador do aplicativo e a assinatura são compatíveis com futuras atualizações. **O workflow atual usa `flutter create` em cada build e exige uma verificação de `applicationId` e `versionCode` antes de publicar.**
5. No Codemagic, após comprovar as etapas 1–4, definir a variável `RELEASE_COMPLIANCE_APPROVED=yes` (a variável é apenas uma trava manual; não concede conformidade automaticamente).
6. Executar workflow `roxo-shop-v08-release-assinada` e instalar/testar o APK release. Não distribuir a versão debug.

## Segurança
A App Key/IDs de anúncios não são senhas; API keys, secret keys, dados bancários e keystore devem ficar fora do repositório.

## Observação
Os anúncios no app são habilitados por `ENABLE_LEVELPLAY_ADS=true`. O código original **ainda não implementa CMP**. Por isso, o build de publicação é bloqueado por padrão e não deve ser liberado prematuramente.
