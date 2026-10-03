import 'package:bookcase/app.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://kpnckevunpcdnlhnikol.supabase.co',
    anonKey:
        'sb_publishable_6T3UOH_lnm68SbAXsW7mxQ_3VLylpKi',
  );
  runApp(const App());
}
