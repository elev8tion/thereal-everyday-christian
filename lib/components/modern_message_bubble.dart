import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../models/chat_message.dart';
import '../models/bible_verse.dart';

class ModernMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool showTimestamp;
  final Function(BibleVerse)? onVersePressed;
  final VoidCallback? onRegenerateResponse;

  const ModernMessageBubble({
    super.key,
    required this.message,
    this.showTimestamp = false,
    this.onVersePressed,
    this.onRegenerateResponse,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: message.isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: message.isUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!message.isUser) ...[
                _buildAvatar(),
                const SizedBox(width: 12),
              ],
              Flexible(
                child: _buildMessageContent(context),
              ),
              if (message.isUser) ...[
                const SizedBox(width: 12),
                _buildUserAvatar(),
              ],
            ],
          ),
          if (showTimestamp) ...[
            const SizedBox(height: 4),
            _buildTimestamp(),
          ],
          if (message.verses.isNotEmpty == true) ...[
            const SizedBox(height: 8),
            _buildVerses(),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.3);
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 16,
      backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
      child: const Icon(
        Icons.psychology_outlined,
        size: 16,
        color: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildUserAvatar() {
    return CircleAvatar(
      radius: 16,
      backgroundColor: AppTheme.accentColor.withValues(alpha: 0.1),
      child: const Icon(
        Icons.person,
        size: 16,
        color: AppTheme.accentColor,
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context) {
    return GestureDetector(
      onLongPress: message.isAI && onRegenerateResponse != null
          ? () => _showMessageOptions(context)
          : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: message.isUser
              ? AppTheme.primaryGradient
              : null,
          color: message.isUser
              ? null
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(AppRadius.lg),
            topRight: const Radius.circular(AppRadius.lg),
            bottomLeft: Radius.circular(message.isUser ? 20 : 4),
            bottomRight: Radius.circular(message.isUser ? 4 : 20),
          ),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.type == MessageType.system) ...[
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: message.isUser ? Colors.white : AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'System',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: message.isUser ? Colors.white70 : AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            Text(
              message.content,
              style: TextStyle(
                fontSize: 16,
                color: message.isUser
                    ? Colors.white
                    : Theme.of(context).textTheme.bodyLarge?.color,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMessageOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1E293B).withValues(alpha: 0.95), // Standard slate-800
              const Color(0xFF0F172A).withValues(alpha: 0.98), // Standard slate-900
            ],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(AppRadius.xs / 4),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.refresh, color: AppTheme.primaryColor),
                title: const Text(
                  'Regenerate Response',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Get a new AI response',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                onTap: () {
                  Navigator.pop(context);
                  onRegenerateResponse?.call();
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimestamp() {
    return Padding(
      padding: EdgeInsets.only(
        left: message.isUser ? 0 : 44,
        right: message.isUser ? 44 : 0,
      ),
      child: Text(
        _formatTimestamp(message.timestamp),
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade500,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildVerses() {
    return Padding(
      padding: EdgeInsets.only(
        left: message.isUser ? 0 : 44,
        right: message.isUser ? 44 : 0,
      ),
      child: Column(
        children: message.verses.map((verse) =>
          ModernVerseCard(
            verse: verse,
            onTap: onVersePressed != null ? () => onVersePressed!(verse) : null,
          ),
        ).toList(),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.month}/${timestamp.day}';
    }
  }
}

class ModernVerseCard extends StatelessWidget {
  final BibleVerse verse;
  final VoidCallback? onTap;
  final bool compact;

  const ModernVerseCard({
    super.key,
    required this.verse,
    this.onTap,
    this.compact = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor.withValues(alpha: 0.05),
                  AppTheme.accentColor.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: AppTheme.primaryColor.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: AppRadius.smallRadius,
                      ),
                      child: const Icon(
                        Icons.auto_stories,
                        size: 16,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        verse.reference,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    if (onTap != null)
                      Icon(
                        Icons.open_in_new,
                        size: 16,
                        color: AppTheme.primaryColor.withValues(alpha: 0.6),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  verse.text,
                  style: TextStyle(
                    fontSize: compact ? 14 : 16,
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (verse.themes.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    children: verse.themes.take(3).map((theme) =>
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: AppRadius.mediumRadius,
                        ),
                        child: Text(
                          theme,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    ).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 200.ms).slideY(begin: 0.2);
  }
}