import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../components/verse_share_widget.dart';
import '../models/bible_verse.dart';
import '../core/services/database_service.dart';

/// Service for capturing and sharing Bible verses with branding
class VerseShareService {
  final ScreenshotController _screenshotController = ScreenshotController();
  final DatabaseService? _databaseService;
  final _uuid = const Uuid();

  VerseShareService({DatabaseService? databaseService})
      : _databaseService = databaseService;

  ScreenshotController get controller => _screenshotController;

  /// Captures a Bible verse as a branded image and shares it
  Future<void> shareVerse({
    required BuildContext context,
    required BibleVerse verse,
    bool showThemes = true,
  }) async {
    try {
      // Capture the widget as an image
      final Uint8List? imageBytes = await _screenshotController.captureFromWidget(
        MediaQuery(
          data: MediaQuery.of(context),
          child: VerseShareWidget(
            verse: verse,
            showThemes: showThemes,
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
      final imagePath = '${directory.path}/edc_verse_share_${DateTime.now().millisecondsSinceEpoch}.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(imageBytes);

      // Share the image with text
      await Share.shareXFiles(
        [XFile(imagePath)],
        text: '${verse.reference} - "${verse.text}"\n\nFind more scripture with Everyday Christian 🙏\nhttps://everydaychristian.app',
        subject: 'Bible Verse - ${verse.reference}',
      );

      // Track the share in database if verse has an id
      if (verse.id != null && _databaseService != null) {
        await _trackShare(verse.id!);
      }

      // Clean up temporary file after a delay
      Future.delayed(const Duration(seconds: 30), () {
        if (imageFile.existsSync()) {
          imageFile.delete();
        }
      });
    } catch (e) {
      debugPrint('Error sharing verse: $e');
      rethrow;
    }
  }

  /// Track a verse share in the database
  Future<void> _trackShare(int verseId) async {
    try {
      final db = await _databaseService!.database;
      await db.insert('shared_verses', {
        'id': _uuid.v4(),
        'verse_id': verseId,
        'shared_at': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      debugPrint('Error tracking verse share: $e');
      // Don't rethrow - sharing succeeded, tracking failure shouldn't break UX
    }
  }
}
