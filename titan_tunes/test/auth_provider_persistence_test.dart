import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:titan_tunes/providers/auth_provider.dart';
import 'package:titan_tunes/services/local_user_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('AuthProvider restores user session from local storage', () async {
    final storage = await LocalUserStorage.create();
    await storage.saveSession(
      isLoggedIn: true,
      userId: 'u_42',
      userName: 'NanaT',
      firstName: 'Nana',
      lastName: 'Togo',
      email: 'nana@example.com',
      phone: '+22890000000',
      role: 'ROLE_ARTISTE',
      authMethod: 'backend',
      avatarUrl: 'https://example.com/avatar.png',
      subscriptionPlan: 'monthly',
      subscriptionExpiry: DateTime.now().add(const Duration(days: 30)),
      isPhoneVerified: true,
    );

    final auth = AuthProvider();
    await auth.init(storage: storage);

    expect(auth.isLoggedIn, isTrue);
    expect(auth.userId, 'u_42');
    expect(auth.userName, 'NanaT');
    expect(auth.email, 'nana@example.com');
    expect(auth.isArtist, isTrue);
    expect(auth.isPhoneVerified, isTrue);
    expect(auth.isSubscribed, isTrue);
  });
}
