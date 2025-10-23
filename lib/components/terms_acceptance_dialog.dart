import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../components/frosted_glass_card.dart';
import '../components/glass_button.dart';
import '../core/services/preferences_service.dart';
import '../utils/responsive_utils.dart';

/// Terms Acceptance Dialog
///
/// Displays Terms of Service and Privacy Policy that must be accepted
/// before using the app for the first time. This is required for App Store
/// compliance and legal protection.
class TermsAcceptanceDialog extends ConsumerStatefulWidget {
  final VoidCallback onAccepted;

  const TermsAcceptanceDialog({
    super.key,
    required this.onAccepted,
  });

  @override
  ConsumerState<TermsAcceptanceDialog> createState() => _TermsAcceptanceDialogState();
}

class _TermsAcceptanceDialogState extends ConsumerState<TermsAcceptanceDialog> {
  bool _termsChecked = false;
  bool _privacyChecked = false;
  bool _isAccepting = false;

  Future<void> _acceptTerms() async {
    if (!_termsChecked || !_privacyChecked) {
      _showSnackBar('Please read and accept both documents');
      return;
    }

    setState(() => _isAccepting = true);

    try {
      final prefsService = await PreferencesService.getInstance();
      final success = await prefsService.saveTermsAcceptance(true);

      if (success) {
        widget.onAccepted();
      } else {
        _showSnackBar('Failed to save acceptance. Please try again.');
        setState(() => _isAccepting = false);
      }
    } catch (e) {
      _showSnackBar('Error: $e');
      setState(() => _isAccepting = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.9),
      ),
    );
  }

  Future<void> _showDocument(String title, String filePath) async {
    HapticFeedback.mediumImpact();

    String content;
    try {
      content = await rootBundle.loadString(filePath);
    } catch (e) {
      content = 'Error loading document: $e';
    }

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1E293B), // Slate-800
                Color(0xFF0F172A), // Slate-900
              ],
            ),
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: ResponsiveUtils.fontSize(context, 20),
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryText,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.primaryText),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white10, height: 1),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: SelectableText(
                    content,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.fontSize(context, 14),
                      color: AppColors.secondaryText,
                      height: 1.6,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent dismissal by back button
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
            maxWidth: 500,
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1E293B), // Slate-800
                Color(0xFF0F172A), // Slate-900
              ],
            ),
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    Icon(
                      Icons.gavel,
                      size: ResponsiveUtils.iconSize(context, 48),
                      color: AppTheme.goldColor,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Legal Agreement',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 24),
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Please review and accept to continue',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 14),
                        color: AppColors.secondaryText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white10, height: 1),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Terms of Service
                      FrostedGlassCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        intensity: GlassIntensity.light,
                        child: Row(
                          children: [
                            Checkbox(
                              value: _termsChecked,
                              onChanged: _isAccepting ? null : (value) {
                                setState(() => _termsChecked = value ?? false);
                              },
                              shape: const CircleBorder(),
                              side: BorderSide(
                                color: AppTheme.goldColor.withValues(alpha: 0.6),
                                width: 2,
                              ),
                              activeColor: AppTheme.primaryColor,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'I have read and agree to the',
                                    style: TextStyle(
                                      fontSize: ResponsiveUtils.fontSize(context, 14),
                                      color: AppColors.primaryText,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => _showDocument(
                                      'Terms of Service',
                                      'assets/legal/TERMS_OF_SERVICE.md',
                                    ),
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: const Size(0, 30),
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Text(
                                      'Terms of Service',
                                      style: TextStyle(
                                        decoration: TextDecoration.underline,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // Privacy Policy
                      FrostedGlassCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        intensity: GlassIntensity.light,
                        child: Row(
                          children: [
                            Checkbox(
                              value: _privacyChecked,
                              onChanged: _isAccepting ? null : (value) {
                                setState(() => _privacyChecked = value ?? false);
                              },
                              shape: const CircleBorder(),
                              side: BorderSide(
                                color: AppTheme.goldColor.withValues(alpha: 0.6),
                                width: 2,
                              ),
                              activeColor: AppTheme.primaryColor,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'I have read and agree to the',
                                    style: TextStyle(
                                      fontSize: ResponsiveUtils.fontSize(context, 14),
                                      color: AppColors.primaryText,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => _showDocument(
                                      'Privacy Policy',
                                      'assets/legal/PRIVACY_POLICY.md',
                                    ),
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: const Size(0, 30),
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Text(
                                      'Privacy Policy',
                                      style: TextStyle(
                                        decoration: TextDecoration.underline,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      // Important notice
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: Colors.amber.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.amber.shade300,
                              size: 20,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                'You must accept both documents to use this app',
                                style: TextStyle(
                                  fontSize: ResponsiveUtils.fontSize(context, 12),
                                  color: Colors.amber.shade100,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Divider(color: Colors.white10, height: 1),

              // Actions
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    Expanded(
                      child: GlassButton(
                        text: _isAccepting ? 'Processing...' : 'Accept & Continue',
                        onPressed: (_termsChecked && _privacyChecked && !_isAccepting) ? _acceptTerms : null,
                        isLoading: _isAccepting,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
