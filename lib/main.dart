import 'package:eneam/screens/atd_fail_screen.dart';
import 'package:eneam/screens/login_screen.dart';
import 'package:eneam/screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'screens/home_screen.dart'; // Import de l'écran d'accueil

void main() {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Présence',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4C51BF)),
        useMaterial3: true,
        fontFamily: 'Cabin', // Police personnalisée
      ),
      home: const AppLauncher(),
      debugShowCheckedModeBanner: false, // Suppression du bandeau "Debug"
    );
  }
}

class AppLauncher extends StatelessWidget {
  const AppLauncher({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4C51BF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo de l'application
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.access_time_filled,
                  size: 80,
                  color: Color(0xFF4C51BF),
                ),
              ),

              const SizedBox(height: 30),

              // Bouton pour l'utilisateur normal
              _buildLaunchButton(
                context,
                title: 'Utilisateur Normal',
                subtitle: 'Accès standard',
                icon: Icons.person,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HomeScreen(isSenator: false, nom: '', ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),
              // Bouton pour l'utilisateur normal
              _buildLaunchButton(
                context,
                title: 'Authentification',
                subtitle: 'Requis',
                icon: Icons.login,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),

              // Bouton pour profile
              _buildLaunchButton(
                context,
                title: 'Page erreur',
                subtitle: 'Accès standard',
                icon: Icons.error,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GPSErrorScreen()),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Bouton pour le sénateur
              _buildLaunchButton(
                context,
                title: 'Sénateur',
                subtitle: 'Accès complet',
                icon: Icons.star,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HomeScreen(isSenator: true, nom: '',),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLaunchButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(icon, size: 32, color: const Color(0xFF4C51BF)),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,














                    color: Color(0xFF4C51BF),
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

































