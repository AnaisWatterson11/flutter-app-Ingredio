import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/auth/firebase_auth_provider.dart';
import 'package:flutter_application_1/utilities/show_error_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final FirebaseAuthProvider _authProvider = FirebaseAuthProvider();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
}


  Future<void> _loadUserProfile() async {
    try {
      final snapshot = await _authProvider.getUserFirestoreData();
      final data = snapshot.data();
      if (data != null) {
        setState(() {
          _nameController.text = data['prenom'] ?? '';
          _heightController.text = (data['taille'] ?? '').toString();
          _weightController.text = (data['poids'] ?? '').toString();
        });
      }
    } catch (e) {
        showErrorDialog(context, "Erreur lors du chargement du Profile");
    }
}

  Future<void> _pickImage() async {
    var status = await Permission.photos.request(); // Pour API 33+
    if (!status.isGranted) {
      status = await Permission.storage.request(); // Pour API <= 32
    }

    if (status.isGranted) {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        setState(() {
          _profileImage = File(picked.path);
        });
      }
    } else {
        showErrorDialog(context, "Permission refusée. Impossible d'accéder à la galerie.");
    }
  }

  void _saveProfile() async {
    final name = _nameController.text.trim();
    final heightText = _heightController.text.trim();
    final weightText = _weightController.text.trim();

    if (name.isEmpty || heightText.isEmpty || weightText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Merci de remplir tous les champs.")),
      );
      return;
    }

    try {
      final height = int.parse(heightText);
      final weight = int.parse(weightText);
      String? imageUrl;

      // Si une nouvelle image est sélectionnée
    if (_profileImage != null) {
      final fileName = '${_authProvider.currentUser!.uid}_profile.jpg';
      final ref = FirebaseStorage.instance.ref().child('profile_images/$fileName');
      await ref.putFile(_profileImage!);
      imageUrl = await ref.getDownloadURL();
    }

      await _authProvider.updateUserProfile(
      prenom: name,
      taille: height,
      poids: weight,
      imageUrl: imageUrl,
    );
      showDialogMessage(context,  "Profil mis à jour avec succès !");
    }catch (e) {
      showErrorDialog(context, "Erreur lors de la mise à jour : $e");
  }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
       title: Row(
        children: const [Icon(Icons.person, color: Color.fromARGB(255, 239, 240, 240)),SizedBox(width: 8), Text("Mon Profil", style: TextStyle(color: Color.fromARGB(255, 239, 240, 240),fontWeight: FontWeight.bold,),)],
),
        backgroundColor: const Color.fromARGB(255, 243, 127, 85),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 70,
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!)
                      : const AssetImage('assets/Bonhomme.png') as ImageProvider,
                  child: _profileImage == null
                      ? const Icon(Icons.camera_alt, color: Colors.white, size: 30)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text("📝 Modifier les informations :", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Prénom",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _heightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Taille (cm)",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.height),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Poids (kg)",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.monitor_weight),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                onPressed: _saveProfile,
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Text("Enregistrer"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
