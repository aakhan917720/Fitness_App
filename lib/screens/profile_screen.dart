import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/fitness_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController(text: 'Fitness Warrior');
  final _ageController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  String? _profileImageUrl;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    final provider = context.read<FitnessProvider>();
    _ageController.text = provider.userStats.age.toString();
    _loadProfileImage();
  }

  void _loadProfileImage() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('profileImageUrl')) {
          setState(() {
            _profileImageUrl = data['profileImageUrl'];
          });
        }
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (pickedFile == null) return;

      setState(() {
        _selectedImage = File(pickedFile.path);
        _isUploading = true;
      });

      await _uploadImage();
    } catch (e) {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;

    int retryCount = 0;
    const maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        User? user = FirebaseAuth.instance.currentUser;
        if (user == null) throw Exception('User not logged in');

        int fileSize = await _selectedImage!.length();
        if (fileSize > 5 * 1024 * 1024) {
          throw Exception('Image too large. Max 5MB allowed.');
        }

        if (_profileImageUrl != null) {
          try {
            Reference oldRef = FirebaseStorage.instance.refFromURL(_profileImageUrl!);
            await oldRef.delete();
          } catch (e) {
            print('Old image delete error: $e');
          }
        }

        String fileName = 'profile_${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        Reference ref = FirebaseStorage.instance
            .ref()
            .child('profile_images')
            .child(user.uid)
            .child(fileName);

        SettableMetadata metadata = SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'userId': user.uid,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        );

        UploadTask uploadTask = ref.putFile(_selectedImage!, metadata);
        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'profileImageUrl': downloadUrl});

        setState(() {
          _profileImageUrl = downloadUrl;
          _isUploading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated!'), backgroundColor: Colors.green),
        );
        return;

      } on FirebaseException catch (e) {
        retryCount++;
        if (retryCount >= maxRetries) {
          setState(() => _isUploading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Upload failed: ${e.message}'), backgroundColor: Colors.red),
          );
        } else {
          await Future.delayed(Duration(seconds: retryCount * 2));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), centerTitle: true),
      body: Consumer<FitnessProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildProfileHeader(),
                const SizedBox(height: 32),
                _buildInfoCard(
                  'Personal Information',
                  [
                    _buildTextField('Name', _nameController, Icons.person),
                    const SizedBox(height: 16),
                    _buildTextField('Age', _ageController, Icons.cake, TextInputType.number),
                    const SizedBox(height: 16),
                    _buildGenderSelector(provider),
                  ],
                ),
                const SizedBox(height: 24),
                _buildInfoCard(
                  'Body Stats',
                  [
                    _buildStatRow('Weight', '${provider.userStats.weight} kg'),
                    const Divider(),
                    _buildStatRow('Height', '${provider.userStats.height} cm'),
                    const Divider(),
                    _buildStatRow('BMI', provider.userStats.bmi.toStringAsFixed(1)),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final age = int.tryParse(_ageController.text);
                      provider.updateUserStats(age: age); // Updated with correct handling
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Profile updated!')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Save Changes'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          children: [
            GestureDetector(
              onTap: _isUploading ? null : _pickImage,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF6C63FF).withOpacity(0.1),
                  border: Border.all(color: const Color(0xFF6C63FF), width: 3),
                  image: _selectedImage != null
                      ? DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.cover)
                      : _profileImageUrl != null
                      ? DecorationImage(image: NetworkImage(_profileImageUrl!), fit: BoxFit.cover)
                      : null,
                ),
                child: _selectedImage == null && _profileImageUrl == null
                    ? const Icon(Icons.person, size: 60, color: Color(0xFF6C63FF))
                    : null,
              ),
            ),
            if (_isUploading)
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black54),
                  child: const Center(child: CircularProgressIndicator(color: Colors.white)),
                ),
              ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _isUploading ? null : _pickImage,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: Color(0xFF6C63FF), shape: BoxShape.circle),
                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(_nameController.text, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('Fitness Enthusiast', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: _isUploading ? null : _pickImage,
          icon: const Icon(Icons.photo_library, size: 18),
          label: const Text('Change Photo'),
          style: TextButton.styleFrom(foregroundColor: const Color(0xFF6C63FF)),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, [TextInputType? type]) {
    return TextField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildGenderSelector(FitnessProvider provider) {
    return Row(
      children: [
        Expanded(
          child: ChoiceChip(
            label: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Icon(Icons.male, size: 18), SizedBox(width: 4), Text('Male')],
            ),
            selected: provider.userStats.gender == 'Male',
            onSelected: (selected) {
              if (selected) provider.updateUserStats(gender: 'Male');
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ChoiceChip(
            label: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Icon(Icons.female, size: 18), SizedBox(width: 4), Text('Female')],
            ),
            selected: provider.userStats.gender == 'Female',
            onSelected: (selected) {
              if (selected) provider.updateUserStats(gender: 'Female');
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}