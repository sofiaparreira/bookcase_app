import 'package:bookcase/app.dart';
import 'package:bookcase/features/auth/login_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://kpnckevunpcdnlhnikol.supabase.co',
    publishableKey: 'sb_publishable_6T3UOH_lnm68SbAXsW7mxQ_3VLylpKi',
  );

  final session = Supabase.instance.client.auth.currentSession;

  runApp(App(initialHome: session == null ? const LoginPage() : null));
}
