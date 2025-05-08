// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants/routes.dart';
import 'package:flutter_application_1/services/auth/auth_service.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State <VerifyEmailView> createState() =>  VerifyEmailViewState();
}

class  VerifyEmailViewState extends State <VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
   return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 249, 248),
      appBar:AppBar(
          title: const Text("Vérifier l'e-mail" ,style: TextStyle(color: Color.fromARGB(255, 239, 240, 240),),),
          backgroundColor: const Color.fromARGB(255, 246, 131, 97),
          ),
      body: SingleChildScrollView( 
          padding: const EdgeInsets.all(24.0),
          child : Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children : [
              const Icon(Icons.email_outlined, size: 100, color:  Color.fromARGB(255, 246, 131, 97),),
              const SizedBox(height: 24),
              Text("Nous vous avons envoyé un email de vérification.",style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
              const SizedBox(height: 12),
              const Text("Veuillez l'ouvrir pour vérifier votre compte.",textAlign: TextAlign.center,),
              const SizedBox(height: 20),
              const SizedBox(height: 30),
              const Text ("Si vous n'avez pas encore reçu l'email de vérification, appuyez sur le bouton ci-dessous.",textAlign: TextAlign.center,),
              const SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed: () async { AuthService.firebase().sendEmailVerification();},
                icon: const Icon(Icons.send),
                label: const Text("Renvoyer l'e-mail de vérification"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 246, 131, 97),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                
              ),
              const SizedBox(height: 20),
                
              TextButton(onPressed: () async {
                await AuthService.firebase().logOut();
                Navigator.of(context).pushNamedAndRemoveUntil(registerRoute, (route)=> false,);
              }, child: const Text('Redémarrer',style: TextStyle(color: Colors.deepOrange),),),
            ],
          ),
   ),
   );
  }
}