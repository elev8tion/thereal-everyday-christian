import 'dart:io';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';

class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  /// Check if device has biometric hardware
  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } on PlatformException catch (e) {
      debugPrint('❌ [BiometricService] Error checking device support: $e');
      return false;
    }
  }

  /// Check if biometrics are enrolled
  Future<bool> canCheckBiometrics() async {
    try {
      final isSupported = await isDeviceSupported();
      if (!isSupported) return false;

      final canCheck = await _localAuth.canCheckBiometrics;
      final isAvailable = canCheck || await _localAuth.isDeviceSupported();

      if (isAvailable) {
        final availableBiometrics = await _localAuth.getAvailableBiometrics();
        return availableBiometrics.isNotEmpty;
      }

      return false;
    } on PlatformException catch (e) {
      debugPrint('❌ [BiometricService] Error checking biometrics: $e');
      return false;
    }
  }

  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      debugPrint('❌ [BiometricService] Error getting biometric types: $e');
      return [];
    }
  }

  /// Authenticate with biometrics
  Future<bool> authenticate({
    required String reason,
    bool biometricOnly = false,
  }) async {
    try {
      final isAvailable = await canCheckBiometrics();
      if (!isAvailable) {
        debugPrint('⚠️ [BiometricService] Biometrics not available');
        return false;
      }

      return await _localAuth.authenticate(
        localizedReason: reason,
        authMessages: <AuthMessages>[
          AndroidAuthMessages(
            signInTitle: 'Unlock Everyday Christian',
            biometricHint: 'Verify your identity',
            biometricNotRecognized: 'Not recognized. Try again.',
            biometricSuccess: 'Success',
            cancelButton: 'Cancel',
            deviceCredentialsRequiredTitle: 'Device credentials required',
            deviceCredentialsSetupDescription: 'Please set up device credentials',
            goToSettingsButton: 'Go to settings',
            goToSettingsDescription: 'Biometric authentication is not set up on your device.',
          ),
          IOSAuthMessages(
            cancelButton: 'Cancel',
            goToSettingsButton: 'Go to settings',
            goToSettingsDescription: 'Biometric authentication is not set up on your device.',
            lockOut: 'Biometric authentication is locked. Please try again later.',
          ),
        ],
        options: AuthenticationOptions(
          biometricOnly: biometricOnly,
          stickyAuth: true, // Keep auth dialog up until success
          useErrorDialogs: true,
        ),
      );
    } on PlatformException catch (e) {
      debugPrint('❌ [BiometricService] Authentication error: ${e.message}');

      // Handle specific error codes
      if (e.code == 'NotAvailable') {
        debugPrint('Biometric authentication not available');
      } else if (e.code == 'NotEnrolled') {
        debugPrint('No biometrics enrolled');
      } else if (e.code == 'LockedOut' || e.code == 'PermanentlyLockedOut') {
        debugPrint('Biometric authentication locked');
      }

      return false;
    }
  }

  /// Check if user has enrolled biometrics
  Future<bool> hasEnrolledBiometrics() async {
    try {
      final biometrics = await getAvailableBiometrics();
      return biometrics.isNotEmpty;
    } catch (e) {
      debugPrint('❌ [BiometricService] Error checking enrolled biometrics: $e');
      return false;
    }
  }

  /// Stop authentication (if in progress)
  Future<bool> stopAuthentication() async {
    try {
      return await _localAuth.stopAuthentication();
    } catch (e) {
      debugPrint('❌ [BiometricService] Error stopping authentication: $e');
      return false;
    }
  }
}
