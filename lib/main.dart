import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'package:learning_app/firebase_options.dart';
import 'package:learning_app/app/router/app_router.dart';

// Features
import 'package:learning_app/features/overview/providers/sync_provider.dart';
import 'package:learning_app/features/auth/providers/auth_provider.dart';
import 'package:learning_app/features/home/providers/material_provider.dart';
import 'package:learning_app/features/history/providers/attempt_provider.dart';

// Core
import 'package:learning_app/core/providers/connectivity_provider.dart';
import 'package:learning_app/core/services/firestore_service.dart';
import 'package:learning_app/core/services/llm_service.dart';
import 'package:learning_app/core/services/auth_service.dart';
import 'package:learning_app/core/repositories/local_storage_repository.dart';
import 'package:learning_app/core/models/material_model.dart' as mt;
import 'package:learning_app/core/models/question_model.dart';
import 'package:learning_app/core/models/attempt_model.dart';
import 'package:provider/single_child_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await initializeDateFormatting('id_ID', null);

  await _initHive();

  final llmService = LlmService();
  await llmService.initialize();

  runApp(MyApp(llmService: llmService));
}

class MyApp extends StatelessWidget {
  final LlmService llmService;
  const MyApp({super.key, required this.llmService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: buildProviders(llmService),
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final router = AppRouter(authProvider: authProvider).router;
          return MaterialApp.router(
            title: 'Interactive Learning',
            debugShowCheckedModeBanner: false,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('id', 'ID')],
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),
            routerConfig: router,
          );
        },
      ),
    );
  }
}

List<SingleChildWidget> buildProviders(LlmService llmService) {
  return [
    Provider(create: (_) => LocalStorageRepository()),
    Provider(create: (_) => AuthService()),
    Provider(create: (_) => FirestoreService()),
    Provider.value(value: llmService),

    ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
    ChangeNotifierProvider(
      create: (context) =>
          AuthProvider(authService: context.read<AuthService>()),
    ),
    ChangeNotifierProvider(
      create: (context) => MaterialProvider(
        repository: context.read<LocalStorageRepository>(),
        firestoreService: context.read<FirestoreService>(),
      )..loadMaterialsFromLocal(),
    ),
    ChangeNotifierProvider(
      create: (context) =>
          AttemptProvider(repository: context.read<LocalStorageRepository>())
            ..loadAttempts(),
    ),
    ChangeNotifierProxyProvider4<
      AuthProvider,
      ConnectivityProvider,
      LocalStorageRepository,
      FirestoreService,
      SyncProvider
    >(
      create: (context) => SyncProvider(
        authProvider: context.read<AuthProvider>(),
        connectivityProvider: context.read<ConnectivityProvider>(),
        localRepo: context.read<LocalStorageRepository>(),
        firestoreService: context.read<FirestoreService>(),
      ),
      update: (_, auth, connectivity, localRepo, firestore, __) => SyncProvider(
        authProvider: auth,
        connectivityProvider: connectivity,
        localRepo: localRepo,
        firestoreService: firestore,
      ),
    ),
  ];
}

Future<void> _initHive() async {
  await Hive.initFlutter();
  Hive.registerAdapter(mt.MaterialAdapter());
  Hive.registerAdapter(QuestionAdapter());
  Hive.registerAdapter(AttemptAdapter());

  await Hive.openBox<mt.Material>('materials');
  await Hive.openBox<Attempt>('attempts');
}
