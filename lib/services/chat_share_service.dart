import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../components/chat_share_widget.dart';
import '../models/chat_message.dart';
import '../core/services/database_service.dart';
import '../core/services/achievement_service.dart';
import '../l10n/app_localizations.dart';

/// Service for capturing and sharing chat conversations with branding
class ChatShareService {
  final ScreenshotController _screenshotController = ScreenshotController();
  final DatabaseService? _databaseService;
  final AchievementService? _achievementService;
  final _uuid = const Uuid();

  ChatShareService({
    DatabaseService? databaseService,
    AchievementService? achievementService,
  })  : _databaseService = databaseService,
        _achievementService = achievementService;

  ScreenshotController get controller => _screenshotController;

  /// Captures chat messages as a branded image and shares it
  Future<void> shareChat({
    required BuildContext context,
    required List<ChatMessage> messages,
    required List<Widget> messageWidgets,
    String? sessionId,
  }) async {
    try {
      // Extract locale and localizations before captureFromWidget
      final locale = Localizations.localeOf(context);
      final l10n = AppLocalizations.of(context);

      // Capture the widget as an image
      // Reset text scale to 1.0 for consistent screenshots regardless of user's text size preference
      final Uint8List imageBytes = await _screenshotController.captureFromWidget(
        MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.0), // Always use 1.0 for screenshots
          ),
          child: ChatShareWidget(
            messages: messageWidgets,
            locale: locale,
            l10n: l10n,
          ),
        ),
        pixelRatio: 2.0,
        delay: const Duration(milliseconds: 100),
      );

      // Save to temporary file in share_plus subdirectory for Android compatibility
      final directory = await getTemporaryDirectory();
      final shareDir = Directory('${directory.path}/share_plus');
      if (!await shareDir.exists()) {
        await shareDir.create(recursive: true);
      }
      final imagePath = '${shareDir.path}/edc_chat_share_${DateTime.now().millisecondsSinceEpoch}.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(imageBytes);

      // Share the image with text
      // ignore: deprecated_member_use
      await Share.shareXFiles(
        [XFile(imagePath)],
        text: 'Check out my conversation with Everyday Christian! 🙏\n\nGet personalized biblical guidance: https://everydaychristian.app',
        subject: 'My Everyday Christian Conversation',
      );

      // Track the share in database if sessionId provided
      if (sessionId != null && _databaseService != null) {
        await _trackShare(sessionId);
      }

      // Clean up temporary file after a delay
      Future.delayed(const Duration(seconds: 30), () {
        if (imageFile.existsSync()) {
          imageFile.delete();
        }
      });
    } catch (e) {
      debugPrint('Error sharing chat: $e');
      rethrow;
    }
  }

  /// Track a chat share in the database
  Future<void> _trackShare(String sessionId) async {
    try {
      final db = await _databaseService!.database;
      await db.insert('shared_chats', {
        'id': _uuid.v4(),
        'session_id': sessionId,
        'shared_at': DateTime.now().millisecondsSinceEpoch,
      });

      // Check for Disciple achievement (10 total shares across all types)
      if (_achievementService != null) {
        await _achievementService!.checkAllSharesAchievement();
      }
    } catch (e) {
      debugPrint('Error tracking share: $e');
      // Don't rethrow - sharing succeeded, tracking failure shouldn't break UX
    }
  }

  /// Creates message widgets from chat messages for sharing
  List<Widget> createShareableMessageWidgets(List<ChatMessage> messages) {
    return messages.map((message) {
      final isUser = message.type == MessageType.user;
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isUser
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isUser ? 'You' : 'Everyday Christian',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isUser
                      ? const Color(0xFFD4AF37) // Gold
                      : Colors.white70,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                message.content,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
}
