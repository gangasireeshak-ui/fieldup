import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  await GoogleFonts.pendingFonts([GoogleFonts.barlowCondensed()]);

  const supabaseUrl = String.fromEnvironment('SUPABASE_URL',
      defaultValue: 'https://nweibhcjqnumxcpwnrvo.supabase.co');
  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY',
      defaultValue:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im53ZWliaGNqcW51bXhjcHducnZvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODIwMjAzNjIsImV4cCI6MjA5NzU5NjM2Mn0.O4LNQOY2Ub69KcKnGBqbsFG2D6NkB8wdEfmIPqYJEgo');

  try {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.implicit,
        autoRefreshToken: false,
      ),
    );
  } catch (_) {
    await const FlutterSecureStorage().deleteAll();
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.implicit,
        autoRefreshToken: false,
      ),
    );
  }

  runApp(const ProviderScope(child: VendorApp()));
}
