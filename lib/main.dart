import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/storage/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/presentation/pages/settings_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  runApp(const ProviderScope(child: FusionIslandApp()));
}

class FusionIslandApp extends ConsumerWidget {
  const FusionIslandApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeOption = ref.watch(selectedThemeModeProvider);

    return MaterialApp.router(
      title: 'Fusion Island',
      debugShowCheckedModeBanner: false,
      theme: themeOption == ThemeModeOption.amoled
          ? AppTheme.amoledTheme
          : AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: AppRouter.router,
    );
  }
}
