import 'package:flutter/material.dart';
import '../core/models/prayer_category.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';

class CategoryFilterChip extends StatelessWidget {
  final PrayerCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryFilterChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  String _getLocalizedCategoryName(BuildContext context, String englishName) {
    final l10n = AppLocalizations.of(context);
    switch (englishName.toLowerCase()) {
      case 'family':
        return l10n.family;
      case 'health':
        return l10n.health;
      case 'work':
        return l10n.work;
      case 'ministry':
        return l10n.ministry;
      case 'thanksgiving':
        return l10n.thanksgiving;
      case 'intercession':
        return l10n.intercession;
      case 'finances':
        return l10n.finances;
      case 'relationships':
        return l10n.relationships;
      case 'guidance':
        return l10n.guidance;
      case 'protection':
        return l10n.protection;
      case 'general':
        return l10n.general;
      case 'faith':
        return l10n.faith;
      case 'gratitude':
        return l10n.gratitude;
      case 'other':
        return l10n.other;
      default:
        return englishName;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    category.color.withValues(alpha: 0.4),
                    category.color.withValues(alpha: 0.2),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.15),
                    Colors.white.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: AppRadius.largeCardRadius,
          border: Border.all(
            color: isSelected
                ? category.color
                : Colors.white.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: category.color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              category.icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 6),
            Text(
              _getLocalizedCategoryName(context, category.name),
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
