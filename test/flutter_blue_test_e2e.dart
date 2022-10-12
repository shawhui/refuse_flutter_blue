import 'package:flutter_test/flutter_test.dart';
import 'package:e2e/e2e.dart';
import 'package:refuse_flutter_blue/refuse_flutter_blue.dart';

void main() {
  E2EWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Is bluetooth available?', (WidgetTester tester) async {
    final RefuseFlutterBlue blue = RefuseFlutterBlue.instance;
    final bool isAvail = await blue.isAvailable;
    expect(isAvail, true);
  });
}
