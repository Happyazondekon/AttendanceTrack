import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:lottie/lottie.dart';

// Service IA intégré
class AIService {
  static const String _groqApiKey = ''; // Gratuit et rapide
  static const String _cohereApiKey = ''; // Gratuit avec limite
  static Future<String> getGroqResponse(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_groqApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'llama3-8b-8192',
          'messages': [
            {
              'role': 'system',
              'content': 'Tu es Eneambot, l\'assistant intelligent de l\'application ENEAM pour étudiants. Tu aides avec les questions sur l\'app de gestion des présences, tu peux répondre amicalement à leur salutation, donner des conseils utiles pour leur réussite, bien-être ou organisation personnelle, et leur rappeler que leur école est la meilleure. Réponds en français de manière concise, chaleureuse et utile.'
            },
            {
              'role': 'user',
              'content': prompt
            }
          ],
          'max_tokens': 150,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'].trim();
      }
    } catch (e) {
      print('Erreur Groq: $e');
    }
    return '';
  }

  static Future<String> getCohereResponse(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.cohere.ai/v1/generate'),
        headers: {
          'Authorization': 'Bearer $_cohereApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'command-light',
          'prompt': '''Tu es Eneambot, assistant de l'app ENEAM. Question: $prompt. Réponse:''',
          'max_tokens': 100,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['generations'] != null && data['generations'].isNotEmpty) {
          return data['generations'][0]['text'].trim();
        }
      }
    } catch (e) {
      print('Erreur Cohere: $e');
    }
    return '';
  }

  static Future<String> getAIResponse(String prompt) async {
    // Essayer Groq d'abord (gratuit et rapide)
    String response = await getGroqResponse(prompt);
    if (response.isNotEmpty) return response;

    // Puis Cohere en fallback
    response = await getCohereResponse(prompt);
    if (response.isNotEmpty) return response;

    return "Je rencontre des difficultés techniques. Contactez le support pour plus d'aide.";
  }
}

class FAQChatBot {
  static final Map<String, String> faqQuestions = {
    "Comment marquer ma présence?": "Pour marquer votre présence, allez dans le menu principal et cliquez sur 'Scanner pour valider'. Scannez ensuite le QR code affiché en cours.",
    "Où voir mon historique?": "L'historique de vos présences est disponible dans la section 'Historique de Présences' du menu principal.",
    "Comment fonctionne l'emploi du temps?": "L'emploi du temps affiche vos cours programmés. Vous pouvez le consulter dans la section 'Mon Emploi du Temps'.",
    "Que faire si je suis sénateur?": "Si vous êtes sénateur, vous aurez accès à des fonctions supplémentaires pour gérer les présences des étudiants.",
    "Problème de connexion?": "Vérifiez votre connexion internet. Si le problème persiste, contactez le support technique de l'école.",
    "Comment scanner un QR code?": "Utilisez la fonction 'Scanner pour valider' du menu principal. Pointez votre caméra vers le QR code affiché par le professeur.",
    "Puis-je modifier mes informations?": "Oui, rendez-vous dans votre profil pour modifier vos informations personnelles.",
    "Comment fonctionne la validation des présences?": "La validation se fait via QR code généré par le professeur. Vous devez scanner ce code pendant le cours.",
    "Que faire si le QR code ne fonctionne pas?": "Assurez-vous d'avoir une bonne connexion internet et que votre caméra fonctionne correctement. Contactez votre professeur si le problème persiste.",
    "Comment voir mes absences?": "Dans l'historique des présences, vous pouvez voir tous vos cours et identifier ceux où vous étiez absent.",
  };

