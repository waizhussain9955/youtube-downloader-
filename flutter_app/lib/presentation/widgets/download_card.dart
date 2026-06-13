import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/download_item.dart';

class DownloadCard extends StatelessWidget {
  final DownloadItem item;
  final VoidCallback? onCancel;
  final VoidCallback? onDelete;
  final VoidCallback? onOpen;
  final VoidCallback? onShare;

  const DownloadCard({
    super.key,
    required this.item,
    this.onCancel,
    this.onDelete,
    this.onOpen,
    this.onShare,
  });

  Color _statusColor() {
    switch (item.status) {
      case 'completed': return AppTheme.success;
      case 'failed': return AppTheme.error;
      case 'cancelled': return AppTheme.textHint;
      case 'downloading': return AppTheme.primary;
      case 'processing': return AppTheme.accentOrange;
      default: return AppTheme.info;
    }
  }

  IconData _statusIcon() {
    switch (item.status) {
      case 'completed': return Icons.check_circle_rounded;
      case 'failed': return Icons.error_rounded;
      case 'cancelled': return Icons.cancel_rounded;
      case 'downloading': return Icons.downloading_rounded;
      case 'processing': return Icons.settings_rounded;
      default: return Icons.schedule_rounded;
    }
  }

  String _statusLabel() {
    switch (item.status) {
      case 'queued': return 'Queued';
      case 'downloading': return item.speed != null ? item.speed! : 'Downloading...';
      case 'processing': return 'Processing...';
      case 'completed': return 'Completed';
      case 'failed': return 'Failed';
      case 'cancelled': return 'Cancelled';
      default: return item.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppTheme.darkCard,
        border: Border.all(
          color: item.isActive ? AppTheme.primary.withValues(alpha: 0.3) : AppTheme.darkBorder,
          width: item.isActive ? 1.5 : 1,
        ),
        boxShadow: item.isActive
            ? [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.08), blurRadius: 16)]
            : null,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: item.thumbnail != null
                      ? CachedNetworkImage(
                          imageUrl: item.thumbnail!,
                          width: 72,
                          height: 50,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => _thumbnailPlaceholder(),
                          errorWidget: (_, __, ___) => _thumbnailPlaceholder(),
                        )
                      : _thumbnailPlaceholder(),
                ),
                const SizedBox(width: 12),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _TypeBadge(item.isAudio ? 'AUDIO' : 'VIDEO', item.isAudio),
                          const SizedBox(width: 6),
                          _QualityBadge(
                            item.isAudio ? '${item.quality}kbps' : '${item.quality}p',
                          ),
                          if (item.formattedDuration.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Text(
                              item.formattedDuration,
                              style: const TextStyle(color: AppTheme.textHint, fontSize: 11),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // Action Button
                const SizedBox(width: 8),
                _buildActionButton(),
              ],
            ),
          ),
          // Progress Bar
          if (item.isActive)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(_statusIcon(), color: _statusColor(), size: 14),
                          const SizedBox(width: 4),
                          Text(
                            _statusLabel(),
                            style: TextStyle(color: _statusColor(), fontSize: 12),
                          ),
                        ],
                      ),
                      Text(
                        item.eta != null
                            ? '${item.progress.toStringAsFixed(0)}% • ${item.eta}'
                            : '${item.progress.toStringAsFixed(0)}%',
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: item.progress / 100,
                      backgroundColor: AppTheme.darkCardElevated,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        item.status == 'processing' ? AppTheme.accentOrange : AppTheme.primary,
                      ),
                      minHeight: 5,
                    ),
                  ),
                ],
              ),
            ),
          // Completed status bar
          if (item.isCompleted || item.isFailed)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              child: Row(
                children: [
                  Icon(_statusIcon(), color: _statusColor(), size: 14),
                  const SizedBox(width: 4),
                  Text(
                    item.isFailed
                        ? (item.error ?? 'Download failed')
                        : (item.formattedFileSize.isNotEmpty
                            ? 'Saved • ${item.formattedFileSize}'
                            : 'Download completed'),
                    style: TextStyle(color: _statusColor(), fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    if (item.isActive && onCancel != null) {
      return IconButton(
        icon: const Icon(Icons.close_rounded, color: AppTheme.error, size: 20),
        tooltip: 'Cancel',
        onPressed: onCancel,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      );
    }
    if (item.isCompleted) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onOpen != null)
            IconButton(
              icon: const Icon(Icons.folder_open_rounded, color: AppTheme.primary, size: 20),
              tooltip: 'Open',
              onPressed: onOpen,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.textHint, size: 20),
              tooltip: 'Delete',
              onPressed: onDelete,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
        ],
      );
    }
    if (onDelete != null) {
      return IconButton(
        icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.textHint, size: 20),
        tooltip: 'Delete',
        onPressed: onDelete,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _thumbnailPlaceholder() {
    return Container(
      width: 72,
      height: 50,
      decoration: BoxDecoration(
        color: AppTheme.darkCardElevated,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        item.isAudio ? Icons.music_note_rounded : Icons.play_circle_outline_rounded,
        color: AppTheme.textHint,
        size: 24,
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final String label;
  final bool isAudio;
  const _TypeBadge(this.label, this.isAudio);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        gradient: isAudio ? AppTheme.audioGradient : AppTheme.videoGradient,
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _QualityBadge extends StatelessWidget {
  final String label;
  const _QualityBadge(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: AppTheme.darkCardElevated,
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Text(
        label,
        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 9, fontWeight: FontWeight.w600),
      ),
    );
  }
}
