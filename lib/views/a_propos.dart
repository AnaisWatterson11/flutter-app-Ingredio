import 'package:flutter/material.dart';

class AProposPage extends StatefulWidget {
  const AProposPage({super.key});

  @override
  State<AProposPage> createState() => _AProposPageState();
}

class _AProposPageState extends State<AProposPage> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<Offset>> _slideAnimations;
  late List<Animation<double>> _fadeAnimations;

  final List<Map<String, dynamic>> _features = [
    {
      'icon': Icons.search,
      'title': 'Recherche par ingrédients',
      'description': 'Entrez ce que vous avez dans votre cuisine et découvrez des recettes adaptées.',
    },
    {
      'icon': Icons.local_dining,
      'title': 'Modes alimentaires',
      'description': 'Sans gluten, végétarien, sans sucre, perte de poids, etc.',
    },
    {
      'icon': Icons.category,
      'title': 'Filtrage par catégorie',
      'description': 'Choisissez parmi : plat, dessert, entrée ou autre.',
    },
    {
      'icon': Icons.mic,
      'title': 'Assistance vocale',
      'description': 'Interagissez vocalement avec les recettes en activant le mode mains libres.',
    },
    {
      'icon': Icons.chat_bubble_outline,
      'title': 'Chatbot intelligent',
      'description': 'Posez vos questions et recevez de l’aide personnalisée.',
    },
  ];

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(_features.length, (index) {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      );
    });

    _slideAnimations = _controllers.map((controller) {
      return Tween<Offset>(
        begin: const Offset(0, 0.2),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeOut,
      ));
    }).toList();

    _fadeAnimations = _controllers.map((controller) {
      return Tween<double>(
        begin: 0,
        end: 1,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeIn,
      ));
    }).toList();

    _startAnimations();
  }

  Future<void> _startAnimations() async {
    for (int i = 0; i < _controllers.length; i++) {
      await Future.delayed(const Duration(milliseconds: 200));
      _controllers[i].forward();
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBFA),
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF68D5F), Color(0xFFF6A385)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'À propos de l’application',
          style: TextStyle(color: Color.fromARGB(255, 239, 240, 240),fontWeight: FontWeight.bold,),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Icon(Icons.restaurant_menu, size: 90, color: Color(0xFFF68D5F)),
            const SizedBox(height: 15),
            const Text(
              'Votre assistant culinaire Ingredio',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: _features.length,
              itemBuilder: (context, i) {
                return SlideTransition(
                  position: _slideAnimations[i],
                  child: FadeTransition(
                    opacity: _fadeAnimations[i],
                    child: _buildFeatureCard(
                      icon: _features[i]['icon'],
                      title: _features[i]['title'],
                      description: _features[i]['description'],
                    ),
                  ),
                );
              },
            ),
            
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(2, 4),
          )
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: const Color(0xFFF68D5F).withOpacity(0.15),
          child: Icon(icon, color: const Color(0xFFF68D5F), size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(description),
        ),
      ),
    );
  }
}
