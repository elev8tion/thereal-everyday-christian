import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Hook for fade-in animation with optional delay
AnimationController useFadeInAnimation({
  Duration duration = const Duration(milliseconds: 600),
  Duration delay = Duration.zero,
}) {
  final controller = useAnimationController(duration: duration);

  useEffect(() {
    Future.delayed(delay, () {
      if (controller.status != AnimationStatus.completed) {
        controller.forward();
      }
    });
    return null;
  }, [delay]);

  return controller;
}

/// Hook for scale animation with optional delay
AnimationController useScaleAnimation({
  Duration duration = const Duration(milliseconds: 800),
  Duration delay = Duration.zero,
}) {
  final controller = useAnimationController(duration: duration);

  useEffect(() {
    Future.delayed(delay, () {
      if (controller.status != AnimationStatus.completed) {
        controller.forward();
      }
    });
    return null;
  }, [delay]);

  return controller;
}

/// Hook for combined fade and scale animation
({AnimationController fade, AnimationController scale}) useFadeAndScale({
  Duration fadeDuration = const Duration(milliseconds: 1500),
  Duration scaleDuration = const Duration(milliseconds: 2000),
  Duration delay = Duration.zero,
}) {
  final fadeController = useAnimationController(duration: fadeDuration);
  final scaleController = useAnimationController(duration: scaleDuration);

  useEffect(() {
    Future.delayed(delay, () {
      fadeController.forward();
      scaleController.forward();
    });
    return null;
  }, [delay]);

  return (fade: fadeController, scale: scaleController);
}

/// Hook for auto-scrolling to bottom
void useAutoScrollToBottom(ScrollController controller, List<dynamic> items) {
  useEffect(() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.hasClients) {
        controller.animateTo(
          controller.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
    return null;
  }, [items.length]);
}
