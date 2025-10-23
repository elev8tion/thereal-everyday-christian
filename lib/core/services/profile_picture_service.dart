import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;

/// Service to manage user profile picture
class ProfilePictureService {
  static const String _profilePictureKey = 'profile_picture_path';
  final ImagePicker _picker = ImagePicker();

  /// Get the current profile picture path
  Future<String?> getProfilePicturePath() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_profilePictureKey);
    } catch (e) {
      debugPrint('Error getting profile picture path: $e');
      return null;
    }
  }

  /// Pick image from gallery
  Future<String?> pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        return await _saveProfilePicture(image);
      }
      return null;
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
      return null;
    }
  }

  /// Take photo with camera
  Future<String?> takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        return await _saveProfilePicture(image);
      }
      return null;
    } catch (e) {
      debugPrint('Error taking photo: $e');
      return null;
    }
  }

  /// Save profile picture to app directory
  Future<String?> _saveProfilePicture(XFile image) async {
    try {
      // Get app documents directory
      final appDir = await getApplicationDocumentsDirectory();
      final profileDir = Directory('${appDir.path}/profile');

      // Create profile directory if it doesn't exist
      if (!await profileDir.exists()) {
        await profileDir.create(recursive: true);
      }

      // Delete old profile picture if exists
      final oldPath = await getProfilePicturePath();
      if (oldPath != null) {
        final oldFile = File(oldPath);
        if (await oldFile.exists()) {
          await oldFile.delete();
        }
      }

      // Generate new filename with timestamp
      final extension = path.extension(image.path);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final newPath = '${profileDir.path}/profile_$timestamp$extension';

      // Copy image to app directory
      final File newFile = await File(image.path).copy(newPath);

      // Save path to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_profilePictureKey, newFile.path);

      return newFile.path;
    } catch (e) {
      debugPrint('Error saving profile picture: $e');
      return null;
    }
  }

  /// Remove profile picture
  Future<bool> removeProfilePicture() async {
    try {
      final picturePath = await getProfilePicturePath();
      if (picturePath != null) {
        final file = File(picturePath);
        if (await file.exists()) {
          await file.delete();
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_profilePictureKey);
      }
      return true;
    } catch (e) {
      debugPrint('Error removing profile picture: $e');
      return false;
    }
  }

  /// Check if profile picture exists
  Future<bool> hasProfilePicture() async {
    final picturePath = await getProfilePicturePath();
    if (picturePath == null) return false;

    final file = File(picturePath);
    return await file.exists();
  }
}
