import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔗 Inisialisasi Supabase
  await Supabase.initialize(
    url:
        'https://handpafrhlymeerqiblx.supabase.co', // ganti dengan URL project Supabase
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhhbmRwYWZyaGx5bWVlcnFpYmx4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTg2OTY2MDUsImV4cCI6MjA3NDI3MjYwNX0.jm7lFz1sxLQzSVrFj8PKG7-8rVVIfr7jiCUZokQjXOA', // ganti dengan anon key dari Supabase
  );

  runApp(const MojarnikApp());
}

class MojarnikApp extends StatelessWidget {
  const MojarnikApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MOJARNIK',
      theme: ThemeData(
        primarySwatch: Colors.red,
        fontFamily: 'Roboto',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
