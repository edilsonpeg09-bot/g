import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  runApp(const RoxoShopApp());
}

const bg = Color(0xFF09090F);
const panel = Color(0xFF18141F);
const purple = Color(0xFF7C3AED);
const lilac = Color(0xFFC084FC);

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
      cardTheme: const CardThemeData(color: panel),
      appBarTheme: const AppBarTheme(backgroundColor: bg, foregroundColor: Colors.white),
    ),
    home: const HomePage(),
  );
}

class Mission {
  final String name, region, reward, description;
  final int power;
  const Mission(this.name, this.region, this.reward, this.description, this.power);
}

// Dados ilustrativos, apenas para testar a interface. NÃO são alertas ativos.
const demoMissions = <Mission>[
  Mission('Missão de exemplo A', 'Floresta Pétrea', 'V-Bucks', 'Recompensa demonstrativa', 15),
  Mission('Missão de exemplo B', 'Plankerton', 'Heróis', 'Recompensa demonstrativa', 34),
  Mission('Missão de exemplo C', 'Canny Valley', 'Esquemas', 'Recompensa demonstrativa', 64),
  Mission('Missão de exemplo D', 'Twine Peaks', 'Materiais', 'Recompensa demonstrativa', 100),
  Mission('Missão de exemplo E', 'Twine Peaks', 'Sobreviventes', 'Recompensa demonstrativa', 124),
];

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int page = 1;
  String region = 'Todas';
  String reward = 'Todas';
  BannerAd? _banner;
  bool _bannerReady = false;

  @override
  void initState() {
    super.initState();
    _banner = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111', // ID oficial de TESTE Android
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(['Roxo Shop · Loja', 'Salve o Mundo', 'Ajustes'][page])),
      body: SafeArea(child: IndexedStack(index: page, children: [
        _shop(), _missions(), _settings(),
      ])),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Somente banner de teste oficial; não gera receita.
          if (page != 2 && _bannerReady && _banner != null)
            SizedBox(
              width: _banner!.size.width.toDouble(),
              height: _banner!.size.height.toDouble(),
              child: AdWidget(ad: _banner!),
            ),
          NavigationBar(
        backgroundColor: panel,
        indicatorColor: purple,
        selectedIndex: page,
        onDestinationSelected: (value) => setState(() => page = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.shopping_bag_outlined), label: 'Loja'),
          NavigationDestination(icon: Icon(Icons.shield_outlined), label: 'Salve o Mundo'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Ajustes'),
        ],
          ),
        ],
      ),
    );
  }

  Widget _shop() => ListView(children: [
    Image.asset('assets/images/banner.png', fit: BoxFit.fitWidth),
    const Padding(padding: EdgeInsets.all(20), child: Column(children: [
      Text('Loja de Itens', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
      SizedBox(height: 14),
      Text('Demonstração: a integração com a loja real será adicionada depois.', textAlign: TextAlign.center),
    ])),
  ]);

  Widget _settings() => ListView(children: const [
    ListTile(title: Text('Tema'), subtitle: Text('Preto e roxo')),
    ListTile(title: Text('Fonte de alertas'), subtitle: Text('Aguardando integração de dados reais')),
    ListTile(title: Text('Identidade'), subtitle: Text('Roxo Shop — dragão roxo')),
  ]);

  Widget _missions() {
    final shown = demoMissions.where((m) =>
      (region == 'Todas' || m.region == region) &&
      (reward == 'Todas' || m.reward == reward)).toList();
    return ListView(padding: const EdgeInsets.all(16), children: [
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: const Color(0xFF1D152D), borderRadius: BorderRadius.circular(16)),
        child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('ALERTAS DE MISSÕES', style: TextStyle(color: lilac, fontWeight: FontWeight.w600)),
          SizedBox(height: 8),
          Text('Todas as recompensas', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('Prévia visual — as missões abaixo são fictícias e não representam alertas atuais.'),
        ]),
      ),
      const SizedBox(height: 18),
      _filter('Região', region, const ['Todas', 'Floresta Pétrea', 'Plankerton', 'Canny Valley', 'Twine Peaks'],
        (v) => setState(() => region = v!)),
      const SizedBox(height: 10),
      _filter('Recompensa', reward,
        const ['Todas', 'V-Bucks', 'Heróis', 'Sobreviventes', 'Esquemas', 'Materiais'],
        (v) => setState(() => reward = v!)),
      const SizedBox(height: 16),
      Text('Missões de demonstração (${shown.length})',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 10),
      if (shown.isEmpty) const ListTile(title: Text('Nenhuma missão para estes filtros.')),
      ...shown.map((m) => Card(child: ListTile(
        title: Text(m.name),
        subtitle: Text('${m.region} • Poder ${m.power}\n${m.description}'),
        isThreeLine: true,
        trailing: Text(m.reward, style: const TextStyle(color: lilac, fontWeight: FontWeight.w600)),
      ))),
    ]);
  }

  Widget _filter(String title, String value, List<String> choices, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: title, filled: true, fillColor: panel,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
      items: choices.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
      onChanged: onChanged,
    );
  }
}
