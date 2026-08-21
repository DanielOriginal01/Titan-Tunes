import 'package:titan_tunes/network/network_api_client.dart';

// Lightweight stub for Google auth to avoid tight coupling with the
// `google_sign_in` package version. The app's demo `AuthProvider` performs
// local simulation of Google login, so this service is optional at runtime.
class GoogleAuthService {
  GoogleAuthService({required NetworkApiClient client});

  /// Stubbed signIn — callers should prefer using `ApiAuthService.oauth2Callback`
  /// or the app's own demo flow. This throws to indicate real Google flow
  /// is not wired in this build.
  Future<Never> signIn({String role = 'ROLE_AUDITEUR'}) async {
    throw UnsupportedError('Google Sign-In is not available in this build.');
  }

  Future<void> signOut() async {
    // No-op stub
    return;
  }
}
