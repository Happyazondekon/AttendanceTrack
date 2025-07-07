import 'package:flutter/material.dart';

class FAQChatBot {
  static final Map<String, String> faqQuestions = {
    "Comment marquer ma présence?": "Pour marquer votre présence, allez dans le menu principal et cliquez sur 'Scanner pour valider'. Scannez ensuite le QR code affiché en cours.",
    "Où voir mon historique?": "L'historique de vos présences est disponible dans la section 'Historique de Présences' du menu principal.",
    "Comment fonctionne l'emploi du temps?": "L'emploi du temps affiche vos cours programmés. Vous pouvez le consulter dans la section 'Mon Emploi du Temps'.",
    "Que faire si je suis sénateur?": "Si vous êtes sénateur, vous aurez accès à des fonctions supplémentaires pour gérer les présences des étudiants.",
    "Problème de connexion?": "Vérifiez votre connexion internet. Si le problème persiste, contactez le support technique de l'école.",
  };

  static List<String> getSuggestions(String query) {
    return faqQuestions.keys.where((question) {
      return question.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  static String getAnswer(String question) {
    return faqQuestions[question] ?? "Désolé, je n'ai pas de réponse à cette question. Contactez le support pour plus d'aide.";
  }
}

class FAQChatBotPopup extends StatefulWidget {
  const FAQChatBotPopup({super.key});

  @override
  State<FAQChatBotPopup> createState() => _FAQChatBotPopupState();
}

class _FAQChatBotPopupState extends State<FAQChatBotPopup> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> messages = [];
  List<String> suggestions = [];

  @override
  void initState() {
    super.initState();
    // Message de bienvenue initial
    messages.add({
      'sender': 'bot',
      'text': 'Bonjour! Je suis Eneambot, l\'assistant FAQ de l\'appli. Posez-moi vos questions sur le fonctionnement de l\'application.',
    });
    suggestions = FAQChatBot.faqQuestions.keys.toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_controller.text.isEmpty) return;

    final question = _controller.text;
    _controller.clear();

    // Ajouter la question de l'utilisateur
    setState(() {
      messages.add({
        'sender': 'user',
        'text': question,
      });
    });

    // Simuler un délai de réponse
    Future.delayed(const Duration(milliseconds: 500), () {
      final answer = FAQChatBot.getAnswer(question);
      setState(() {
        messages.add({
          'sender': 'bot',
          'text': answer,
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        children: [
          // Header du chat
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF0D147F),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.help_outline, color: Colors.white),
                const SizedBox(width: 10),
                const Text(
                  'FAQ Assistant',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Messages
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return Align(
                  alignment: message['sender'] == 'user'
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: message['sender'] == 'user'
                          ? const Color(0xFF0D147F).withOpacity(0.8)
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      message['text']!,
                      style: TextStyle(
                        color: message['sender'] == 'user'
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Suggestions
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8),
                  child: ActionChip(
                    label: Text(suggestions[index]),
                    onPressed: () {
                      _controller.text = suggestions[index];
                      _sendMessage();
                    },
                    backgroundColor: const Color(0xFF0D147F).withOpacity(0.1),
                  ),
                );
              },
            ),
          ),

          // Champ de saisie
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Posez votre question...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color(0xFF0D147F),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
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