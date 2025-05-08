
import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants/routes.dart';
import 'package:flutter_application_1/services/auth/auth_service.dart';
import 'package:flutter_application_1/services/chatbot/homepage_chat.dart';
import 'package:flutter_application_1/views/a_propos.dart';
import 'package:flutter_application_1/views/gestion_utilisateur.dart';
import 'package:flutter_application_1/views/login_view.dart';
import 'package:flutter_application_1/views/main_UI.dart';
import 'package:flutter_application_1/views/page_favoris.dart';
import 'package:flutter_application_1/views/recipe_finder.dart';
import 'package:flutter_application_1/views/register_view.dart';
import 'package:flutter_application_1/views/splash_screen.dart';
import 'package:flutter_application_1/views/verify_email_view.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
 

  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Colors.orange.shade50,
        useMaterial3: true,),
    home: const HomePage(), // 
    routes: {
      loginRoute: (context) => const LoginView(),
      registerRoute: (context) => const RegisterView(),
      mainRoute: (context) => const MainUi(),             //main UI
      verifyEmailRoute: (context) => const VerifyEmailView(),
      gestionProfileRoute: (context) => const UserProfilePage(),
      recipeFinderRoute : (context) => const RecipeFinderPage(),
      favorisRoute: (context) => const FavoritesPage(),
      aproposRoute : (context) => const AProposPage(),
      chatRoute : (context) => const HomePageChat(),
    },
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
        return FutureBuilder(
          future : AuthService.firebase().initialize(),
          builder :(context, snapshot) {
            switch (snapshot.connectionState){
              case ConnectionState.done:
                final user=AuthService.firebase().currentUser;
                if (user!= null) {
                  if (user.isEmailVerified) {
                    return const MainUi();
                  }  
                  else {
                    return const VerifyEmailView();
                  }
                }
                  else
                {
                  return const LoginView();
                }
          
                 
              default:
                return const SplashLoadingScreen();
            }
            
            
          }, 
        
        );
  }

}














  
