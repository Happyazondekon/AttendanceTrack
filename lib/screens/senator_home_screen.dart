import 'package:flutter/material.dart';
import 'package:eneam/screens/choose_courses_screen.dart';
import 'package:eneam/screens/historique_cahier_screen.dart';


class SenateurScreen extends StatefulWidget {
  const SenateurScreen({super.key});

  @override
  State<SenateurScreen> createState() => _SenateurScreenState();
}

class _SenateurScreenState extends State<SenateurScreen> with TickerProviderStateMixin {
  late AnimationController _controller1;
  late Animation<Offset> _offsetAnimation1;
  late Animation<double> _fadeAnimation1;

  late AnimationController _controller2;
  late Animation<Offset> _offsetAnimation2;
  late Animation<double> _fadeAnimation2;

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

    // Lancement différé des animations
    _controller1.forward();
    Future.delayed(const Duration(milliseconds: 300), () => _controller2.forward());
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      body: Stack(
        children: [
          Container(
            height: 290,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF1C2674),
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(60),
                bottomLeft: Radius.circular(60),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Expanded(
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Je suis Sénateur",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 68), // pour équilibrer l’icône retour à gauche
                      ],
                    ),

                  const SizedBox(height: 22),
                  const Text(
                    "Salut, Jordy",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Cette section est réservée uniquement aux sénateurs de la classe “IG 2/B”, ici vous êtes amenés à remplir le cahier des textes et visualiser l’historique, toutes les informations seront visibles par l’administration, veuillez contrôler leurs véracité.',
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),

          // Cartes avec animation
          Positioned.fill(
            top: 320,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  FadeTransition(
                    opacity: _fadeAnimation1,
                  child: SlideTransition(
                      position: _offsetAnimation1,
                      child: _ActionCard(
                        title: 'Formulaire',
                        description: 'Remplir le cahier des textes\nAjoutez les détails des cours de chaque jours',
                        buttonText: 'Accédez au formulaire',
                        iconPath: 'assets/send.png',
                        color: const Color(0xFFB3DEFF),
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) => const ChooseScreen(),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                const begin = Offset(1.0, 0.0); // Slide from right
                                const end = Offset.zero;
                                const curve = Curves.ease;

                                final tween = Tween(begin: begin, end: end)
                                    .chain(CurveTween(curve: curve));
                                final offsetAnimation = animation.drive(tween);

                                return SlideTransition(
                                  position: offsetAnimation,
                                  child: child,
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FadeTransition(
                    opacity: _fadeAnimation2,
                    child: SlideTransition(
                      position: _offsetAnimation2,
                      child: _ActionCard(
                        title: 'Historiques',
                        description: 'Visualiser l’historique\nConsultez les cours déjà enregistrés',
                        buttonText: 'Consultez l’historique',
                        iconPath: 'assets/historique.png',
                        color: const Color(0xFF0F1F84),
                        isDark: true,
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) =>  HistoriqueCahierScreen(),
                              transitionsBuilder:
                                  (context, animation, secondaryAnimation, child) {
                                const begin = Offset(1.0, 0.0); // Slide from right
                                const end = Offset.zero;
                                const curve = Curves.ease;

                                final tween = Tween(begin: begin, end: end)
                                    .chain(CurveTween(curve: curve));
                                final offsetAnimation = animation.drive(tween);

                                return SlideTransition(
                                  position: offsetAnimation,
                                  child: child,
                                );
                              },
                            ),
                          );
                        },

                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String description;
  final String buttonText;
  final String iconPath;
  final Color color;
  final VoidCallback onTap;
  final bool isDark;

  const _ActionCard({
    required this.title,
    required this.description,
    required this.buttonText,
    required this.iconPath,
    required this.color,
    required this.onTap,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              // Texte
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1C2674),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Image.asset(
                iconPath,
                width: 60,
                height: 60,
                color: isDark ? Colors.white : null,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(
            color: isDark ? Colors.white24 : Colors.black26,
            thickness: 1,
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? Colors.white : const Color(0xFF1C2674),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: onTap,
              child: Text(
                buttonText,
                style: TextStyle(
                  color: isDark ? const Color(0xFF1C2674) : Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
