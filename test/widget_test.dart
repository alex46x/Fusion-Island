import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fusion_island/core/storage/storage_service.dart';
import 'package:fusion_island/main.dart';

void main() {
  testWidgets('FusionIslandApp builds test', (WidgetTester tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({'onboarding_completed': true});
    await StorageService.init();

    Animate.restartOnHotReload = false;
    await tester.pumpWidget(const ProviderScope(child: FusionIslandApp()));
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    expect(find.byType(FusionIslandApp), findsOneWidget);
  });
}
