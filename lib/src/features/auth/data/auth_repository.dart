import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for the [AuthRepository] instance.
///
/// This provider creates and manages the application's authentication repository.
/// It handles authentication operations such as sign in, sign up, and sign out.
///
/// Usage:
/// ```dart
/// final authRepository = ref.read(authRepositoryProvider);
/// authRepository.signIn(email: 'email', password: 'password');
/// ```
final authRepositoryProvider = Provider(
  (ref) => AuthRepository(Supabase.instance.client),
);

/// Repository for managing authentication operations.
///
/// This repository handles authentication operations such as sign in, sign up, and sign out.
/// It uses the [SupabaseClient] to interact with the authentication service.
///
/// Usage:
/// ```dart
/// final authRepository = ref.read(authRepositoryProvider);
/// authRepository.signIn(email: 'email', password: 'password');
/// ```
///
class AuthRepository {
  final SupabaseClient _client;

  AuthRepository(this._client);

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
  Session? get currentSession => _client.auth.currentSession;
  User? get currentUser => _client.auth.currentUser;

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role, // 'patient' or 'doctor'
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName, 'role': role},
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
