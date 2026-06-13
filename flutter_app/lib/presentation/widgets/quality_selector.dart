import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/download_item.dart';
import 'dart:math';

class QualitySelector extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onChanged;
  final bool isAudio;

  const QualitySelector({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.isAudio = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              isAudio ? Icons.equalizer_rounded : Icons.hd_rounded,
              color: AppTheme.primary,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              isAudio ? 'Audio Quality' : 'Video Resolution',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((opt) {
            final isSelected = opt == selected;
            return GestureDetector(
              onTap: () => onChanged(opt),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: isSelected
                      ? (isAudio ? AppTheme.audioGradient : AppTheme.videoGradient)
                      : null,
                  color: isSelected ? null : AppTheme.darkCard,
                  border: Border.all(
                    color: isSelected ? Colors.transparent : AppTheme.darkBorder,
                    width: 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.3),
                            blurRadius: 12,
                            spreadRadius: 0,
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  isAudio ? '${opt}kbps' : '${opt}p',
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.textSecondary,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Static quality selector for when we don't have server format list
class StaticQualitySelector extends StatelessWidget {
  final bool isAudio;
  final String selected;
  final ValueChanged<String> onChanged;

  const StaticQualitySelector({
    super.key,
    required this.isAudio,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final options = isAudio
        ? ['64', '128', '192', '320']
        : ['360', '480', '720', '1080', '1440', '2160'];

    return QualitySelector(
      options: options,
      selected: selected,
      onChanged: onChanged,
      isAudio: isAudio,
    );
  }
}
