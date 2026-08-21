import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:titan_tunes/core/api_config.dart';
import 'package:titan_tunes/core/app_theme.dart';
import 'package:titan_tunes/data/repositories/audio_repository.dart';
import 'package:titan_tunes/data/repositories/remote_audio_repository.dart';
import 'package:titan_tunes/data/services/abonnement_service.dart';
import 'package:titan_tunes/data/services/artiste_service.dart';
import 'package:titan_tunes/data/services/banniere_service.dart';
import 'package:titan_tunes/data/services/recherche_service.dart';
import 'package:titan_tunes/network/network_api_client.dart';
import 'package:titan_tunes/network/secure_token_storage.dart';
import 'package:titan_tunes/presentation/pages/login_page.dart';
import 'package:titan_tunes/presentation/pages/profil/page_profil.dart';
import 'package:titan_tunes/presentation/pages/subscription_page.dart';
import 'package:titan_tunes/presentation/screens/home_screen.dart';
import 'package:titan_tunes/presentation/screens/splash_screen.dart';
import 'package:titan_tunes/providers/abonnement_provider.dart';
import 'package:titan_tunes/providers/artiste_provider.dart';
import 'package:titan_tunes/providers/audio_provider.dart';
import 'package:titan_tunes/providers/auth_provider.dart';
import 'package:titan_tunes/providers/banniere_provider.dart';
import 'package:titan_tunes/services/api_auth_service.dart';
import 'package:titan_tunes/services/download_storage_service.dart';
import 'package:titan_tunes/services/google_auth_service.dart';
import 'package:titan_tunes/services/local_user_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.black,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // ── Stockage local ─────────────────────────────────────────────────────────
  final localStorage = await LocalUserStorage.create();
  final downloadStorage = await DownloadStorageService.create();

  // ── Services réseau ────────────────────────────────────────────────────────
  final tokenVault = TokenVault(storage: const SecureTokenStorage());
  await tokenVault.initialize();

  final baseUrl = ApiConfig.defaultBaseUrl;
  final apiClient = NetworkApiClient(tokenVault: tokenVault, baseUrl: baseUrl);
  final apiAuth = ApiAuthService(client: apiClient);
  final googleAuth = GoogleAuthService(client: apiClient);

  // ── Test de connectivité ───────────────────────────────────────────────────
  final bool backendAvailable = await _pingBackend(apiClient);

  final AudioRepository audioRepository;
  final BanniereService banniereService;
  final AbonnementService abonnementService;
  final ArtisteService artisteService;
  final RechercheService rechercheService;

  if (backendAvailable) {
    audioRepository = RemoteAudioRepository(
      apiClient: apiClient,
      downloadStorage: downloadStorage,
      userId: localStorage.userId,
    );
    banniereService = RemoteBanniereService(client: apiClient);
    abonnementService = RemoteAbonnementService(client: apiClient);
    artisteService = RemoteArtisteService(client: apiClient);
    rechercheService = RemoteRechercheService(client: apiClient);
    debugPrint(
      '✅ Backend Titan Tunes disponible ($baseUrl) — mode réseau activé.',
    );
  } else {
    audioRepository = MockAudioRepository();
    banniereService = MockBanniereService();
    abonnementService = MockAbonnementService();
    artisteService = MockArtisteService();
    rechercheService = MockRechercheService();
    debugPrint('⚠️  Backend injoignable ($baseUrl) — mode mock activé.');
  }

  // ── AuthProvider ───────────────────────────────────────────────────────────
  final authProvider = AuthProvider();
  await authProvider.init(
    storage: localStorage,
    tokenVault: tokenVault,
    apiAuth: apiAuth,
    googleAuth: googleAuth,
  );

  // Synchroniser le userId dans le repository distant après restauration de session
  if (audioRepository is RemoteAudioRepository && authProvider.userId != null) {
    audioRepository.userId = authProvider.userId;
    await audioRepository.initialize();
  }

  // Propager les changements de session (login/logout) vers le repository distant
  authProvider.addListener(() async {
    if (audioRepository is RemoteAudioRepository) {
      final repo = audioRepository as RemoteAudioRepository;
      // Mettre à jour l'userId pour que les appels distants soient authentifiés
      repo.userId = authProvider.userId;
      try {
        await repo.initialize();
      } catch (e) {
        debugPrint('Error initializing remote repo after auth change: $e');
      }
    }
  });

  if (!backendAvailable && !authProvider.isLoggedIn) {
    authProvider.loginDemo();
  }

  // Purger les téléchargements expirés au démarrage
  final purgedCount = await downloadStorage.purgeExpired();
  if (purgedCount > 0) {
    debugPrint('🗑️ $purgedCount téléchargement(s) expiré(s) supprimé(s).');
  }

  runApp(
    TitanTunesApp(
      authProvider: authProvider,
      audioRepository: audioRepository,
      banniereService: banniereService,
      abonnementService: abonnementService,
      artisteService: artisteService,
      rechercheService: rechercheService,
      downloadStorage: downloadStorage,
      backendAvailable: backendAvailable,
    ),
  );
}

