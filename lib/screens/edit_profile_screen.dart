import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/profile_store.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    super.key,
    required this.initialUsername,
    required this.initialBio,
  });

  final String initialUsername;
  final String initialBio;

  @override
  State<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _displayNameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _bioController;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();

    final currentProfile =
        ProfileStore.profile.value;

    _displayNameController =
        TextEditingController(
      text: currentProfile.displayName,
    );

    _usernameController =
        TextEditingController(
      text: widget.initialUsername,
    );

    _bioController =
        TextEditingController(
      text: widget.initialBio,
    );
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();

    super.dispose();
  }

  // ==========================================================
  // CHANGE PROFILE PHOTO
  // ==========================================================

  Future<void> _changeProfilePhoto() async {
    try {
      final XFile? image =
          await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image == null) {
        return;
      }

      final imageBytes =
          await image.readAsBytes();

      ProfileStore.updateProfileImage(
        imageBytes,
      );

      if (!mounted) {
        return;
      }

      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Profile photo updated.',
          ),
          duration: Duration(
            seconds: 1,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not select profile photo.',
          ),
        ),
      );
    }
  }

  // ==========================================================
  // SAVE PROFILE
  // ==========================================================

  void _saveProfile() {
    final displayName =
        _displayNameController.text.trim();

    String username =
        _usernameController.text.trim();

    final bio =
        _bioController.text.trim();

    if (displayName.isEmpty) {
      _showMessage(
        'Display name cannot be empty.',
      );
      return;
    }

    if (username.isEmpty) {
      _showMessage(
        'Username cannot be empty.',
      );
      return;
    }

    if (!username.startsWith('@')) {
      username = '@$username';
    }

    if (bio.length > 120) {
      _showMessage(
        'Bio must be 120 characters or less.',
      );
      return;
    }

    ProfileStore.updateProfile(
      displayName: displayName,
      username: username,
      bio: bio,
    );

    Navigator.pop(context);
  }

  void _showMessage(
    String message,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // ==========================================================
  // UI
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final profile =
        ProfileStore.profile.value;

    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,

        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text(
              'Save',
              style: TextStyle(
                color: Color(0xFF6C63FF),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          20,
          18,
          20,
          35,
        ),

        child: Column(
          children: [
            // ==================================================
            // PROFILE PHOTO
            // ==================================================

            Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,

                  decoration: BoxDecoration(
                    color: const Color(
                      0xFF6C63FF,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white24,
                      width: 2,
                    ),
                  ),

                  child: ClipOval(
                    child:
                        profile.profileImageBytes !=
                                null
                            ? Image.memory(
                                profile
                                    .profileImageBytes!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              )
                            : const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 58,
                              ),
                  ),
                ),

                Positioned(
                  right: 0,
                  bottom: 0,

                  child: GestureDetector(
                    onTap: _changeProfilePhoto,

                    child: Container(
                      width: 34,
                      height: 34,

                      decoration:
                          const BoxDecoration(
                        color:
                            Color(0xFF6C63FF),
                        shape: BoxShape.circle,
                      ),

                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            TextButton(
              onPressed: _changeProfilePhoto,

              child: const Text(
                'Change profile photo',
                style: TextStyle(
                  color: Color(0xFF6C63FF),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ==================================================
            // DISPLAY NAME
            // ==================================================

            _buildTextField(
              controller:
                  _displayNameController,
              label: 'Display Name',
              hint: 'Enter your name',
              icon: Icons.badge_outlined,
            ),

            const SizedBox(height: 18),

            // ==================================================
            // USERNAME
            // ==================================================

            _buildTextField(
              controller:
                  _usernameController,
              label: 'Username',
              hint: '@username',
              icon:
                  Icons.alternate_email,
            ),

            const SizedBox(height: 18),

            // ==================================================
            // BIO
            // ==================================================

            _buildTextField(
              controller:
                  _bioController,
              label: 'Bio',
              hint:
                  'Tell people about yourself...',
              icon:
                  Icons.description_outlined,
              maxLines: 4,
              maxLength: 120,
            ),

            const SizedBox(height: 28),

            // ==================================================
            // SAVE BUTTON
            // ==================================================

            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton.icon(
                onPressed: _saveProfile,

                icon: const Icon(
                  Icons.check,
                ),

                label: const Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(
                    0xFF6C63FF,
                  ),
                  foregroundColor:
                      Colors.white,

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      14,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'Profile information is stored locally for the current demo.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // TEXT FIELD
  // ==========================================================

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    int? maxLength,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,

      style: const TextStyle(
        color: Colors.white,
      ),

      decoration: InputDecoration(
        labelText: label,
        hintText: hint,

        labelStyle: const TextStyle(
          color: Colors.grey,
        ),

        hintStyle: const TextStyle(
          color: Colors.white38,
        ),

        prefixIcon: Icon(
          icon,
          color: const Color(
            0xFF6C63FF,
          ),
        ),

        filled: true,

        fillColor:
            const Color(
          0xFF1C1C1C,
        ),

        border:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            14,
          ),
          borderSide:
              BorderSide.none,
        ),

        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            14,
          ),
          borderSide:
              const BorderSide(
            color: Colors.white12,
          ),
        ),

        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            14,
          ),
          borderSide:
              const BorderSide(
            color: Color(
              0xFF6C63FF,
            ),
            width: 2,
          ),
        ),
      ),
    );
  }
}
