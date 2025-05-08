// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants/routes.dart';
import 'package:flutter_application_1/services/auth/auth_service.dart';
import 'package:flutter_application_1/services/auth/firebase_auth_provider.dart';

enum MenuAction { manageProfile, logout, about, fav }

class MainUi extends StatefulWidget {
  const MainUi({super.key});

  @override
  State<MainUi> createState() => _MainUiState();
}

class _MainUiState extends State<MainUi> {
  late final FirebaseAuthProvider _authProvider;
  String get userEmail => AuthService.firebase().currentUser!.email!;

  @override
  void initState() {
    _authProvider = FirebaseAuthProvider();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 250, 250),
      appBar: AppBar(
        title: const Text(
          "Ingredio",
          style: TextStyle(
            color: Color.fromARGB(255, 239, 240, 240),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 243, 127, 85),
        actions: [
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.manageProfile:
                  Navigator.of(context).pushNamed(gestionProfileRoute);
                  break;
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                    await AuthService.firebase().logOut();
                    Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (route) => false);
                  }
                  break;
                case MenuAction.about:
                  Navigator.of(context).pushNamed(aproposRoute);
                  break;
                case MenuAction.fav:
                  Navigator.of(context).pushNamed(favorisRoute);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem<MenuAction>(value: MenuAction.about, child: Text("À propos")),
              PopupMenuItem<MenuAction>(value: MenuAction.manageProfile, child: Text("Gérer mon profil")),
              PopupMenuItem<MenuAction>(value: MenuAction.fav, child: Text("Voir mes recettes favorites")),
              PopupMenuItem<MenuAction>(value: MenuAction.logout, child: Text("Se déconnecter")),
            ],
          )
        ],
      ),
      body: FutureBuilder(
        future: _authProvider.getUserFirestoreData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              if (snapshot.hasData) {
                final userData = snapshot.data;

                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 251, 249, 249),
                        Color.fromARGB(255, 250, 250, 250),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: SizedBox.expand(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 20),
                            Image.asset(
                              'assets/icon/icon_no_bg.png',
                              width: 250,
                              height: 250,
                            ),
                            const SizedBox(height: 20),
                            Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 6,
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  children: [
                                    Text(
                                      'Bienvenue ${userData!['prenom']} 👋',
                                      style: const TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(255, 87, 72, 72),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 20),
                                    const Text(
                                      'Maison de +5500 recettes 🍽️\nLaissez-vous inspirer !',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Color.fromARGB(255, 220, 118, 22),
                                        fontWeight: FontWeight.bold
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).pushNamed(recipeFinderRoute);
                              },
                              icon: const Icon(Icons.search),
                              label: const Text("Trouver une recette",style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(255, 249, 247, 247),
                                      ),),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepOrangeAccent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                minimumSize: const Size(double.infinity, 50),
                                elevation: 4,
                              ),
                            ),
                            const SizedBox(height: 30),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).pushNamed(chatRoute);
                              },
                              icon: const Icon(Icons.smart_toy),
                              label: const Text("Utiliser l'assistant vocal",style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(255, 254, 254, 254),
                                      ),),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(255, 55, 152, 97),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                minimumSize: const Size(double.infinity, 50),
                                elevation: 4,
                              ),
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              } else {
                return const Center(child: Text("Aucune donnée utilisateur trouvée."));
              }
            default:
              return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

Future<bool> showLogOutDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text("Voulez-vous vraiment vous déconnecter ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Déconnexion'),
          ),
        ],
      );
    },
  ).then((value) => value ?? false);
}