Future<bool> _pingBackend(NetworkApiClient client) async {
  try {
    final response = await client
        .get('/chansons')
        .timeout(
          const Duration(seconds: 3),
          onTimeout: () => throw Exception('timeout'),
        );
    return (response.statusCode ?? 0) < 500;
  } catch (_) {
    return false;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class TitanTunesApp extends StatelessWidget {
  final AuthProvider authProvider;
  final AudioRepository audioRepository;
  final BanniereService banniereService;
  final AbonnementService abonnementService;
  final ArtisteService artisteService;
  final RechercheService rechercheService;
  final DownloadStorageService downloadStorage;
  final bool backendAvailable;

  const TitanTunesApp({
    super.key,
    required this.authProvider,
    required this.audioRepository,
    required this.banniereService,
    required this.abonnementService,
    required this.artisteService,
    required this.rechercheService,
    required this.downloadStorage,
    required this.backendAvailable,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<AudioProvider>(
          create: (_) => AudioProvider(
            repository: audioRepository,
            dlStorage: downloadStorage,
            authProvider: authProvider,
          ),
        ),
        ChangeNotifierProvider<BanniereProvider>(
          create: (_) => BanniereProvider(service: banniereService),
        ),
        ChangeNotifierProvider<AbonnementProvider>(
          create: (_) => AbonnementProvider(service: abonnementService),
        ),
        ChangeNotifierProvider<ArtisteProvider>(
          create: (_) => ArtisteProvider(service: artisteService),
        ),
        Provider<RechercheService>.value(value: rechercheService),
        ChangeNotifierProvider<DownloadStorageService>.value(
          value: downloadStorage,
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
              statusBarBrightness: Brightness.dark,
              systemNavigationBarColor: Colors.black,
              systemNavigationBarIconBrightness: Brightness.light,
            ),
            child: MaterialApp(
              title: 'Titan Tunes',
              theme: AppTheme.buildTheme(
                brightness: Brightness.light,
                primaryColor: AppColors.primaryLight,
                accentColor: AppColors.accentDeepOrange,
              ),
              darkTheme: AppTheme.buildTheme(
                brightness: Brightness.dark,
                primaryColor: AppColors.primaryDark,
                accentColor: AppColors.accentSkyBlue,
              ),
              themeMode: auth.themeMode,
              debugShowCheckedModeBanner: false,
              home: Stack(
                children: [
                  const SplashScreen(),
                  if (!backendAvailable)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: SafeArea(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          color: Colors.orange.shade800,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.wifi_off_rounded,
                                  color: Colors.white, size: 16),
                              SizedBox(width: 6),
                              Text(
                                'Mode hors-ligne — données démo',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              routes: {
                '/home': (_) => const HomeScreen(),
                '/login': (_) => const LoginPage(),
                '/subscription': (_) => const SubscriptionPage(),
                '/profile': (ctx) =>
                    ProfilePage(provider: Provider.of<AudioProvider>(ctx)),
              },
            ),
          );
        },
      ),
    );
  }
}
