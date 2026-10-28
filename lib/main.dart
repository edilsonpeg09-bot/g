import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unity_levelplay_mediation/unity_levelplay_mediation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RoxoShopApp());
}

// Habilitar apenas em testes com dispositivo registrado na Unity e consentimento adequado.
const bool enableLevelPlayAds = bool.fromEnvironment('ENABLE_LEVELPLAY_ADS', defaultValue: false);
const String levelPlayAppKey = '290e20bc5';
const String levelPlayBannerId = 'yahaf9udspaqh4vl';
const String levelPlayInterstitialId = '9w0c1k53wxx84mku';

const bg = Color(0xFF09090F);
const panel = Color(0xFF18141F);
const purple = Color(0xFF7C3AED);
const lilac = Color(0xFFC084FC);
const dim = Color(0xFFB8AEC6);
const fortniteShop = 'https://www.fortnite.com/item-shop';
const fortniteDb = 'https://fortnitedb.com/';
const epicTransactions = 'https://www.epicgames.com/account/transactions';
const epicAccount = 'https://www.epicgames.com/account/personal';
const youtubeSearch = 'https://www.youtube.com/results?search_query=Fortnite+Salve+o+Mundo+miss%C3%B5es+V-Bucks';

class RoxoShopApp extends StatelessWidget {
  const RoxoShopApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Roxo Shop',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: bg,
          colorScheme: ColorScheme.fromSeed(seedColor: purple, brightness: Brightness.dark),
          appBarTheme: const AppBarTheme(backgroundColor: bg, foregroundColor: Colors.white),
          cardTheme: const CardThemeData(color: panel),
        ),
        home: const HomePage(),
      );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    implements LevelPlayInitListener {
  bool _adsReady = false;
  int _navigationChanges = 0;
  DateTime? _lastInterstitial;
  LevelPlayInterstitialAd? _interstitial;
  final GlobalKey<LevelPlayBannerAdViewState> _bannerKey = GlobalKey<LevelPlayBannerAdViewState>();

  @override
  void initState() {
    super.initState();
    if (enableLevelPlayAds) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _initAds());
    }
  }

  Future<void> _initAds() async {
    try {
      final request = LevelPlayInitRequest.builder(levelPlayAppKey).build();
      await LevelPlay.init(initRequest: request, initListener: this);
    } on PlatformException catch (e) {
      debugPrint('LevelPlay init failed: $e');
    }
  }

  @override
  void onInitSuccess(LevelPlayConfiguration configuration) {
    if (!mounted) return;
    _interstitial = LevelPlayInterstitialAd(adUnitId: levelPlayInterstitialId);
    _interstitial!.setListener(_RoxoInterstitialListener(_interstitial!));
    _interstitial!.loadAd();
    setState(() => _adsReady = true);
  }

  @override
  void onInitFailed(LevelPlayInitError error) {
    debugPrint('LevelPlay init error: $error');
  }

  Future<void> _maybeShowInterstitial() async {
    final ad = _interstitial;
    if (!_adsReady || ad == null) return;
    _navigationChanges++;
    if (_navigationChanges % 4 != 0) return;
    final now = DateTime.now();
    if (_lastInterstitial != null && now.difference(_lastInterstitial!).inMinutes < 5) return;
    try {
      final isReady = await ad.isAdReady();
      if (!mounted || !isReady) return;
      _lastInterstitial = DateTime.now();
      await ad.showAd();
    } on PlatformException catch (e) {
      debugPrint('LevelPlay interstitial failed: $e');
    }
  }

  int page = 0;
  void _switchPage(int value) {
    if (value != page) {
      setState(() => page = value);
      _maybeShowInterstitial();
    }
  }

  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    final success = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir a página. Verifique a conexão.')),
      );
    }
  }

  Widget _card({required Widget child}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: panel,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF3A254C)),
        ),
        child: child,
      );

  Widget _action(String text, VoidCallback onTap, {IconData icon = Icons.open_in_new}) =>
      SizedBox(width: double.infinity, child: FilledButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(text, textAlign: TextAlign.center),
        style: FilledButton.styleFrom(backgroundColor: purple,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14)),
      ));

  Widget _heading(String title, String subtitle) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(subtitle, style: const TextStyle(color: dim, height: 1.4)),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final titles = ['Loja', 'Salve o Mundo', 'Minha Conta', 'Ajustes'];
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text('Roxo Shop · ${titles[page]}')),
      body: SafeArea(child: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: IndexedStack(index: page, children: [
          const EmbeddedSitePage(
            title: 'Loja de Itens',
            url: fortniteShop,
            sourceName: 'Fortnite — site oficial',
          ),
          const EmbeddedSitePage(
            title: 'Salve o Mundo — FortniteDB',
            url: fortniteDb,
            sourceName: 'FortniteDB — site de terceiros',
          ),
          _account(), _settings(),
        ]),
      ))),
      bottomNavigationBar: Column(mainAxisSize: MainAxisSize.min, children: [
        if (enableLevelPlayAds && _adsReady)
          SizedBox(height: 50, width: 320, child: LevelPlayBannerAdView(
            key: _bannerKey,
            adUnitId: levelPlayBannerId,
            adSize: LevelPlayAdSize.BANNER,
            listener: _RoxoBannerListener(),
            onPlatformViewCreated: () => _bannerKey.currentState?.loadAd(),
          )),
        SafeArea(top: false, child: NavigationBar(
        height: 74,
        backgroundColor: panel,
        indicatorColor: purple,
        selectedIndex: page,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: _switchPage,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.shopping_bag_outlined), label: 'Loja'),
          NavigationDestination(icon: Icon(Icons.bolt_outlined), label: 'V-Bucks'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Conta'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Ajustes'),
        ],
      )),
      ]),
    );
  }

  Widget _account() => ListView(padding: const EdgeInsets.all(16), children: [
        _heading('Minha Conta', 'Acesse sua conta Epic Games pelo site oficial, com segurança.'),
        const SizedBox(height: 20),
        _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.shield_outlined, color: lilac, size: 32),
          const SizedBox(height: 10),
          const Text('Entrar na Epic Games', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('O login é feito fora do Roxo Shop, na página da Epic. Este aplicativo não coleta sua senha nem recebe tokens de acesso.', style: TextStyle(color: dim, height: 1.4)),
          const SizedBox(height: 16),
          _action('Abrir conta Epic', () => _open(epicAccount)),
        ])),
        const SizedBox(height: 14),
        _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Histórico de transações', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Consulte as transações que a Epic disponibiliza oficialmente. O histórico não equivale ao total de V-Bucks gastos dentro do jogo.', style: TextStyle(color: dim, height: 1.4)),
          const SizedBox(height: 16),
          _action('Consultar transações na Epic', () => _open(epicTransactions)),
        ])),
        const SizedBox(height: 14),
        _card(child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('V-Bucks gastos', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('Não disponível', style: TextStyle(color: lilac, fontSize: 22, fontWeight: FontWeight.w700)),
          SizedBox(height: 6),
          Text('Não foi encontrada uma API oficial autorizada que forneça o total de V-Bucks gastos. Nenhum valor é estimado ou inventado.', style: TextStyle(color: dim, height: 1.4)),
        ])),
      ]);

  Widget _settings() => ListView(padding: const EdgeInsets.all(16), children: [
        _heading('Ajustes', 'Informações do aplicativo.'),
        const SizedBox(height: 12),
        _action('Abrir YouTube: Salve o Mundo', () => _open(youtubeSearch), icon: Icons.play_circle_outline),
        const SizedBox(height: 20),
        _card(child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.palette_outlined, color: lilac), title: Text('Tema'), subtitle: Text('Preto e roxo')),
          ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.ads_click, color: lilac), title: Text('Anúncios'), subtitle: Text(enableLevelPlayAds ? 'Unity LevelPlay habilitado para testes' : 'Anúncios desativados nesta compilação')),
          ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.notifications_none, color: lilac), title: Text('Notificações'), subtitle: Text('Ainda não implementadas — exigem serviço de alertas')),
          ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.info_outline, color: lilac), title: Text('Versão'), subtitle: Text('0.8.0 (Unity LevelPlay)')),
        ])),
      ]);
}


