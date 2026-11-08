import 'package:bookcase/app.dart';
import 'package:bookcase/features/auth/auth_service.dart';
import 'package:bookcase/features/auth/login_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://kpnckevunpcdnlhnikol.supabase.co',
    publishableKey: 'sb_publishable_6T3UOH_lnm68SbAXsW7mxQ_3VLylpKi',
  );

  await AuthService.restoreSession();
  final isApiAuthenticated = AuthService().isAuthenticated;

  runApp(App(initialHome: isApiAuthenticated ? null : const LoginPage()));
}
