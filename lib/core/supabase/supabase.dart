import 'package:cochasqui_park/core/app_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

loadSupabase() async {
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );
}

class AuthService {
  final _supabase = Supabase.instance.client;

  Future<AuthResponse> signUp(String email, String password) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> login(String email, String password) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
  }


Future<void> sendRecoveryCode(String email) async {
  await Supabase.instance.client.auth.signInWithOtp(
    email: email,
    emailRedirectTo: null, 
  );
}


Future<void> verifyRecoveryCodeAndChangePassword({
  required String email,
  required String token,
  required String newPassword,
}) async {
  final res = await Supabase.instance.client.auth.verifyOTP(
    type: OtpType.email,
    token: token,
    email: email,
  );

  if (res.user == null) {
    throw Exception("Código inválido o expirado");
  }

  await Supabase.instance.client.auth.updateUser(
    UserAttributes(password: newPassword),
  );
}

  User? get currentUser => _supabase.auth.currentUser;
}