/// Mostra a página original dentro do aplicativo, sem copiar seu conteúdo.
/// Se o provedor bloquear WebView, oferece abertura externa explícita.
class EmbeddedSitePage extends StatefulWidget {
  final String title;
  final String url;
  final String sourceName;
  const EmbeddedSitePage({
    super.key,
    required this.title,
    required this.url,
    required this.sourceName,
  });

  @override
  State<EmbeddedSitePage> createState() => _EmbeddedSitePageState();
}

class _EmbeddedSitePageState extends State<EmbeddedSitePage> {
  late final WebViewController _controller;
  int _progress = 0;
  String? _error;
  bool _canBack = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(bg)
      ..setNavigationDelegate(NavigationDelegate(
        onProgress: (progress) {
          if (mounted) setState(() => _progress = progress);
        },
        onPageStarted: (_) {
          if (mounted) setState(() { _error = null; _progress = 0; });
        },
        onPageFinished: (_) async {
          final back = await _controller.canGoBack();
          if (mounted) setState(() { _progress = 100; _canBack = back; });
        },
        onWebResourceError: (error) {
          if (error.isForMainFrame == true && mounted) {
            setState(() => _error = 'Não foi possível carregar esta página dentro do aplicativo.');
          }
        },
        onNavigationRequest: (request) {
          final uri = Uri.tryParse(request.url);
          if (uri == null) return NavigationDecision.prevent;
          // Evita navegar para esquemas não HTTP e aplicativos externos silenciosamente.
          if (uri.scheme != 'https' && uri.scheme != 'http') {
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(Uri.parse(widget.url));
  }

  Future<void> _external() async {
    final ok = await launchUrl(Uri.parse(widget.url), mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir no navegador.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        color: panel,
        child: Row(children: [
          IconButton(
            tooltip: 'Voltar na página',
            onPressed: _canBack ? () async {
              await _controller.goBack();
              final back = await _controller.canGoBack();
              if (mounted) setState(() => _canBack = back);
            } : null,
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          ),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700)),
            Text(widget.sourceName, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: dim, fontSize: 11)),
          ])),
          IconButton(
            tooltip: 'Atualizar',
            onPressed: () => _controller.reload(),
            icon: const Icon(Icons.refresh, color: lilac),
          ),
          IconButton(
            tooltip: 'Abrir no navegador',
            onPressed: _external,
            icon: const Icon(Icons.open_in_browser, size: 22),
          ),
        ]),
      ),
      if (_progress < 100) LinearProgressIndicator(value: _progress / 100,
        minHeight: 2, color: lilac, backgroundColor: panel),
      Expanded(child: Stack(children: [
        Positioned.fill(child: WebViewWidget(controller: _controller)),
        if (_error != null) Positioned.fill(child: Container(
          color: bg,
          padding: const EdgeInsets.all(24),
          child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.wifi_off, size: 40, color: lilac),
            const SizedBox(height: 12),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(onPressed: () => _controller.reload(),
              icon: const Icon(Icons.refresh), label: const Text('Tentar novamente')),
            TextButton(onPressed: _external,
              child: const Text('Abrir no navegador')),
          ])),
        )),
      ])),
    ],
  );
}

