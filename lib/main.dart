import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  runApp(const RoxoShopApp());
}

const bg = Color(0xFF09090F);
const panel = Color(0xFF18141F);
const purple = Color(0xFF7C3AED);
const lilac = Color(0xFFC084FC);
const dim = Color(0xFFB8AEC6);
const fortniteShop = 'https://www.fortnite.com/item-shop';
// Link permanente fornecido pelo filtro V-Bucks do FortniteDB.
const fortniteDbVbucks = 'https://fortnitedb.com/all_missions/p/f494b06eff611ab4ca088d78839f0636';
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

class _HomePageState extends State<HomePage> {
  int page = 0;
  BannerAd? _banner;
  bool _bannerReady = false;
  InterstitialAd? _interstitial;
  int _tabChanges = 0;
  DateTime? _lastInterstitial;

  void _loadInterstitial() {
    if (_interstitial != null) return;
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/1033173712',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          if (!mounted) { ad.dispose(); return; }
          _interstitial = ad;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitial = null;
              if (mounted) _loadInterstitial();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _interstitial = null;
              if (mounted) _loadInterstitial();
            },
          );
        },
        onAdFailedToLoad: (error) { debugPrint('Interstitial de teste indisponível: $error'); },
      ),
    );
  }

  void _switchPage(int value) {
    if (value == page) return;
    setState(() => page = value);
    _tabChanges += 1;
    // Exibir apenas em transições naturais, nunca ao iniciar o app ou ao clicar em links.
    // Limitar frequência: pelo menos 3 trocas de aba e intervalo de 10 minutos.
    final now = DateTime.now();
    if (_tabChanges >= 3 && _interstitial != null &&
        (_lastInterstitial == null || now.difference(_lastInterstitial!) >= const Duration(minutes: 10))) {
      final ad = _interstitial!;
      _interstitial = null;
      _lastInterstitial = now;
      _tabChanges = 0;
      ad.show();
    }
  }


  @override
  void initState() {
    super.initState();
    _loadInterstitial();
    _banner = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) setState(() => _bannerReady = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (mounted) setState(() { _bannerReady = false; _banner = null; });
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _banner?.dispose();
    _interstitial?.dispose();
    super.dispose();
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
          _shop(), _missions(), _account(), _settings(),
        ]),
      ))),
      bottomNavigationBar: SafeArea(top: false, child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_bannerReady && _banner != null && page != 3)
            Center(child: SizedBox(
              width: _banner!.size.width.toDouble(),
              height: _banner!.size.height.toDouble(),
              child: AdWidget(ad: _banner!),
            )),
          NavigationBar(
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
          ),
        ],
      )),
    );
  }

  Widget _shop() => ListView(padding: const EdgeInsets.all(16), children: [
        ClipRRect(borderRadius: BorderRadius.circular(16),
          child: Image.asset('assets/images/banner.png', fit: BoxFit.fitWidth)),
        const SizedBox(height: 20),
        _heading('Loja de Itens', 'Acesse a loja atual diretamente na página oficial do Fortnite.'),
        const SizedBox(height: 18),
        _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.shopping_bag_outlined, color: lilac, size: 34),
          const SizedBox(height: 12),
          const Text('Loja diária', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('A loja abre no navegador para mostrar informações atualizadas na fonte original.', style: TextStyle(color: dim)),
          const SizedBox(height: 16),
          _action('Abrir loja oficial', () => _open(fortniteShop)),
          const SizedBox(height: 10),
          _action('Vídeos e novidades no YouTube', () => _open(youtubeSearch), icon: Icons.play_circle_outline),
        ])),
        const SizedBox(height: 14),
        const Text('Uma API própria da loja não foi validada neste projeto. Não exibimos itens fictícios como dados atuais.', style: TextStyle(fontSize: 12, color: dim)),
      ]);

  Widget _missions() => ListView(padding: const EdgeInsets.all(16), children: [
        _heading('Alertas de V-Bucks', 'Somente missões do Salve o Mundo com recompensa em V-Bucks.'),
        const SizedBox(height: 20),
        _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [
            Icon(Icons.bolt, color: lilac, size: 30),
            SizedBox(width: 10),
            Expanded(child: Text('Missões com V-Bucks', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold))),
          ]),
          const SizedBox(height: 10),
          const Text('Veja no FortniteDB a missão, a localização, o nível e a quantidade de V-Bucks. O filtro por recompensa já está aplicado no link.', style: TextStyle(color: dim, height: 1.4)),
          const SizedBox(height: 18),
          _action('Ver missões de V-Bucks', () => _open(fortniteDbVbucks)),
        ])),
        const SizedBox(height: 14),
        _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Avisos de atualização', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Text('A conferência das missões às 21h e as notificações automáticas ainda precisam de um serviço de verificação e envio. Não vamos anunciar V-Bucks sem confirmação.', style: TextStyle(color: dim, height: 1.45)),
          const SizedBox(height: 12),
          TextButton.icon(onPressed: () => _open(fortniteDb), icon: const Icon(Icons.language), label: const Text('Abrir FortniteDB')),
        ])),
      ]);

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
        _heading('Ajustes', 'Informações da versão de teste.'),
        const SizedBox(height: 12),
        _action('Abrir YouTube: Salve o Mundo', () => _open(youtubeSearch), icon: Icons.play_circle_outline),
        const SizedBox(height: 20),
        _card(child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.palette_outlined, color: lilac), title: Text('Tema'), subtitle: Text('Preto e roxo')),
          ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.ads_click, color: lilac), title: Text('Anúncios'), subtitle: Text('Banners e anúncios de tela cheia de teste — sem receita')),
          ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.notifications_none, color: lilac), title: Text('Notificações'), subtitle: Text('Ainda não implementadas — exigem serviço de alertas')),
          ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.info_outline, color: lilac), title: Text('Versão'), subtitle: Text('0.3.0 (teste)')),
        ])),
      ]);
}
