import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../theme/app_theme.dart';
import '../core/providers/app_providers.dart';
import '../models/chat_message.dart';
import '../providers/ai_provider.dart';
import '../components/gradient_background.dart';
import '../components/base_bottom_sheet.dart';
import '../components/glass_effects/glass_dialog.dart';
import '../components/glass_card.dart';
import '../components/glass_streaming_message.dart';
import '../components/glassmorphic_fab_menu.dart';
import '../components/scroll_to_bottom.dart';
import '../components/is_typing_indicator.dart';
import '../components/time_and_status.dart';
import '../services/conversation_service.dart';
import '../services/gemini_ai_service.dart';
import '../core/services/crisis_detection_service.dart';
import '../core/services/content_filter_service.dart';
import '../core/widgets/crisis_dialog.dart';
import '../utils/responsive_utils.dart';
import 'paywall_screen.dart';
import '../components/message_limit_dialog.dart';
import '../components/chat_screen_lockout_overlay.dart';
import '../core/services/subscription_service.dart';

class ChatScreen extends HookConsumerWidget {
  const ChatScreen({super.key});

  ChatMessage _createWelcomeMessage() {
    return ChatMessage.system(
      content: 'Peace be with you! 🙏\n\nI\'m here to provide biblical guidance and spiritual support. Feel free to ask me about:\n\n• Scripture interpretation\n• Prayer requests\n• Life challenges\n• Faith questions\n• Daily encouragement\n\nHow can I help you today?',
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messageController = useTextEditingController();
    final scrollController = useScrollController();
    final messages = useState<List<ChatMessage>>([]);
    final isTyping = useState(false);
    final isStreaming = useState(false);
    final isStreamingComplete = useState(false);
    final streamedText = useState('');
    final sessionId = useState<String?>(null);
    final conversationService = useMemoized(() => ConversationService());
    final canSend = useState(false);
    final showScrollToBottom = useState(false);

    // Listen to text changes to update send button state
    useEffect(() {
      void listener() {
        canSend.value = messageController.text.trim().isNotEmpty;
      }
      messageController.addListener(listener);
      return () => messageController.removeListener(listener);
    }, [messageController]);

    // Listen to scroll position to show/hide scroll to bottom button
    useEffect(() {
      void listener() {
        if (scrollController.hasClients) {
          final maxScroll = scrollController.position.maxScrollExtent;
          final currentScroll = scrollController.position.pixels;
          // Show button if scrolled up more than 200 pixels from bottom
          showScrollToBottom.value = (maxScroll - currentScroll) > 200;
        }
      }
      scrollController.addListener(listener);
      return () => scrollController.removeListener(listener);
    }, [scrollController]);

    // Watch AI service initialization state
    final aiServiceState = ref.watch(aiServiceStateProvider);

    // Initialize session and load messages from database
    useEffect(() {
      Future<void> initializeSession() async {
        try {
          debugPrint('🔄 Initializing chat session...');

          // Always start with a fresh session (old sessions accessible via history)
          debugPrint('🆕 Creating fresh session');
          final newSessionId = await conversationService.createSession(
            title: 'New Conversation',
          );
          sessionId.value = newSessionId;
          debugPrint('✅ Created new session: $newSessionId');

          // Add welcome message with sessionId
          final welcomeMessage = ChatMessage.system(
            content: 'Peace be with you! 🙏\n\nI\'m here to provide biblical guidance and spiritual support. Feel free to ask me about:\n\n• Scripture interpretation\n• Prayer requests\n• Life challenges\n• Faith questions\n• Daily encouragement\n\nHow can I help you today?',
            sessionId: newSessionId,
          );
          await conversationService.saveMessage(welcomeMessage);

          // Set messages
          messages.value = [welcomeMessage];
          debugPrint('✅ New session initialized with welcome message');
        } catch (e, stackTrace) {
          debugPrint('❌ Failed to initialize session: $e');
          debugPrint('❌ Stack trace: $stackTrace');
          // Fallback to in-memory
          messages.value = [_createWelcomeMessage()];
          debugPrint('⚠️ Using in-memory fallback mode');
        }
      }

      initializeSession();
      return null;
    }, []);

    // Auto-scroll when messages change
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
      return null;
    }, [messages.value]);