// Listeners separados: API do banner e do intersticial usam assinaturas diferentes.
class _RoxoInterstitialListener implements LevelPlayInterstitialAdListener {
  final LevelPlayInterstitialAd ad;
  _RoxoInterstitialListener(this.ad);
  @override void onAdLoaded(LevelPlayAdInfo adInfo) {}
  @override void onAdLoadFailed(LevelPlayAdError error) { debugPrint('Interstitial load: $error'); }
  @override void onAdDisplayed(LevelPlayAdInfo adInfo) {}
  @override void onAdDisplayFailed(LevelPlayAdError error, LevelPlayAdInfo adInfo) {}
  @override void onAdClicked(LevelPlayAdInfo adInfo) {}
  @override void onAdClosed(LevelPlayAdInfo adInfo) { ad.loadAd(); }
  @override void onAdInfoChanged(LevelPlayAdInfo adInfo) {}
}

class _RoxoBannerListener implements LevelPlayBannerAdViewListener {
  @override void onAdLoaded(LevelPlayAdInfo adInfo) {}
  @override void onAdLoadFailed(LevelPlayAdError error) { debugPrint('Banner load: $error'); }
  @override void onAdDisplayed(LevelPlayAdInfo adInfo) {}
  @override void onAdDisplayFailed(LevelPlayAdInfo adInfo, LevelPlayAdError error) {}
  @override void onAdClicked(LevelPlayAdInfo adInfo) {}
  @override void onAdExpanded(LevelPlayAdInfo adInfo) {}
  @override void onAdCollapsed(LevelPlayAdInfo adInfo) {}
  @override void onAdLeftApplication(LevelPlayAdInfo adInfo) {}
}
