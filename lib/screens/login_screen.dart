import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import '../models/user.dart';
import '../services/user_manager.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _matriculeController = TextEditingController();
  final _codeController = TextEditingController();
  bool _codeSent = false;
  bool _isLoading = false;

  late Dio dio;
  late CookieJar cookieJar;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    dio = Dio();
    cookieJar = CookieJar();
    dio.interceptors.add(CookieManager(cookieJar));

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _matriculeController.dispose();
    _codeController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final response = await dio.post(
          'http://10.0.2.2:8000/auth/send-code',
          data: {'matricule': _matriculeController.text},
          options: Options(
            headers: {'Content-Type': 'application/json'},
          ),
        );

        if (response.statusCode == 200 && response.data['success'] == true) {
          setState(() => _codeSent = true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.data['error'] ?? 'Erreur lors de l\'envoi du code'),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Erreur de connexion au serveur'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _verifyCode() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final response = await dio.post(
          'http://10.0.2.2:8000/auth/verify-code',
          data: {'code': _codeController.text},
          options: Options(
            headers: {'Content-Type': 'application/json'},
          ),
        );

        if (response.statusCode == 200 && response.data['success'] == true) {
          final nom = response.data['data']['nom'] ?? 'Utilisateur';
          final userData = response.data['data'];
          UserManager().setUser(User.fromJson(userData));

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(
                isSenator: true,
                nom: nom,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.data['error'] ?? 'Code invalide'),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Erreur de connexion au serveur'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildGlassmorphicContainer({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.5),
            Colors.blue.withOpacity(0.1),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String? Function(String?) validator,
    bool enabled = true,
    IconData? prefixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: Colors.grey.shade600, size: 22)
              : null,
          labelStyle: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 14,
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.95),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Colors.grey.shade200,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Colors.blue.shade400,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Colors.red.shade400,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildModernButton({
    required VoidCallback? onPressed,
    required String text,
    bool isLoading = false,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: onPressed != null
              ? [
            Colors.blue.shade600,
            Colors.blue.shade700,
          ]
              : [
            Colors.grey.shade400,
            Colors.grey.shade500,
          ],
        ),
        boxShadow: onPressed != null
            ? [
          BoxShadow(
            color: Colors.blue.shade600.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ]
            : [],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? const SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
            : Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/img_bolore.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          // Overlay sombre ajouté ici

          child: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: _buildGlassmorphicContainer(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Logo avec effet d'ombre
                              Container(
                                height: 120,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Image.asset(
                                  'assets/lockk.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(height: 32),

                              // Titre avec style moderne
                              const Text(
                                'Connexion',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Accédez à votre espace personnel',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white.withOpacity(0.8),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 40),

                              // Champ matricule
                              _buildModernTextField(
                                controller: _matriculeController,
                                label: 'Matricule',
                                hint: 'Entrez votre matricule',
                                prefixIcon: Icons.badge_outlined,
                                enabled: !_codeSent,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Veuillez entrer votre matricule';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),

                              // Message de confirmation après envoi du code
                              if (_codeSent) ...[
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.green.shade200,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.mark_email_read_outlined,
                                        color: Colors.green.shade600,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'Un code a été envoyé à votre mail',
                                          style: TextStyle(
                                            color: Colors.green.shade700,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ],

                              // Champ code de vérification (animé)
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                height: _codeSent ? null : 0,
                                child: AnimatedOpacity(
                                  opacity: _codeSent ? 1.0 : 0.0,
                                  duration: const Duration(milliseconds: 300),
                                  child: _codeSent
                                      ? Column(
                                    children: [
                                      _buildModernTextField(
                                        controller: _codeController,
                                        label: 'Code de vérification',
                                        hint: 'Entrez le code reçu',
                                        prefixIcon: Icons.security_outlined,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Veuillez entrer le code de vérification';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 24),
                                    ],
                                  )
                                      : const SizedBox(),
                                ),
                              ),

                              // Bouton principal
                              _buildModernButton(
                                onPressed: _isLoading ? null : (_codeSent ? _verifyCode : _sendCode),
                                text: _codeSent ? 'Vérifier le code' : 'Envoyer le code',
                                isLoading: _isLoading,
                              ),

                              // Bouton secondaire
                              if (_codeSent) ...[
                                const SizedBox(height: 16),
                                TextButton.icon(
                                  onPressed: _isLoading
                                      ? null
                                      : () {
                                    setState(() => _codeSent = false);
                                    _codeController.clear();
                                  },
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    color: Colors.white70,
                                    size: 18,
                                  ),
                                  label: const Text(
                                    'Modifier le matricule',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ],

                              const SizedBox(height: 24),

                              // Footer
                              Text(
                                'Sécurisé et confidentiel',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.6),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}