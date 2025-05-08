import 'package:flutter_application_1/services/auth/auth_user.dart';

abstract class AuthProvider{
  Future<void>initialize();
  AuthUser? get currentUser;

  Future<AuthUser> logIn({
    required String email,
    required String password,
  });

  Future<AuthUser> createUser({
    required String email,
    required String password,
    required String nom,
    required String prenom,
    required int taille,
    required int poids,
    String? imageUrl,
  });

  Future<void> logOut();
  Future<void> sendEmailVerification();

}