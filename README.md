# Roxo Shop 0.3.0 — TESTE, NÃO PUBLICAR COMO FINAL

## O que contém
- Quatro abas: Loja, Salve o Mundo (link do FortniteDB), Minha Conta (link oficial Epic) e Ajustes.
- Atalho para resultados de busca no YouTube sobre Fortnite e Salve o Mundo (não é um canal oficial nem vídeos incorporados).
- Banner AdMob de TESTE e intersticial AdMob de TESTE. Intersticial somente após no mínimo 3 mudanças de abas, limitado a uma tentativa a cada 10 minutos, se anúncio estiver carregado. O tempo e o botão Fechar são controlados pelo SDK do Google. Sem cronômetro ou fechamento falso.
- Dragão e paleta preto/roxo, ícone e banner.

## O que NÃO contém
- API de loja sincronizada no próprio aplicativo: a Loja abre a página oficial externa.
- Consulta real dos V-Bucks gastos: nenhuma API autorizada foi confirmada; a aba da conta abre páginas oficiais e mostra “não disponível”.
- Aviso automático às 21h: ainda precisa de backend ou integração de notificações. Não informa falsamente que há V-Bucks.
- Anúncios que geram receita: apenas IDs públicos OFICIAIS DE TESTE do Google, inclusive no AndroidManifest. NÃO substitua por IDs reais antes de resolver políticas, autorizações e consentimento.

## Codemagic
1. Extraia o ZIP. Substitua os arquivos existentes na raiz do repositório no GitHub (inclusive `lib/main.dart`, `pubspec.yaml` e `README.md`), faça Commit na branch `main`.
2. Codemagic → projeto `g` → Start new build → `main` → Roxo Shop - Android APK de teste.
3. Quando terminar, baixe `app-debug.apk` em Artifacts e instale no Android.

`codemagic.yaml` cria a plataforma Android automaticamente e executa `preparar_android.py` para inserir o App ID oficial de teste do AdMob no manifest.

## Limitações antes de publicação
Necessários: autorização apropriada para uso/monetização de conteúdo do Fortnite, revisão das políticas AdMob e Google Play, política de privacidade e consentimento, verificação de marca/nome, dados autorizados, testes no dispositivo e assinatura AAB release. Sem autorização comercial da Epic, não ativar monetização.

## Fontes AdMob
https://developers.google.com/admob/flutter/interstitial
https://developers.google.com/admob/flutter/banner
