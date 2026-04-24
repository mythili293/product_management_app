import 'package:flutter_test/flutter_test.dart';

import 'package:product_management_app/main.dart';

void main() {
  testWidgets('shows setup screen when Supabase is not configured', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp(isSupabaseConfigured: false));

    expect(find.text('Supabase Setup Required'), findsOneWidget);
    expect(
      find.textContaining('flutter run --dart-define=SUPABASE_URL'),
      findsOneWidget,
    );
  });
}
