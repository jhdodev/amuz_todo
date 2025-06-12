import 'package:amuz_todo/src/service/theme_service.dart';
import 'package:amuz_todo/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsMenuButton extends ConsumerWidget {
  const SettingsMenuButton({
    super.key,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailingWidget,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailingWidget;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: double.infinity,
        child: Card(
          color: isDarkMode ? AppColors.cardGrey : Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: isDarkMode ? AppColors.darkGrey : Colors.grey.shade200,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: trailingWidget != null
                ? Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isDarkMode
                                    ? AppColors.almostWhite
                                    : Colors.black,
                              ),
                            ),
                            if (subtitle != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                subtitle!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDarkMode
                                      ? AppColors.mediumGrey
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      trailingWidget!,
                    ],
                  )
                : Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDarkMode ? AppColors.almostWhite : Colors.black,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
