import 'package:flutter_application_1/services/auth/auth_provider.dart';
import 'package:flutter_application_1/services/auth/auth_user.dart';
import 'package:flutter_application_1/services/auth/firebase_auth_provider.dart';

class AuthService  implements AuthProvider{
  final AuthProvider provider;
  const AuthService(this.provider);
  factory AuthService.firebase()=> AuthService(FirebaseAuthProvider());
  
  @override
  Future<void> initialize() => provider.initialize();
  
  
  @override
  Future<AuthUser> createUser({required String email, required String password,required String nom, required String prenom, required int taille, required int poids, String? imageUrl}) => provider.createUser(email:email, password:password, nom:nom, prenom:prenom, taille: taille, poids: poids,imageUrl: imageUrl,);
  
  @override
 AuthUser? get currentUser => provider.currentUser;
  
  @override
  Future<AuthUser> logIn({required String email, required String password,}) => provider.logIn(email: email, password: password,);
  
  @override
  Future<void> logOut()=> provider.logOut();
  
  @override
  Future<void> sendEmailVerification() => provider.sendEmailVerification();
  
  
}