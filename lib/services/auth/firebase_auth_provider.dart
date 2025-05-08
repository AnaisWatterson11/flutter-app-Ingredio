import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/firebase_options.dart';
import 'package:flutter_application_1/services/auth/auth_exceptions.dart';
import 'package:flutter_application_1/services/auth/auth_user.dart';
import 'package:flutter_application_1/services/auth/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, FirebaseAuthException;

class FirebaseAuthProvider implements AuthProvider{
  // --- Singleton Implementation ---
  static final FirebaseAuthProvider _instance = FirebaseAuthProvider._internal();

  factory FirebaseAuthProvider() {
    return _instance;
  }

  FirebaseAuthProvider._internal();


  @override
  Future<void> initialize() async {
    await Firebase.initializeApp(options : DefaultFirebaseOptions.currentPlatform,);
  }


  @override
Future<AuthUser> createUser({
  required String email,
  required String password,
  required String nom,
  required String prenom,
  required int taille,
  required int poids,
  String? imageUrl,
}) async {
  try {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = currentUser;
    if (user != null) {
      final userData = {
        'nom': nom,
        'prenom': prenom,
        'email': email,
        'taille': taille,
        'poids': poids,
        'favorites': <String>[],
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Only add imageUrl if it's not null or empty
      if (imageUrl != null && imageUrl.isNotEmpty) {
        userData['imageUrl'] = imageUrl;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(userData);

      return user;
    } else {
      throw UserNotLoggedInAuthException();
    }
  } on FirebaseAuthException catch (e) {
    if (e.code == 'weak-password') {
      throw WeakPasswordException();
    } else if (e.code == 'email-already-in-use') {
      throw EmailAlreadyInUseException();
    } else if (e.code == 'invalid-email') {
      throw InvalidEmailException();
    } else {
      throw GenericAuthException();
    }
  } catch (_) {
    throw GenericAuthException();
  }
}


  @override
  AuthUser? get currentUser {
    final user = FirebaseAuth.instance.currentUser;
    if (user!=null)
    {
      return AuthUser.fromFirebase(user);
    }
    else
    {
      return null;
    }
  }

  @override
  Future<AuthUser> logIn({required String email, required String password,}) async {
    try{
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password,);
      final user=currentUser;
      if (user!= null)
      {
        return user;
      }
      else
      {
        throw UserNotLoggedInAuthException();
      }


    } on FirebaseAuthException catch (e)
    {
      if (e.code=='invalid-credential')
      {
        throw InvalidCredentialException();
      }
      else
      {
        throw GenericAuthException();          
      }

    }catch (_)
    {
      throw GenericAuthException();
    }
    
  }

  @override
  Future<void> logOut() async {
    final user= FirebaseAuth.instance.currentUser;
    if (user!=null)
    {
      await FirebaseAuth.instance.signOut();
    }
    else
    {
      throw UserNotLoggedInAuthException();
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user!=null)
    {
      await user.sendEmailVerification();
    }
    else
    {
      throw UserNotLoggedInAuthException();
    }
    
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserFirestoreData() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    return await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  } else {
    throw UserNotLoggedInAuthException();
  }
}

Future<List<String>> getFavorites() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final data = doc.data();
      if (data != null && data['favorites'] is List) {
        return List<String>.from(data['favorites']);
      } else {
        return []; // Aucun favori trouvé
      }
    } catch (e) {
      throw Exception("Erreur lors de la récupération des favoris : $e");
    }
  } else {
    throw UserNotLoggedInAuthException();
  }
}


Future<void> updateUserProfile({required String prenom,required int taille,required int poids, String? imageUrl}) async {
   final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    try {
      final Map<String, dynamic> updateData = {
        'prenom': prenom,
        'taille': taille,
        'poids': poids,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (imageUrl != null && imageUrl.isNotEmpty) {
        updateData['imageUrl'] = imageUrl;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(updateData, SetOptions(merge: true));
    } catch (e) {
      throw Exception("Erreur lors de la mise à jour du profil : $e");
    }
  } else {
    throw UserNotLoggedInAuthException();
  }
}

Future<void> addFavorite(String recipeId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

        // Ajout du recetteId aux favoris
        await userDocRef.update({
          'favorites': FieldValue.arrayUnion([recipeId]),
        });
      } catch (e) {
        throw Exception("Erreur lors de l'ajout aux favoris : $e");
      }
    } else {
      throw UserNotLoggedInAuthException();
    }
  }



Future<void> removeFavorite(String recipeId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

        // Retirer le recetteId des favoris
        await userDocRef.update({
          'favorites': FieldValue.arrayRemove([recipeId]),
        });
      } catch (e) {
        throw Exception("Erreur lors du retrait des favoris : $e");
      }
    } else {
      throw UserNotLoggedInAuthException();
    }
  }


}