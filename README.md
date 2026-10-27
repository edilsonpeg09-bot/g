# Roxo Shop — v0.5 (FortniteDB na aba Salve o Mundo)

Nesta versão a aba Salve o Mundo abre **https://fortnitedb.com/** na WebView interna, em vez do link anterior de filtro de missões. A página inicial também contém outros recursos do FortniteDB além das missões de V-Bucks.

**Importante:** integração por WebView não é uma API nativa nem garante que o site autorize o carregamento no app. O site depende de conexão de internet e pode alterar sua interface. Esta versão não envia notificações inteligentes sobre novas missões; anúncios continuam apenas em modo de teste. O código não foi compilado nem testado em Android nesta sessão.

## Atualizar pelo Codemagic

Extraia o ZIP e carregue os arquivos extraídos na raiz do repositório GitHub (substitua arquivos com o mesmo nome). Depois confirme o commit na `main` e inicie o workflow Android existente no Codemagic.

## Original

# Roxo Shop v0.4 — Loja e Salve o Mundo dentro do app

Este pacote mantém a identidade preto/roxo, anúncios **somente de teste**, Minha Conta e Ajustes. A aba **Loja** agora carrega a página oficial `https://www.fortnite.com/item-shop` dentro de uma WebView. A aba **V-Bucks** carrega a página filtrada do FortniteDB em outra WebView. Não há mais redirecionamento automático para o navegador nessas abas.

As páginas exibidas continuam pertencendo a seus respectivos provedores. **Não é uma integração de API** e não foi possível garantir que ambos os sites permitam o carregamento dentro de WebView: poderão bloquear, exigir cookies, ou exibir um layout próprio. Em caso de erro, o usuário tem botões para recarregar ou abrir no navegador. Consulte os termos e obtenha permissões para distribuição/monetização de conteúdo de terceiros.

## Gerar APK no Codemagic

1. Extraia este ZIP e envie todos os arquivos à raiz do repositório GitHub `g`, substituindo os anteriores. Envie as pastas `assets` e `lib` com seu conteúdo.
2. Faça commit na branch `main`.
3. Codemagic > projeto `g` > Start new build > workflow `Roxo Shop - Android APK de teste`.
4. Ao concluir, baixe `app-debug.apk` em Artifacts.

O workflow executa: `flutter create --platforms=android --org com.roxoshop .`, `python3 preparar_android.py`, `flutter pub get`, geração do ícone e `flutter build apk --debug`. O script configura permissão `INTERNET` no AndroidManifest e AdMob em modo de teste.

## Limitações restantes

- Sem notificações reais automáticas às 21h.
- Sem consulta autorizada e verificada do total de V-Bucks gastos.
- Nenhuma monetização real: AdMob usa unidades de teste.
- A compilação e a renderização de sites **não foram validadas em dispositivo neste ambiente**.
- Android WebView deve estar atualizado no aparelho.
- Não implantar ou ativar anúncios comerciais com conteúdos do Fortnite/FortniteDB sem licença ou autorização e aprovação do AdMob.
