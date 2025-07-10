import 'package:eneam/screens/atd_history_screen.dart';
import 'package:eneam/screens/profile_screen.dart';
import 'package:eneam/screens/scanqrcode_screen.dart';
import 'package:eneam/screens/timetable_screen.dart';
import 'package:eneam/screens/senator_home_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:eneam/screens/faq_chatbot.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final bool isSenator;
  final String nom;

  const HomeScreen({
    super.key,
    this.isSenator = false,
    required this.nom,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _controller1;
  late Animation<Offset> _offsetAnimation1;
  late Animation<double> _fadeAnimation1;

  late AnimationController _controller2;
  late Animation<Offset> _offsetAnimation2;
  late Animation<double> _fadeAnimation2;

  late AnimationController _controller3;
  late Animation<Offset> _offsetAnimation3;
  late Animation<double> _fadeAnimation3;

  late AnimationController _controller4;
  late Animation<Offset> _offsetAnimation4;
  late Animation<double> _fadeAnimation4;

  @override
  void initState() {
    super.initState();

    _controller1 = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _offsetAnimation1 = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller1, curve: Curves.easeOut),
    );
    _fadeAnimation1 = CurvedAnimation(parent: _controller1, curve: Curves.easeIn);

    _controller2 = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _offsetAnimation2 = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller2, curve: Curves.easeOut),
    );
    _fadeAnimation2 = CurvedAnimation(parent: _controller2, curve: Curves.easeIn);

    _controller3 = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _offsetAnimation3 = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller3, curve: Curves.easeOut),
    );
    _fadeAnimation3 = CurvedAnimation(parent: _controller3, curve: Curves.easeIn);

    _controller4 = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _offsetAnimation4 = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller4, curve: Curves.easeOut),
    );
    _fadeAnimation4 = CurvedAnimation(parent: _controller4, curve: Curves.easeIn);

    _controller1.forward();
    Future.delayed(const Duration(milliseconds: 200), () => _controller2.forward());
    Future.delayed(const Duration(milliseconds: 400), () => _controller3.forward());
    Future.delayed(const Duration(milliseconds: 600), () => _controller4.forward());
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    _controller4.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => showFAQChatBot(context),
        backgroundColor: const Color(0xFF0D147F),
        elevation: 8,
        child: const Icon(Icons.smart_toy, color: Colors.white),
        tooltip: 'Assistant FAQ',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      backgroundColor: Color(0xFFE6E6FA),
      body: Stack(
        children: [
          // Header bleu arrondi avec style similaire au SenateurScreen
          Container(
            height: 240,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0D147F),
                  Color(0xFF1C2674),
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(50),
                bottomLeft: Radius.circular(50),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0D147F).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Header avec profil
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Salut,',
                              style: TextStyle(
                                fontFamily: 'Cabin',
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.nom.isNotEmpty ? widget.nom : 'Utilisateur',
                              style: const TextStyle(
                                fontFamily: 'Cabin',
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ProfileScreen()),
                          );
                        },
                        child: Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(29),
                            border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Bienvenue dans votre espace étudiant. Accédez à toutes vos fonctionnalités depuis cette page.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          // Contenu avec cartes
          Positioned.fill(
            top: 260,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 15),
                  FadeTransition(
                    opacity: _fadeAnimation1,
                    child: SlideTransition(
                      position: _offsetAnimation1,
                      child: _ActionCardWithIcon(
                        title: 'Historique de Présences',
                        description: 'Consultez vos présences passées et suivez votre assiduité',
                        buttonText: 'Voir l\'historique',
                        icon: Icons.history,
                        color: const Color(0xFF0D147F),
                        isDark: true,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AttendanceHistoryScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FadeTransition(
                    opacity: _fadeAnimation2,
                    child: SlideTransition(
                      position: _offsetAnimation2,
                      child: _ActionCardWithIcon(
                        title: 'Mon Emploi du Temps',
                        description: 'Visualisez votre planning et consultez vos cours à venir',
                        buttonText: 'Voir le planning',
                        icon: Icons.calendar_today_outlined,
                        color: Colors.white,
                        borderColor: const Color(0xFFE3F2FD),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EmploiDuTempsScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FadeTransition(
                    opacity: _fadeAnimation3,
                    child: SlideTransition(
                      position: _offsetAnimation3,
                      child: _ActionCardWithIcon(
                        title: 'Scanner pour valider',
                        description: 'Scannez un QR code et marquez votre présence facilement',
                        buttonText: 'Scanner maintenant',
                        icon: Icons.qr_code_scanner,
                        color: const Color(0xFF1C2674),
                        isDark: true,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ScanQRCodeScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FadeTransition(
                    opacity: _fadeAnimation4,
                    child: SlideTransition(
                      position: _offsetAnimation4,
                      child: _ActionCardWithIcon(
                        title: 'Je suis un Sénateur',
                        description: widget.isSenator
                            ? 'Accédez à vos fonctions et gérez le cahier des textes'
                            : 'Fonction non disponible - Contactez l\'administration',
                        buttonText: widget.isSenator ? 'Espace Sénateur' : 'Non disponible',
                        icon: Icons.person_add,
                        color: widget.isSenator ? Colors.white : Colors.grey.shade100,
                        borderColor: widget.isSenator ? const Color(0xFFE8F5E8) : Colors.grey.shade200,
                        isEnabled: widget.isSenator,
                        onTap: widget.isSenator
                            ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SenateurScreen(),
                            ),
                          );
                        }
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40), // Espace pour le FAB
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Carte avec icône Flutter améliorée
class _ActionCardWithIcon extends StatelessWidget {
  final String title;
  final String description;
  final String buttonText;
  final IconData icon;
  final Color color;
  final Color? borderColor;
  final VoidCallback? onTap;
  final bool isDark;
  final bool isEnabled;

  const _ActionCardWithIcon({
    required this.title,
    required this.description,
    required this.buttonText,
    required this.icon,
    required this.color,
    this.borderColor,
    required this.onTap,
    this.isDark = false,
    this.isEnabled = true,
  });

  @override
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: borderColor != null ? Border.all(color: borderColor!, width: 1.5) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(20),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFE8F0FE),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 26, color: isDark ? Colors.white : const Color(0xFF0D147F)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF0D147F),
                ),
              ),
            ),
            Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                gradient: isDark
                    ? const LinearGradient(colors: [Colors.white, Color(0xFFF8F9FA)])
                    : const LinearGradient(colors: [Color(0xFF0D147F), Color(0xFF1C2674)]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  buttonText,
                  style: TextStyle(
                    color: isDark ? const Color(0xFF0D147F) : Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

}