  static List<String> getSuggestions(String query) {
    if (query.isEmpty) return faqQuestions.keys.toList().take(6).toList();

    return faqQuestions.keys.where((question) {
      return question.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  static String getLocalAnswer(String question) {
    // Recherche exacte
    if (faqQuestions.containsKey(question)) {
      return faqQuestions[question]!;
    }

    // Recherche par mots-clés
    String queryLower = question.toLowerCase();
    for (String key in faqQuestions.keys) {
      if (key.toLowerCase().contains(queryLower) ||
          queryLower.contains(key.toLowerCase().split(' ')[0])) {
        return faqQuestions[key]!;
      }
    }

    return "";
  }

  static Future<String> getAnswer(String question) async {
    // D'abord, chercher dans les réponses locales
    String localAnswer = getLocalAnswer(question);
    if (localAnswer.isNotEmpty) {
      return localAnswer;
    }

    // Si pas de réponse locale, utiliser l'IA
    return await AIService.getAIResponse(question);
  }
}

class FAQChatBotPopup extends StatefulWidget {
  const FAQChatBotPopup({super.key});

  @override
  State<FAQChatBotPopup> createState() => _FAQChatBotPopupState();
}

class _FAQChatBotPopupState extends State<FAQChatBotPopup>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<Map<String, dynamic>> messages = [];
  List<String> suggestions = [];
  bool isTyping = false;
  late AnimationController _typingController;
  late AnimationController _botAvatarController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();

    // Initialiser les contrôleurs d'animation
    _typingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _botAvatarController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Messages de bienvenue avec animation
    _addWelcomeMessages();

    suggestions = FAQChatBot.getSuggestions("");

    // Démarrer les animations
    _botAvatarController.repeat();
    _pulseController.repeat(reverse: true);
  }

  void _addWelcomeMessages() {
    // Premier message
    messages.add({
      'sender': 'bot',
      'text': 'Bonjour! 👋',
      'timestamp': DateTime.now(),
    });

    // Deuxième message après un délai
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        messages.add({
          'sender': 'bot',
          'text': 'Je suis Eneambot 🤖, votre assistant intelligent pour l\'application ENEAM!',
          'timestamp': DateTime.now(),
        });
        _listKey.currentState?.insertItem(messages.length - 1);
        _scrollToBottom();
      }
    });

    // Troisième message après un autre délai
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) {
        messages.add({
          'sender': 'bot',
          'text': 'Posez-moi toutes vos questions sur l\'utilisation de l\'application. Je suis là pour vous aider! 💡',
          'timestamp': DateTime.now(),
        });
        _listKey.currentState?.insertItem(messages.length - 1);
        _scrollToBottom();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _typingController.dispose();
    _botAvatarController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final question = _controller.text.trim();
    _controller.clear();

    // Ajouter la question de l'utilisateur
    messages.add({
      'sender': 'user',
      'text': question,
      'timestamp': DateTime.now(),
    });

    // Notifier l'AnimatedList du nouvel élément
    _listKey.currentState?.insertItem(messages.length - 1);

    // Mettre à jour l'état pour afficher l'indicateur de frappe
    setState(() {
      isTyping = true;
      // Mettre à jour les suggestions
      suggestions = FAQChatBot.getSuggestions(question);
    });

    // Faire défiler vers le bas
    _scrollToBottom();

    // Démarrer l'animation de frappe
    _typingController.repeat();

    // Obtenir la réponse de l'IA
    try {
      final answer = await FAQChatBot.getAnswer(question);

      // Simuler un délai de réponse réaliste
      await Future.delayed(const Duration(milliseconds: 1200));

      if (mounted) {
        setState(() {
          isTyping = false;
        });

        // Ajouter la réponse du bot
        messages.add({
          'sender': 'bot',
          'text': answer,
          'timestamp': DateTime.now(),
        });

        // Notifier l'AnimatedList du nouvel élément
        _listKey.currentState?.insertItem(messages.length - 1);

        _typingController.stop();
        _scrollToBottom();
      }

    } catch (e) {
      if (mounted) {
        setState(() {
          isTyping = false;
        });

        messages.add({
          'sender': 'bot',
          'text': 'Désolé, j\'ai rencontré un problème technique. Veuillez réessayer.',
          'timestamp': DateTime.now(),
        });

        _listKey.currentState?.insertItem(messages.length - 1);
        _typingController.stop();
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Color(0xFFE6E6FA),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        children: [
          // Header du chat avec animation améliorée
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0D147F),
                  Color(0xFF4C51BF),
                  Color(0xFF667EEA),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0D147F).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                // Avatar animé avec pulse
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Effet de pulse
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Container(
                          width: 50 + (_pulseController.value * 5),
                          height: 50 + (_pulseController.value * 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1 - _pulseController.value * 0.1),
                            borderRadius: BorderRadius.circular(25),
                          ),
                        );
                      },
                    ),
                    // Avatar principal
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(22.5),
                      ),
                      child: RotationTransition(
                        turns: Tween(begin: 0.0, end: 1.0).animate(
                          CurvedAnimation(
                            parent: _botAvatarController,
                            curve: Curves.easeInOut,
                          ),
                        ),
                        child: const Icon(
                          Icons.smart_toy_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Eneambot',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'IA',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.greenAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Assistant intelligent • En ligne',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Messages avec AnimatedList corrigée
          Expanded(
            child: AnimatedList(
              key: _listKey,
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              initialItemCount: messages.length,
              itemBuilder: (context, index, animation) {
                // Gérer l'indicateur de frappe
                if (isTyping && index == messages.length) {
                  return SlideTransition(
                    position: animation.drive(
                      Tween(begin: const Offset(0, 1), end: Offset.zero),
                    ),
                    child: _buildTypingIndicator(),
                  );
                }

                // Afficher les messages normaux
                if (index < messages.length) {
                  final message = messages[index];
                  return SlideTransition(
                    position: animation.drive(
                      Tween(begin: const Offset(0, 1), end: Offset.zero),
                    ),
                    child: _buildMessageBubble(message),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),

          // Indicateur de frappe séparé
          if (isTyping)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildTypingIndicator(),
            ),

          // Suggestions rapides
          if (suggestions.isNotEmpty) ...[
            Container(
              height: 70,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Suggestions rapides:',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: suggestions.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ActionChip(
                            avatar: const Icon(Icons.lightbulb_outline, size: 16),
                            label: Text(
                              suggestions[index],
                              style: const TextStyle(fontSize: 12),
                            ),
                            onPressed: () {
                              _controller.text = suggestions[index];
                              _sendMessage();
                            },
                            backgroundColor: const Color(0xFF0D147F).withOpacity(0.1),
                            side: BorderSide(
                              color: const Color(0xFF0D147F).withOpacity(0.3),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Champ de saisie premium
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(
                top: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Posez votre question à Eneambot...',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                        prefixIcon: Icon(
                          Icons.chat_bubble_outline,
                          color: Colors.grey[400],
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                      maxLines: null,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0D147F), Color(0xFF4C51BF)],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0D147F).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(25),
                      onTap: _sendMessage,
                      child: const Padding(
                        padding: EdgeInsets.all(14),
                        child: Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isUser = message['sender'] == 'user';

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          gradient: isUser
              ? const LinearGradient(
            colors: [Color(0xFF0D147F), Color(0xFF4C51BF)],
          )
              : null,
          color: isUser ? null : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser) ...[
              Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0D147F), Color(0xFF4C51BF)],
                      ),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Icon(
                      Icons.smart_toy_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Eneambot',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D147F),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
            ],
            Text(
              message['text'],
              style: TextStyle(
                color: isUser ? Colors.white : Colors.black87,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0D147F), Color(0xFF4C51BF)],
                ),
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                color: Colors.white,
                size: 14,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Eneambot réfléchit',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 40,
              height: 20,
              child: AnimatedBuilder(
                animation: _typingController,
                builder: (context, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(3, (index) {
                      final animationValue = (_typingController.value + index * 0.33) % 1.0;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 4,
                        height: 4 + (animationValue * 4),
                        decoration: BoxDecoration(
                          color: Color.lerp(
                            Colors.grey[300],
                            const Color(0xFF0D147F),
                            animationValue,
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showFAQChatBot(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return const FAQChatBotPopup();
    },
  );
}