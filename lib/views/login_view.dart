// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants/routes.dart';
import 'package:flutter_application_1/services/auth/auth_exceptions.dart';
import 'package:flutter_application_1/services/auth/auth_service.dart';
import 'package:flutter_application_1/utilities/show_error_dialog.dart';
import 'package:flutter_application_1/utilities/build_text_field.dart';




class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {

  late final TextEditingController _email;
  late final TextEditingController _password;
  
  @override
  void initState() {

    _email= TextEditingController();
    _password=TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
   
      return Scaffold(
        backgroundColor: const Color.fromARGB(255, 250, 249, 248),
        appBar :AppBar(
          title: const Text("Login",style: TextStyle(color: Color.fromARGB(255, 255, 255, 255),fontWeight: FontWeight.bold,),),
          backgroundColor: const Color.fromARGB(255, 246, 131, 97), // Ensures contrast with status bar
          ),
        body: SingleChildScrollView(
                child: Padding (
                  padding : const EdgeInsets.all(20.0),
                  child : Column (
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                          const SizedBox(height: 20),
                          Center(
                            child: Image.asset(
                              'assets/icon/icon_no_bg.png',
                              height: 180, // ajustez la hauteur selon vos besoins
                             ),
                          ),
                          const SizedBox(height: 30),
                          CustomTextField(controller: _email,hint: "Email",icon: Icons.email,keyboardType: TextInputType.emailAddress),
                          const SizedBox(height: 20),
                          CustomTextField(controller:_password, hint :"Entrez un mot de passe solide", icon :Icons.lock, obscureText: true),
                    const SizedBox(height: 40),
                
                ElevatedButton(
                  onPressed:() async {
                  final email=_email.text;
                  final password=_password.text;
                  try {
                    await AuthService.firebase().logIn(email: email, password: password,);
                    final user=AuthService.firebase().currentUser;
                    if (user?.isEmailVerified ?? false)
                    {
                      Navigator.of(context).pushNamedAndRemoveUntil(mainRoute, (route)=>false,);

                    }
                    else
                    {
                      Navigator.of(context).pushNamedAndRemoveUntil(verifyEmailRoute, (route)=>false,);

                    }
                  } on InvalidCredentialException{
                    await showErrorDialog(context, 'Utilisateur non trouvé, Veuillez vérifier vos informations',);
                  } on GenericAuthException{
                    await showErrorDialog (context, "Erreur d'authentification !",);
                  }

                }, style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 246, 131, 97),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
              ),
            ),
                child: const Text("Connexion",style: TextStyle(fontSize: 18, color: Colors.white,),
            ),
          ),
          const SizedBox(height: 20),
          Center (
            child: TextButton(onPressed: () {Navigator.of(context).pushNamedAndRemoveUntil(registerRoute,(route)=>false);},child: RichText(
                  text: TextSpan(
                  style: TextStyle(
                  color: Color.fromARGB(255, 246, 131, 97),
                  fontSize: 16,
                  ),
                  children: [
                    const TextSpan(text: "Pas encore inscrit ? "),
                    TextSpan(
                    text: "Inscrivez-vous ici !",
                    style: const TextStyle(fontWeight: FontWeight.bold),),
                ],
              ),
            ),
          ),
        )  
      ],
    ),
  ),),
);
  }
}


