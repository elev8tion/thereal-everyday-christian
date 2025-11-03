import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../components/chat_share_widget.dart';
import '../models/chat_message.dart';

/// Service for capturing and sharing chat conversations with branding
class ChatShareService {
  final ScreenshotController _screenshotController = ScreenshotController();

  ScreenshotController get controller => _screenshotController;

  /// Captures chat messages as a branded image and shares it
  Future<void> shareChat({
    required BuildContext context,
    required List<ChatMessage> messages,
    required List<Widget> messageWidgets,
  }) async {
    try {
      // Capture the widget as an image
      final Uint8List? imageBytes = await _screenshotController.captureFromWidget(
        MediaQuery(
          data: MediaQuery.of(context),
          child: ChatShareWidget(
            messages: messageWidgets,
          ),
        ),
        pixelRatio: 2.0,
        delay: const Duration(milliseconds: 100),
      );

      if (imageBytes == null) {
        throw Exception('Failed to capture screenshot');
      }

      // Save to temporary file
      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/edc_chat_share_${DateTime.now().millisecondsSinceEpoch}.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(imageBytes);

      // Share the image with text
      await Share.shareXFiles(
        [XFile(imagePath)],
        text: 'Check out my conversation with Everyday Christian! 🙏\n\nGet personalized biblical guidance: https://everydaychristian.app',
        subject: 'My Everyday Christian Conversation',
      );

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