    void scrollToBottom() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }

    Future<void> sendMessage(String text) async {
      if (text.trim().isEmpty) return;

      // Get subscription service and status
      final subscriptionService = ref.read(subscriptionServiceProvider);
      final subscriptionStatus = subscriptionService.getSubscriptionStatus();

      debugPrint('🔍 Subscription check: status=$subscriptionStatus, kDebugMode=$kDebugMode');

      // Skip all checks in debug mode
      if (kDebugMode) {
        // In debug mode, allow sending without subscription checks
      } else {
        // 1. Check if user is locked out (trial expired or premium expired)
        if (subscriptionStatus == SubscriptionStatus.trialExpired ||
            subscriptionStatus == SubscriptionStatus.premiumExpired) {
          // Show paywall directly - user is fully locked out
          if (context.mounted) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const PaywallScreen(showTrialInfo: false),
              ),
            );
          }
          return;
        }

        // 2. Check if user has messages remaining
        if (!subscriptionService.canSendMessage) {
          // Show message limit dialog first
          if (context.mounted) {
            final shouldShowPaywall = await MessageLimitDialog.show(
              context: context,
              isPremium: subscriptionStatus == SubscriptionStatus.premiumActive,
              remainingMessages: subscriptionService.remainingMessages,
            );

            if (shouldShowPaywall == true) {
              if (!context.mounted) {
                return;
              }
              // User clicked "Subscribe Now"
              final upgraded = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PaywallScreen(
                    showTrialInfo: subscriptionStatus == SubscriptionStatus.inTrial,
                    showMessageStats: true,
                  ),
                ),
              );

              if (upgraded != true) {
                // User didn't upgrade, don't send message
                return;
              }
            } else {
              // User clicked "Maybe Later"
              // Days 1-2: Can still view history (just return)
              // Day 3 + cancelled: Will be handled by lockout check on next screen load
              return;
            }
          } else {
            return;
          }
        }
      }

      // Consume message credit (skip in debug mode)
      final consumed = kDebugMode ? true : await subscriptionService.consumeMessage();
      if (!consumed) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
              margin: const EdgeInsets.all(16),
              padding: EdgeInsets.zero,
              content: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1E293B), // slate-800
                      Color(0xFF0F172A), // slate-900
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.red.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red.shade300,
                      size: ResponsiveUtils.iconSize(context, 20),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Failed to send message. Please try again.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return;
      }

      // Check for crisis keywords and show resources if detected
      final crisisDetectionService = CrisisDetectionService();
      final crisisResult = crisisDetectionService.detectCrisis(text.trim());

      if (crisisResult != null && context.mounted) {
        // Show dismissible warning with resources (doesn't block the message)
        crisisDetectionService.logCrisisDetection(crisisResult);

        // Capture the context that has Navigator access
        final navigatorContext = context;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 10),
            margin: const EdgeInsets.all(16),
            padding: EdgeInsets.zero,
            content: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1E293B), // slate-800
                    Color(0xFF0F172A), // slate-900
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.orange.withValues(alpha: 0.7),
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange.shade300, size: 20),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Crisis Resources Available',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(crisisResult.getMessage(), style: const TextStyle(fontSize: 14, color: Colors.white)),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to view resources →',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.orange.shade300),
                  ),
                ],
              ),
            ),
            action: SnackBarAction(
              label: 'View',
              textColor: Colors.orange.shade300,
              onPressed: () {
                // Use navigatorContext to ensure we have Navigator access
                if (navigatorContext.mounted) {
                  CrisisDialog.show(
                    navigatorContext,
                    crisisResult: crisisResult,
                    onAcknowledge: () {
                      debugPrint('✅ User viewed crisis resources');
                    },
                  );
                }
              },
            ),
          ),
        );
        // Message continues to AI normally
      }

      final userMessage = ChatMessage.user(
        content: text.trim(),
        sessionId: sessionId.value,
      );

      messages.value = [...messages.value, userMessage];
      isStreaming.value = true;
      isStreamingComplete.value = false;
      streamedText.value = '';
      messageController.clear();

      // Save user message to database
      if (sessionId.value != null) {
        await conversationService.saveMessage(userMessage);
        debugPrint('💾 Saved user message to session ${sessionId.value}');
      } else {
        debugPrint('⚠️ Cannot save message - no active session');
      }

      scrollToBottom();

      try {
        // Use actual AI service with streaming
        final aiService = ref.read(aiServiceProvider);
        debugPrint('🔍 AI Service ready: ${aiService.isReady}');

        if (!aiService.isReady) {
          debugPrint('⚠️ AI Service not ready, using fallback');
          throw Exception('AI Service not ready');
        }

        debugPrint('🚀 Starting streaming AI response for: "${text.trim()}"');

        // Accumulate full response for saving
        final fullResponse = StringBuffer();

        // Start streaming
        final stream = aiService.generateResponseStream(
          userInput: text.trim(),
          conversationHistory: messages.value,
        );

        await for (final chunk in stream) {
          streamedText.value += chunk;
          fullResponse.write(chunk);

          // Add small delay for smoother reading experience
          await Future.delayed(const Duration(milliseconds: 30));
          scrollToBottom();
        }

        debugPrint('✅ Streaming complete, full response length: ${fullResponse.length}');

        // Mark streaming as complete but keep widget visible
        isStreamingComplete.value = true;

        // Wait for completion animation to finish
        await Future.delayed(const Duration(milliseconds: 500));

        // Filter AI response for harmful content
        final contentFilterService = ContentFilterService();
        final filterResult = contentFilterService.filterResponse(fullResponse.toString());

        String finalContent;
        if (filterResult.isRejected) {
          // Log the filtering event
          contentFilterService.logFilteredResponse(filterResult, fullResponse.toString());

          // Use fallback response instead
          finalContent = contentFilterService.getFallbackResponse('default');

          debugPrint('⚠️ Content filtered: ${filterResult.rejectionReason}');
          debugPrint('📝 Using fallback response');
        } else {
          finalContent = fullResponse.toString();
        }

        // Create final AI message with filtered content
        final aiMessage = ChatMessage.ai(
          content: finalContent,
          sessionId: sessionId.value,
        );

        // Now transition to final message
        isStreaming.value = false;
        isStreamingComplete.value = false;
        messages.value = [...messages.value, aiMessage];

        // Save AI message to database
        if (sessionId.value != null) {
          await conversationService.saveMessage(aiMessage);
          debugPrint('💾 Saved AI message to session ${sessionId.value}');

          // Auto-generate conversation title after first exchange
          final conversationMessages = messages.value.where((m) =>
            m.type == MessageType.user || m.type == MessageType.ai
          ).toList();

          debugPrint('🔍 Conversation has ${conversationMessages.length} messages (excluding system)');

          if (conversationMessages.length == 2) {
            try {
              debugPrint('🎯 Triggering title generation...');
              final userMsg = conversationMessages.first.content;
              final title = await GeminiAIService.instance.generateConversationTitle(
                userMessage: userMsg,
                aiResponse: fullResponse.toString(),
              );
              await conversationService.updateSessionTitle(sessionId.value!, title);
              debugPrint('✅ Auto-generated title: "$title"');
            } catch (e) {
              debugPrint('⚠️ Failed to generate title: $e');
            }
          }
        } else {
          debugPrint('⚠️ Cannot save AI message - no active session');
        }

        scrollToBottom();
      } catch (e) {
        // Fallback to contextual response if AI service fails
        debugPrint('❌ AI Service error: $e');
        debugPrint('❌ Stack trace: ${StackTrace.current}');
        final response = _getContextualResponse(text.trim().toLowerCase());
        final aiMessage = ChatMessage.ai(
          content: response,
          sessionId: sessionId.value,
        );

        isStreaming.value = false;
        isStreamingComplete.value = false;
        streamedText.value = '';
        messages.value = [...messages.value, aiMessage];

        // Save fallback AI message to database
        if (sessionId.value != null) {
          await conversationService.saveMessage(aiMessage);
          debugPrint('💾 Saved fallback AI message to session ${sessionId.value}');
        } else {
          debugPrint('⚠️ Cannot save fallback message - no active session');
        }

        scrollToBottom();
      }
    }

    // Regenerate AI response for a specific message
    Future<void> regenerateResponse(int aiMessageIndex) async {
      if (aiMessageIndex < 0 || aiMessageIndex >= messages.value.length) {
        debugPrint('❌ Invalid message index: $aiMessageIndex');
        return;
      }

      final aiMessage = messages.value[aiMessageIndex];
      if (!aiMessage.isAI) {
        debugPrint('❌ Cannot regenerate non-AI message');
        return;
      }

      // Find the previous user message
      String? userInput;
      for (int i = aiMessageIndex - 1; i >= 0; i--) {
        if (messages.value[i].isUser) {
          userInput = messages.value[i].content;
          break;
        }
      }

      if (userInput == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
              margin: const EdgeInsets.all(16),
              padding: EdgeInsets.zero,
              content: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1E293B), // slate-800
                      Color(0xFF0F172A), // slate-900
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.red.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red.shade300,
                      size: ResponsiveUtils.iconSize(context, 20),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Could not find previous user message',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return;
      }

      debugPrint('🔄 Regenerating response for user input: "$userInput"');
      isTyping.value = true;

      try {
        // Use actual AI service
        final aiService = ref.read(aiServiceProvider);

        if (!aiService.isReady) {
          throw Exception('AI Service not ready');
        }

        final response = await aiService.generateResponse(
          userInput: userInput,
          conversationHistory: messages.value.take(aiMessageIndex).toList(),
        );
        debugPrint('✅ AI service returned new response');

        // Filter regenerated response for harmful content
        final contentFilterService = ContentFilterService();
        final filterResult = contentFilterService.filterResponse(response.content);

        String finalContent;
        if (filterResult.isRejected) {
          contentFilterService.logFilteredResponse(filterResult, response.content);
          finalContent = contentFilterService.getFallbackResponse('default');
          debugPrint('⚠️ Regenerated content filtered: ${filterResult.rejectionReason}');
        } else {
          finalContent = response.content;
        }

        final newAiMessage = ChatMessage.ai(
          content: finalContent,
          verses: response.verses,
          metadata: response.metadata,
          sessionId: sessionId.value,
        );

        // Replace the message in the list
        final updatedMessages = List<ChatMessage>.from(messages.value);
        updatedMessages[aiMessageIndex] = newAiMessage;
        messages.value = updatedMessages;

        // Update in database
        if (sessionId.value != null) {
          // Delete old message and save new one
          await conversationService.deleteMessage(aiMessage.id);
          await conversationService.saveMessage(newAiMessage);
          debugPrint('💾 Updated message in database');
        }

        isTyping.value = false;

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
              margin: const EdgeInsets.all(16),
              padding: EdgeInsets.zero,
              content: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1E293B), // slate-800
                      Color(0xFF0F172A), // slate-900
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.goldColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppTheme.goldColor,
                      size: ResponsiveUtils.iconSize(context, 20),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        '✨ Response regenerated successfully',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      } catch (e) {
        debugPrint('❌ Failed to regenerate response: $e');
        isTyping.value = false;

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
              margin: const EdgeInsets.all(16),
              padding: EdgeInsets.zero,
              content: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1E293B), // slate-800
                      Color(0xFF0F172A), // slate-900
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.red.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red.shade300,
                      size: ResponsiveUtils.iconSize(context, 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Failed to regenerate response: $e',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      }
    }

    // Export conversation to text
    Future<void> exportConversation() async {
      if (sessionId.value == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
              margin: const EdgeInsets.all(16),
              padding: EdgeInsets.zero,
              content: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1E293B), // slate-800
                      Color(0xFF0F172A), // slate-900
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.goldColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.white70,
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'No conversation to export',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return;
      }

      try {
        debugPrint('📤 Exporting conversation: ${sessionId.value}');
        final exportText = await conversationService.exportConversation(sessionId.value!);

        if (exportText.isEmpty) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
                margin: const EdgeInsets.all(16),
                padding: EdgeInsets.zero,
                content: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF1E293B), // slate-800
                        Color(0xFF0F172A), // slate-900
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.goldColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.white70,
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'No messages to export',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          return;
        }

        if (context.mounted) {
          showGlassDialog(
            context: context,
            child: GlassContainer(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.download, color: AppTheme.primaryColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AutoSizeText(
                          'Export Conversation',
                          style: TextStyle(
                            color: AppColors.primaryText,
                            fontWeight: FontWeight.w700,
                            fontSize: ResponsiveUtils.fontSize(context, 20, minSize: 18, maxSize: 24),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 400),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      borderRadius: AppRadius.mediumRadius,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: SelectableText(
                        exportText,
                        style: TextStyle(
                          color: AppColors.primaryText,
                          fontFamily: 'monospace',
                          fontSize: ResponsiveUtils.fontSize(context, 12, minSize: 10, maxSize: 14),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GlassDialogButton(
                        text: 'Close',
                        onTap: () => Navigator.pop(context),
                      ),
                      GlassDialogButton(
                        text: 'Share',
                        isPrimary: true,
                        onTap: () {
                          Navigator.pop(context);
                          SharePlus.instance.share(
                            ShareParams(
                              text: exportText,
                              subject: 'Biblical AI Conversation Export',
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }
      } catch (e) {
        debugPrint('❌ Failed to export conversation: $e');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
              margin: const EdgeInsets.all(16),
              padding: EdgeInsets.zero,
              content: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1E293B), // slate-800
                      Color(0xFF0F172A), // slate-900
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.red.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red.shade300,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Failed to export: $e',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      }
    }

    // Share conversation directly
    Future<void> shareConversation() async {
      if (sessionId.value == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
              margin: const EdgeInsets.all(16),
              padding: EdgeInsets.zero,
              content: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1E293B), // slate-800
                      Color(0xFF0F172A), // slate-900
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.goldColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.white70,
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'No conversation to share',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return;
      }

      try {
        debugPrint('📤 Sharing conversation: ${sessionId.value}');
        final exportText = await conversationService.exportConversation(sessionId.value!);

        if (exportText.isEmpty) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
                margin: const EdgeInsets.all(16),
                padding: EdgeInsets.zero,
                content: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF1E293B), // slate-800
                        Color(0xFF0F172A), // slate-900
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.goldColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.white70,
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'No messages to share',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          return;
        }

        await SharePlus.instance.share(
          ShareParams(
            text: exportText,
            subject: 'Biblical AI Conversation',
          ),
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
              margin: const EdgeInsets.all(16),
              padding: EdgeInsets.zero,
              content: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1E293B), // slate-800
                      Color(0xFF0F172A), // slate-900
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.goldColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppTheme.goldColor,
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '📤 Conversation shared',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      } catch (e) {
        debugPrint('❌ Failed to share conversation: $e');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
              margin: const EdgeInsets.all(16),
              padding: EdgeInsets.zero,
              content: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1E293B), // slate-800
                      Color(0xFF0F172A), // slate-900
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.red.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red.shade300,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Failed to share: $e',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      }
    }

    // Show chat options menu
    void showChatOptions() {
      showCustomBottomSheet(
        context: context,
        title: 'Chat Options',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor.withValues(alpha: 0.3),
                      AppTheme.primaryColor.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: AppRadius.mediumRadius,
                ),
                child: const Icon(Icons.download, color: AppTheme.primaryColor),
              ),
              title: const Text(
                'Export Conversation',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                ),
              ),
              subtitle: Text(
                'View and copy conversation text',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 12, minSize: 10, maxSize: 14),
                  color: AppColors.secondaryText,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                exportConversation();
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.accentColor.withValues(alpha: 0.3),
                      AppTheme.accentColor.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: AppRadius.mediumRadius,
                ),
                child: const Icon(Icons.share, color: AppTheme.accentColor),
              ),
              title: const Text(
                'Share Conversation',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                ),
              ),
              subtitle: Text(
                'Share via system share sheet',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 12, minSize: 10, maxSize: 14),
                  color: AppColors.secondaryText,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                shareConversation();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    }

    // ============================================================================
    // SUBSCRIPTION LOCKOUT CHECK
    // ============================================================================

    // Check subscription status for chat lockout
    final subscriptionService = ref.watch(subscriptionServiceProvider);
    final subscriptionStatus = subscriptionService.getSubscriptionStatus();

    // If trial expired or premium expired, show lockout overlay
    if (subscriptionStatus == SubscriptionStatus.trialExpired ||
        subscriptionStatus == SubscriptionStatus.premiumExpired) {
      return Scaffold(
        body: Stack(
          children: [
            const GradientBackground(),
            ChatScreenLockoutOverlay(
              onSubscribePressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PaywallScreen(showTrialInfo: false),
                  ),
                );
              },
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          const GradientBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context, messages, sessionId, conversationService, showChatOptions),
                // AI Service initialization status banner
                _buildAIStatusBanner(aiServiceState),
                Expanded(
                  child: _buildMessagesList(
                    context,
                    scrollController,
                    messages.value,
                    isTyping.value,
                    isStreaming.value,
                    isStreamingComplete.value,
                    streamedText.value,
                    regenerateResponse,
                  ),
                ),
                _buildMessageInput(context, messageController, canSend.value, sendMessage),
              ],
            ),
          ),
          // Scroll to bottom button
          ScrollToBottom(
            isVisible: showScrollToBottom.value,
            onPressed: scrollToBottom,
          ),
        ],
      ),
    );
  }

  Widget _buildAIStatusBanner(AIServiceState state) {
    return state.when(
      initializing: () => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.orange.withValues(alpha: 0.3),
              Colors.orange.withValues(alpha: 0.2),
            ],
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withValues(alpha: 0.9)),
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: AutoSizeText(
                'Initializing AI service...',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                minFontSize: 10,
                maxFontSize: 15,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      ready: () => const SizedBox.shrink(),
      fallback: (reason) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.amber.withValues(alpha: 0.3),
              Colors.amber.withValues(alpha: 0.2),
            ],
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.white.withValues(alpha: 0.9), size: 16),
            const SizedBox(width: 12),
            Expanded(
              child: AutoSizeText(
                'Using fallback responses: $reason',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                minFontSize: 10,
                maxFontSize: 15,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      error: (message) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.red.withValues(alpha: 0.3),
              Colors.red.withValues(alpha: 0.2),
            ],
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white.withValues(alpha: 0.9), size: 16),
            const SizedBox(width: 12),
            Expanded(
              child: AutoSizeText(
                'AI service error: $message',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                minFontSize: 10,
                maxFontSize: 15,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(
    BuildContext context,
    ValueNotifier<List<ChatMessage>> messages,
    ValueNotifier<String?> sessionId,
    ConversationService conversationService,
    VoidCallback onShowOptions,
  ) {
    return Container(
      padding: AppSpacing.screenPadding,
      child: Row(
        children: [
          const GlassmorphicFABMenu(),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.2),
                  Colors.white.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: AppRadius.mediumRadius,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: Icon(Icons.more_vert, color: Colors.white, size: ResponsiveUtils.iconSize(context, 20)),
              onPressed: onShowOptions,
              tooltip: 'Chat Options',
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.2),
                  Colors.white.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: AppRadius.mediumRadius,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: Icon(Icons.history, color: Colors.white, size: ResponsiveUtils.iconSize(context, 20)),
              onPressed: () => _showConversationHistory(context, messages, sessionId, conversationService),
              tooltip: 'Conversation History',
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.goldColor.withValues(alpha: 0.3),
                  AppTheme.goldColor.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: AppRadius.mediumRadius,
              border: Border.all(
                color: AppTheme.goldColor.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: Icon(Icons.add, color: AppColors.primaryText, size: ResponsiveUtils.iconSize(context, 20)),
              onPressed: () => _startNewConversation(context, messages, sessionId, conversationService),
              tooltip: 'New Conversation',
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: AppAnimations.slow).slideY(begin: -0.3);
  }

  Widget _buildMessagesList(
    BuildContext context,
    ScrollController scrollController,
    List<ChatMessage> messages,
    bool isTyping,
    bool isStreaming,
    bool isStreamingComplete,
    String streamedText,
    Future<void> Function(int) onRegenerateResponse,
  ) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: messages.length + (isStreaming ? 1 : (isTyping ? 1 : 0)),
      itemBuilder: (listContext, index) {
        // Show streaming message while streaming
        if (index == messages.length && isStreaming) {
          return GlassStreamingMessage(
            streamedText: streamedText,
            isComplete: isStreamingComplete,
          );
        }

        // Show typing indicator as fallback
        if (index == messages.length && isTyping) {
          return _buildTypingIndicator();
        }

        return _buildMessageBubble(context, messages[index], index, onRegenerateResponse);
      },
    );
  }

  Widget _buildMessageBubble(
    BuildContext context,
    ChatMessage message,
    int index,
    Future<void> Function(int) onRegenerateResponse,
  ) {
    return GestureDetector(
      onLongPress: message.isAI
          ? () {
              // Show options for regenerate
              showCustomBottomSheet(
                context: context,
                title: 'Message Options',
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primaryColor.withValues(alpha: 0.3),
                              AppTheme.primaryColor.withValues(alpha: 0.1),
                            ],
                          ),
                          borderRadius: AppRadius.mediumRadius,
                        ),
                        child: const Icon(Icons.refresh, color: AppTheme.primaryColor),
                      ),
                      title: const Text(
                        'Regenerate Response',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryText,
                        ),
                      ),
                      subtitle: Text(
                        'Generate a new response to this message',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.fontSize(context, 12, minSize: 10, maxSize: 14),
                          color: AppColors.secondaryText,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        onRegenerateResponse(index);
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            }
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Row(
          mainAxisAlignment:
              message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!message.isUser) ...[
              Container(
                padding: EdgeInsets.all(ResponsiveUtils.scaleSize(context, AppSpacing.sm, minScale: 0.9, maxScale: 1.1)),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor.withValues(alpha: 0.3),
                      AppTheme.primaryColor.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: AppRadius.mediumRadius,
                  border: Border.all(
                    color: AppTheme.primaryColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.auto_awesome,
                  color: AppColors.primaryText,
                  size: ResponsiveUtils.iconSize(context, 20),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
            ],
            Flexible(
              child: Container(
                padding: AppSpacing.cardPadding,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: message.isUser
                        ? [
                            AppTheme.primaryColor.withValues(alpha: 0.8),
                            AppTheme.primaryColor.withValues(alpha: 0.6),
                          ]
                        : [
                            Colors.white.withValues(alpha: 0.2),
                            Colors.white.withValues(alpha: 0.1),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(message.isUser ? 20 : 8),
                    topRight: Radius.circular(message.isUser ? 8 : 20),
                    bottomLeft: const Radius.circular(AppRadius.lg),
                    bottomRight: const Radius.circular(AppRadius.lg),
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoSizeText(
                      message.content,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 15, minSize: 13, maxSize: 17),
                        color: AppColors.primaryText,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                        shadows: AppTheme.textShadowSubtle,
                      ),
                      minFontSize: 12,
                      maxFontSize: 17,
                      maxLines: 500,
                      overflow: TextOverflow.visible,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TimeAndStatus(
                      timestamp: message.timestamp,
                      status: message.status,
                      showTime: true,
                      showStatus: message.isUser, // Only show status for user messages
                    ),
                  ],
                ),
              ),
            ),
            if (message.isUser) ...[
              const SizedBox(width: AppSpacing.md),
              Container(
                padding: EdgeInsets.all(ResponsiveUtils.scaleSize(context, AppSpacing.sm, minScale: 0.9, maxScale: 1.1)),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.goldColor.withValues(alpha: 0.3),
                      AppTheme.goldColor.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: AppRadius.mediumRadius,
                  border: Border.all(
                    color: AppTheme.goldColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.person,
                  color: AppColors.primaryText,
                  size: ResponsiveUtils.iconSize(context, 20),
                ),
              ),
            ],
          ],
        ),
      ).animate().fadeIn(duration: AppAnimations.normal, delay: (index * 100).ms).slideX(
            begin: message.isUser ? 0.3 : -0.3,
          ),
    );
  }

  Widget _buildTypingIndicator() {
    return const GlassTypingIndicator();
  }

  Widget _buildMessageInput(BuildContext context, TextEditingController messageController, bool canSend, void Function(String) sendMessage) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Consumer(
      builder: (context, ref, child) {
        final remainingMessages = ref.watch(remainingMessagesProvider);
        final isPremium = ref.watch(isPremiumProvider);
        final isInTrial = ref.watch(isInTrialProvider);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Message counter badge
            if (remainingMessages > 0) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.goldColor.withValues(alpha: 0.3),
                        AppTheme.goldColor.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: AppRadius.mediumRadius,
                    border: Border.all(
                      color: AppTheme.goldColor.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.chat_bubble_outline,
                        size: 14,
                        color: AppTheme.goldColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$remainingMessages ${isPremium ? "messages left this month" : isInTrial ? "messages left today" : "messages left"}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            // Input row
            Container(
              padding: EdgeInsets.only(
                left: AppSpacing.screenPadding.left,
                right: AppSpacing.screenPadding.right,
                top: AppSpacing.screenPadding.top,
                bottom: bottomPadding > 0 ? bottomPadding + AppSpacing.sm : AppSpacing.screenPadding.bottom,
              ),
              child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.2),
                    Colors.white.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppRadius.xl + 1),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: messageController,
                style: TextStyle(
                  color: AppColors.primaryText,
                  fontSize: ResponsiveUtils.fontSize(context, 15, minSize: 13, maxSize: 17),
                ),
                decoration: InputDecoration(
                  hintText: 'Scripture Chat...',
                  hintStyle: TextStyle(
                    color: AppColors.tertiaryText,
                    fontSize: ResponsiveUtils.fontSize(context, 15, minSize: 13, maxSize: 17),
                  ),
                  border: InputBorder.none,
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                ),
                minLines: 1,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: canSend ? sendMessage : null,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: canSend
                    ? [
                        AppTheme.primaryColor,
                        AppTheme.primaryColor.withValues(alpha: 0.8),
                      ]
                    : [
                        Colors.grey.withValues(alpha: 0.3),
                        Colors.grey.withValues(alpha: 0.2),
                      ],
              ),
              borderRadius: BorderRadius.circular(AppRadius.xl + 1),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: canSend
                  ? [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: IconButton(
              onPressed: canSend ? () => sendMessage(messageController.text) : null,
              icon: Icon(
                Icons.send,
                color: canSend ? AppColors.primaryText : AppColors.tertiaryText,
                size: ResponsiveUtils.iconSize(context, 20),
              ),
            ),
          ),
                ],
              ),
            ).animate().fadeIn(duration: AppAnimations.slow, delay: AppAnimations.fast).slideY(begin: 0.3),
          ],
        );
      },
    );
  }

  String _getContextualResponse(String message) {
    if (message.contains('prayer') || message.contains('pray')) {
      return 'Prayer is our direct line to God. As it says in Philippians 4:6-7: "Do not be anxious about anything, but in every situation, by prayer and petition, with thanksgiving, present your requests to God. And the peace of God, which transcends all understanding, will guard your hearts and your minds in Christ Jesus."\n\nWhat specific area would you like prayer for?';
    } else if (message.contains('fear') || message.contains('afraid') || message.contains('worry')) {
      return 'I understand you\'re feeling fearful. Remember what God says in Isaiah 41:10: "Fear not, for I am with you; be not dismayed, for I am your God; I will strengthen you, I will help you, I will uphold you with my righteous right hand."\n\nGod is always with you, even in your darkest moments. What is causing you to feel this way?';
    } else if (message.contains('love') || message.contains('relationship')) {
      return 'Love is at the heart of the Christian faith. 1 John 4:19 tells us "We love because he first loved us." God\'s love for us is unconditional and eternal.\n\nIn our relationships with others, we\'re called to love as Christ loved us - with patience, kindness, and forgiveness. How can I help you apply God\'s love in your situation?';
    } else if (message.contains('forgive') || message.contains('forgiveness')) {
      return 'Forgiveness is one of God\'s greatest gifts to us. As Jesus taught us in Matthew 6:14-15: "If you forgive other people when they sin against you, your heavenly Father will also forgive you."\n\nForgiveness doesn\'t mean forgetting or excusing wrong behavior, but it frees us from the burden of resentment. What situation are you struggling to forgive?';
    } else if (message.contains('purpose') || message.contains('calling')) {
      return 'God has a unique purpose for your life! Jeremiah 29:11 reminds us: "For I know the plans I have for you," declares the Lord, "plans to prosper you and not to harm you, to give you hope and a future."\n\nYour purpose is found in loving God and serving others. What gifts and passions has God given you that you could use to serve Him?';
    } else {
      return 'Thank you for sharing with me. God cares deeply about every aspect of your life, both big and small. As it says in 1 Peter 5:7: "Cast all your anxiety on him because he cares for you."\n\nRemember that you are loved, valued, and never alone. God is always listening and ready to help. Would you like to explore a specific Bible verse or topic related to your question?';
    }
  }

  void _showConversationHistory(
    BuildContext context,
    ValueNotifier<List<ChatMessage>> messages,
    ValueNotifier<String?> sessionId,
    ConversationService conversationService,
  ) async {
    debugPrint('📜 Opening conversation history...');
    final sessions = await conversationService.getSessions();
    debugPrint('📜 Found ${sessions.length} sessions in history');

    if (!context.mounted) return;

    showCustomBottomSheet(
      context: context,
      title: 'Conversation History',
      height: MediaQuery.of(context).size.height * 0.75,
      child: sessions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: ResponsiveUtils.iconSize(context, 64),
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AutoSizeText(
                    'No conversation history yet',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    minFontSize: 12,
                    maxFontSize: 18,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              itemCount: sessions.length > 20 ? 20 : sessions.length,
              itemBuilder: (context, index) {
                final session = sessions[index];
                final createdAt = DateTime.fromMillisecondsSinceEpoch(
                  session['created_at'] as int,
                );
                final messageCount = session['message_count'] as int? ?? 0;
                final sessionIdStr = session['id'] as String;

                return Dismissible(
                  key: Key(sessionIdStr),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (direction) async {
                    // Show confirmation dialog
                    return await showGlassDialog<bool>(
                      context: context,
                      child: GlassContainer(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.delete_outline,
                              color: Colors.red.shade400,
                              size: ResponsiveUtils.iconSize(context, 48),
                            ),
                            const SizedBox(height: 16),
                            AutoSizeText(
                              'Delete Conversation?',
                              style: TextStyle(
                                color: AppColors.primaryText,
                                fontWeight: FontWeight.w700,
                                fontSize: ResponsiveUtils.fontSize(context, 20, minSize: 18, maxSize: 24),
                              ),
                              maxLines: 1,
                              minFontSize: 16,
                              maxFontSize: 24,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 12),
                            AutoSizeText(
                              'This will permanently delete this conversation and all its messages.',
                              style: TextStyle(
                                color: AppColors.secondaryText,
                                fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                                fontWeight: FontWeight.w500,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 3,
                              minFontSize: 11,
                              maxFontSize: 16,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                GlassDialogButton(
                                  text: 'Cancel',
                                  onTap: () => Navigator.pop(context, false),
                                ),
                                GlassDialogButton(
                                  text: 'Delete',
                                  isPrimary: true,
                                  onTap: () => Navigator.pop(context, true),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ) ?? false;
                  },
                  onDismissed: (direction) async {
                    // Delete the session
                    await conversationService.deleteSession(sessionIdStr);
                    debugPrint('🗑️ Deleted session: $sessionIdStr');

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                          margin: const EdgeInsets.all(16),
                          padding: EdgeInsets.zero,
                          content: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF1E293B), // slate-800
                                  Color(0xFF0F172A), // slate-900
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppTheme.goldColor.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: AppTheme.goldColor,
                                  size: 20,
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Conversation deleted',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                  },
                  background: Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.red.withValues(alpha: 0.8),
                          Colors.red.withValues(alpha: 0.6),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: ResponsiveUtils.iconSize(context, 32),
                    ),
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.15),
                          Colors.white.withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(AppSpacing.md),
                      leading: Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.goldColor.withValues(alpha: 0.3),
                              AppTheme.goldColor.withValues(alpha: 0.1),
                            ],
                          ),
                          borderRadius: AppRadius.mediumRadius,
                          border: Border.all(
                            color: AppTheme.goldColor.withValues(alpha: 0.4),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.chat_bubble_outline,
                          color: AppColors.primaryText,
                          size: ResponsiveUtils.iconSize(context, 20),
                        ),
                      ),
                      title: AutoSizeText(
                        session['title'] as String? ?? 'Conversation',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryText,
                        ),
                        maxLines: 1,
                        minFontSize: 12,
                        maxFontSize: 18,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: AutoSizeText(
                        '${_formatDate(createdAt)} • $messageCount messages',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.fontSize(context, 12, minSize: 10, maxSize: 14),
                          color: AppColors.secondaryText,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        minFontSize: 9,
                        maxFontSize: 14,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: ResponsiveUtils.iconSize(context, 16),
                        color: AppColors.secondaryText,
                      ),
                      onTap: () {
                        debugPrint('👆 User selected session: $sessionIdStr');
                        Navigator.pop(context);
                        _loadConversation(
                          sessionIdStr,
                          messages,
                          sessionId,
                          conversationService,
                        );
                      },
                    ),
                  ).animate().fadeIn(duration: AppAnimations.fast).slideX(begin: 0.2),
                );
              },
            ),
    );
  }

  void _startNewConversation(
    BuildContext context,
    ValueNotifier<List<ChatMessage>> messages,
    ValueNotifier<String?> sessionId,
    ConversationService conversationService,
  ) async {
    debugPrint('🆕 New conversation button clicked');

    // Get current message count (excluding system welcome message)
    final conversationMessages = messages.value.where((m) =>
      m.type == MessageType.user || m.type == MessageType.ai
    ).toList();

    debugPrint('🔍 Current conversation has ${conversationMessages.length} messages (excluding system)');

    // Only show confirmation if there's actual conversation content
    if (conversationMessages.isEmpty) {
      // No real messages yet - just create new session directly
      debugPrint('✨ No messages yet, creating new session directly');
      final newSessionId = await conversationService.createSession(
        title: 'New Conversation',
      );
      sessionId.value = newSessionId;

      final welcomeMessage = ChatMessage.system(
        content: 'Peace be with you! 🙏\n\nI\'m here to provide biblical guidance and spiritual support. Feel free to ask me about:\n\n• Scripture interpretation\n• Prayer requests\n• Life challenges\n• Faith questions\n• Daily encouragement\n\nHow can I help you today?',
        sessionId: newSessionId,
      );
      await conversationService.saveMessage(welcomeMessage);
      messages.value = [welcomeMessage];

      debugPrint('✅ New session created: $newSessionId');

      // Show success feedback
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            margin: const EdgeInsets.all(16),
            padding: EdgeInsets.zero,
            content: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1E293B), // slate-800
                    Color(0xFF0F172A), // slate-900
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.goldColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppTheme.goldColor,
                    size: 20,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '✨ New conversation started',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
      return;
    }

    // Show confirmation dialog if there's content
    showGlassDialog(
      context: context,
      child: GlassContainer(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AutoSizeText(
              'Start New Conversation?',
              style: TextStyle(
                color: AppColors.primaryText,
                fontWeight: FontWeight.w700,
                fontSize: ResponsiveUtils.fontSize(context, 20, minSize: 18, maxSize: 24),
              ),
              maxLines: 1,
              minFontSize: 16,
              maxFontSize: 24,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            AutoSizeText(
              'Your current conversation will be saved to history.\n\nStart a fresh conversation?',
              style: TextStyle(
                color: AppColors.secondaryText,
                fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
              maxLines: 4,
              minFontSize: 11,
              maxFontSize: 16,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GlassDialogButton(
                  text: 'Cancel',
                  onTap: () => Navigator.pop(context),
                ),
                GlassDialogButton(
                  text: 'New Chat',
                  isPrimary: true,
                  onTap: () async {
                    debugPrint('✅ User confirmed new conversation');
                    Navigator.pop(context);

                    // Ensure current session is finalized
                    if (sessionId.value != null) {
                      debugPrint('💾 Finalizing current session: ${sessionId.value}');
                      // Session is already auto-updated via _updateSessionLastMessage
                    }

                    // Create new session
                    debugPrint('🆕 Creating new session...');
                    final newSessionId = await conversationService.createSession(
                      title: 'New Conversation',
                    );
                    sessionId.value = newSessionId;

                    // Reset messages with welcome message (with sessionId)
                    final welcomeMessage = ChatMessage.system(
                      content: 'Peace be with you! 🙏\n\nI\'m here to provide biblical guidance and spiritual support. Feel free to ask me about:\n\n• Scripture interpretation\n• Prayer requests\n• Life challenges\n• Faith questions\n• Daily encouragement\n\nHow can I help you today?',
                      sessionId: newSessionId,
                    );
                    await conversationService.saveMessage(welcomeMessage);
                    messages.value = [welcomeMessage];

                    // Show success feedback
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 3),
                          margin: const EdgeInsets.all(16),
                          padding: EdgeInsets.zero,
                          content: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF1E293B), // slate-800
                                  Color(0xFF0F172A), // slate-900
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppTheme.goldColor.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: AppTheme.goldColor,
                                  size: 20,
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    '✨ New conversation started! Previous chat saved to history.',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    debugPrint('✅ Started new conversation: $newSessionId');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _loadConversation(
    String conversationSessionId,
    ValueNotifier<List<ChatMessage>> messages,
    ValueNotifier<String?> sessionId,
    ConversationService conversationService,
  ) async {
    try {
      debugPrint('📂 Loading conversation: $conversationSessionId');

      // Load messages from database
      final loadedMessages = await conversationService.getMessages(conversationSessionId);
      debugPrint('📨 Retrieved ${loadedMessages.length} messages from database');

      // Update session ID
      sessionId.value = conversationSessionId;

      // Update messages list
      messages.value = loadedMessages;

      debugPrint('✅ Loaded conversation: $conversationSessionId with ${loadedMessages.length} messages');
    } catch (e, stackTrace) {
      debugPrint('❌ Failed to load conversation: $e');
      debugPrint('❌ Stack trace: $stackTrace');
    }
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

}
