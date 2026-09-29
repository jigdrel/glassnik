import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../services/user_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    super.key,
    required this.initialUsername,
    required this.initialBio,
    this.initialDisplayName,
    this.initialPhotoUrl,
    this.imagePicker,
  });

  final String initialUsername;
  final String initialBio;
  final String? initialDisplayName;
  final String? initialPhotoUrl;
  final ImagePicker? imagePicker;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  final StorageService _storageService = StorageService();

  late final TextEditingController _displayNameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _bioController;

  late final ImagePicker _imagePicker;

  // A newly-picked photo not yet uploaded/saved.
  Uint8List? _pendingPhotoBytes;

  // The photo already saved on the account (from Firestore), shown
  // until the user picks a new one or removes it.
  String? _existingPhotoUrl;
  bool _photoRemoved = false;

  bool _pickingPhoto = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _imagePicker = widget.imagePicker ?? ImagePicker();

    _existingPhotoUrl = widget.initialPhotoUrl;

    _displayNameController = TextEditingController(
      text: widget.initialDisplayName ?? '',
    );

    _usernameController = TextEditingController(text: widget.initialUsername);

    _bioController = TextEditingController(text: widget.initialBio);
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
    if (_pickingPhoto || _saving) return;
    setState(() => _pickingPhoto = true);
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image == null) {
        return;
      }

      final imageBytes = await image.readAsBytes();

      if (!mounted) {
        return;
      }

      setState(() {
        _pendingPhotoBytes = imageBytes;
        _photoRemoved = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not select profile photo.')),
      );
    } finally {
      if (mounted) setState(() => _pickingPhoto = false);
    }
  }

  void _removePhoto() {
    setState(() {
      _pendingPhotoBytes = null;
      _existingPhotoUrl = null;
      _photoRemoved = true;
    });
  }

  // ==========================================================
  // SAVE PROFILE
  // ==========================================================

  Future<void> _saveProfile() async {
    if (_pickingPhoto || _saving) return;
    final displayName = _displayNameController.text.trim();

    String username = _usernameController.text.trim();

    final bio = _bioController.text.trim();

    if (displayName.characters.length < 2) {
      _showMessage('Display name must contain at least 2 characters.');
      return;
    }

    if (!RegExp(r'^@?[A-Za-z0-9_]{3,20}$').hasMatch(username)) {
      _showMessage(
        'Username must be 3–20 characters: letters, numbers or underscores only (optional @). No spaces.',
      );
      return;
    }

    if (!username.startsWith('@')) {
      username = '@$username';
    }

    if (bio.characters.length > 120) {
      _showMessage('Bio must be 120 characters or less.');
      return;
    }

    final uid = _authService.currentUser?.uid;
    if (uid == null) {
      _showMessage('You are not signed in.');
      return;
    }

    setState(() => _saving = true);

    try {
      String? photoUrl = _existingPhotoUrl;

      if (_pendingPhotoBytes != null) {
        photoUrl = await _storageService.uploadProfilePhoto(
          uid: uid,
          imageBytes: _pendingPhotoBytes!,
        );
      }

      await _userService.updateProfile(
        uid: uid,
        displayName: displayName,
        username: username,
        bio: bio,
        photoUrl: photoUrl,
        removePhoto: _photoRemoved && _pendingPhotoBytes == null,
      );
    } on UsernameTakenException {
      if (mounted) {
        _showMessage('That username is already taken.');
      }
      return;
    } catch (error) {
      if (mounted) {
        _showMessage('Could not save your profile: $error');
      }
      return;
    } finally {
      if (mounted) setState(() => _saving = false);
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile saved.'),
        duration: Duration(seconds: 2),
      ),
    );
    Navigator.pop(context);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // ==========================================================
  // UI
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final hasPhoto = _pendingPhotoBytes != null ||
        (_existingPhotoUrl != null && !_photoRemoved);

    return PopScope(
      canPop: !_saving,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,

        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          centerTitle: true,

          title: Text(
            'Edit Profile',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),

          actions: [
            TextButton(
              onPressed: _pickingPhoto || _saving ? null : _saveProfile,
              child: Text(
                _saving ? 'Saving…' : 'Save',
                style: const TextStyle(
                  color: Color(0xFF6C63FF),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),

        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 35),

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
                      color: const Color(0xFF6C63FF),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant,
                        width: 2,
                      ),
                    ),

                    child: ClipOval(
                      child: _pendingPhotoBytes != null
                          ? Image.memory(
                              _pendingPhotoBytes!,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            )
                          : (hasPhoto && _existingPhotoUrl != null)
                              ? Image.network(
                                  _existingPhotoUrl!,
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
                      onTap: _pickingPhoto || _saving
                          ? null
                          : _changeProfilePhoto,

                      child: Container(
                        width: 34,
                        height: 34,

                        decoration: const BoxDecoration(
                          color: Color(0xFF6C63FF),
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
                onPressed: _pickingPhoto || _saving
                    ? null
                    : _changeProfilePhoto,

                child: const Text(
                  'Change profile photo',
                  style: TextStyle(
                    color: Color(0xFF6C63FF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              if (hasPhoto)
                TextButton(
                  onPressed: _pickingPhoto || _saving ? null : _removePhoto,
                  child: const Text('Remove Photo'),
                ),
              Text(
                'Photo changes apply when you save.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 24),

              // ==================================================
              // DISPLAY NAME
              // ==================================================
              _buildTextField(
                controller: _displayNameController,
                label: 'Display Name',
                hint: 'Enter your name',
                icon: Icons.badge_outlined,
              ),

              const SizedBox(height: 18),

              // ==================================================
              // USERNAME
              // ==================================================
              _buildTextField(
                controller: _usernameController,
                label: 'Username',
                hint: '@username',
                icon: Icons.alternate_email,
              ),

              const SizedBox(height: 18),

              // ==================================================
              // BIO
              // ==================================================
              _buildTextField(
                controller: _bioController,
                label: 'Bio',
                hint: 'Tell people about yourself...',
                icon: Icons.description_outlined,
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
                  onPressed: _pickingPhoto || _saving ? null : _saveProfile,

                  icon: const Icon(Icons.check),

                  label: Text(
                    _saving ? 'Saving…' : 'Save Changes',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    foregroundColor: Colors.white,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              TextButton(
                onPressed: _saving ? null : () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              const SizedBox(height: 18),

              Text(
                'Changes are saved to your account.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ],
          ),
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
      enabled: !_saving,
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,

      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),

      decoration: InputDecoration(
        labelText: label,
        hintText: hint,

        labelStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),

        hintStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),

        prefixIcon: Icon(icon, color: const Color(0xFF6C63FF)),

        filled: true,

        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
        ),
      ),
    );
  }
}