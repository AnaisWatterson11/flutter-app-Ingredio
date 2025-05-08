// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/auth/auth_exceptions.dart';
import 'package:flutter_application_1/services/auth/auth_service.dart';
import 'package:flutter_application_1/utilities/show_error_dialog.dart';
import 'package:flutter_application_1/constants/routes.dart';
import 'package:flutter_application_1/utilities/build_text_field.dart';



class RegisterView extends StatefulWidget {
  const RegisterView({super.key});


  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  late final TextEditingController _nom;
  late final TextEditingController _prenom;
  late final TextEditingController _taille;
  late final TextEditingController _poids;
  
  @override
  void initState() {

    _email= TextEditingController();
    _password=TextEditingController();
    _nom= TextEditingController();
    _prenom=TextEditingController();
    _taille= TextEditingController();
    _poids=TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _nom.dispose();
    _prenom.dispose();
    _taille.dispose();
    _poids.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
      return Scaffold(
          backgroundColor: const Color.fromARGB(255, 250, 249, 248),
          appBar: AppBar(
          title: const Text("Inscription",style: TextStyle(color: Color.fromARGB(255, 239, 240, 240),fontWeight: FontWeight.bold,),),
          backgroundColor: const Color.fromARGB(255, 246, 131, 97), // Ensures contrast with status bar
          ),
          body: SingleChildScrollView(
                child: Padding (
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: Image.asset(
                              'assets/icon/icon_no_bg.png',
                              height: 130, 
                             ),
                          ),
                          const SizedBox(height: 30),
                          CustomTextField(controller: _nom,hint: "Entrez votre nom",icon: Icons.person,),
                          const SizedBox(height: 20),
                          CustomTextField(controller: _prenom, hint:"Entrez votre prénom", icon :Icons.person_outline),
                          const SizedBox(height: 20),
                          CustomTextField(controller:_email,hint : "Email", icon :Icons.email, keyboardType: TextInputType.emailAddress),
                          const SizedBox(height: 20),
                          CustomTextField(controller:_password, hint :"Entrez un mot de passe solide", icon :Icons.lock, obscureText: true),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right:10),
                                  child: CustomTextField(
                                    controller: _taille,
                                    hint:"Taille en cm",
                                    icon:Icons.height,
                                    keyboardType: TextInputType.number
                                    ),
                                  ),
                                ),
                                Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left:10),
                                  child: CustomTextField(
                                    controller: _poids,
                                    hint:"Poids en Kg",
                                    icon:Icons.line_weight,
                                    keyboardType: TextInputType.number
                                    ),
                                  ),
                                ),

                            ],
                          ),
                        const SizedBox(height: 40),

                
                ElevatedButton(
                  onPressed: () async {
                  final email = _email.text;
                  final password = _password.text;
                  final nom=_nom.text;
                  final prenom= _prenom.text;
                  final taille = int.tryParse(_taille.text) ?? 0;  
                  final poids = int.tryParse(_poids.text) ?? 0;  
                  try {
                    await AuthService.firebase().createUser(email: email, password: password,nom: nom, prenom:prenom, taille:taille, poids: poids);
                    AuthService.firebase().sendEmailVerification();
                    Navigator.of(context).pushNamed(verifyEmailRoute);
                  } on WeakPasswordException {
                    await showErrorDialog(context, 'Mot de passe faible');
                  } on EmailAlreadyInUseException {
                    await showErrorDialog(context, 'Email déjà utilisé ! Choisissez-en un autre.');
                  } on InvalidEmailException {
                    await showErrorDialog(context, 'Email invalide !');
                  } on GenericAuthException {
                    await showErrorDialog(context, 'Inscription échouée !');
                  }
            },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 246, 131, 97),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
              ),
            ),
                child: const Text(
                  "S'inscrire",
                style: TextStyle(fontSize: 18, color: Colors.white,),
              
            ),
          ),

        const SizedBox(height: 20),

          Center(
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (route) => false);
              },
               child: RichText(
                  text: TextSpan(
                  style: TextStyle(
                  color: Color.fromARGB(255, 255, 87, 34),
                  fontSize: 16,
                  ),
                  children: [
                    const TextSpan(text: "Déjà inscrit ? "),
                    TextSpan(
                    text: "Connectez-vous ici !",
                    style: const TextStyle(fontWeight: FontWeight.bold),),
                ],
              ),
            ),
          ),
          ),
        ],
      ),
    ),
  ),
);
}}

