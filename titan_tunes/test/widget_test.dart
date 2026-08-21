// Tests de base Titan Tunes
//
// Le test de smoke réel nécessite une initialisation async (SharedPreferences,
// SecureStorage, NetworkApiClient) qui ne peut pas être faite dans un simple
// pumpWidget. On vérifie ici uniquement que les widgets de base s'importent
// et que les énumérations clés existent.

import 'package:flutter_test/flutter_test.dart';
import 'package:titan_tunes/providers/auth_provider.dart';

void main() {
  test('SubscriptionPlan enum has expected values', () {
    expect(SubscriptionPlan.values.length, 3);
    expect(SubscriptionPlan.values, contains(SubscriptionPlan.free));
    expect(SubscriptionPlan.values, contains(SubscriptionPlan.weekly));
    expect(SubscriptionPlan.values, contains(SubscriptionPlan.monthly));
  });

  test('AuthMethod enum has expected values', () {
    expect(AuthMethod.values, contains(AuthMethod.demo));
    expect(AuthMethod.values, contains(AuthMethod.backend));
    expect(AuthMethod.values, contains(AuthMethod.phone));
  });

  test('AuthProvider displayName fallback', () {
    final auth = AuthProvider();
    // Sans initialisation, displayName retourne le fallback
    expect(auth.displayName, 'Titan Tunes');
    expect(auth.isLoggedIn, false);
    expect(auth.isSubscribed, false);
  });
}
