import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../bloc/download_bloc.dart';
import '../bloc/download_event.dart';
import '../bloc/download_state.dart';
import '../widgets/download_card.dart';
import '../../data/models/download_item.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _searchController = TextEditingController();
  String? _filterType; // null = all, 'audio', 'video'

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    context.read<DownloadBloc>().add(LoadHistoryEvent(
      search: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
      type: _filterType,
    ));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Download History',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_sweep_rounded, color: AppTheme.error),
                    tooltip: 'Clear All',
                    onPressed: () => _showClearConfirm(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => _loadHistory(),
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search downloads...',
                  hintStyle: const TextStyle(color: AppTheme.textHint, fontSize: 14),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textHint, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, color: AppTheme.textHint, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            _loadHistory();
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppTheme.darkCard,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.darkBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.darkBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Filter chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _FilterChip(
                    label: 'All',
                    selected: _filterType == null,
                    onTap: () {
                      setState(() => _filterType = null);
                      _loadHistory();
                    },
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: '🎵 Audio',
                    selected: _filterType == 'audio',
                    onTap: () {
                      setState(() => _filterType = _filterType == 'audio' ? null : 'audio');
                      _loadHistory();
                    },
                    activeColor: AppTheme.primary,
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: '🎬 Video',
                    selected: _filterType == 'video',
                    onTap: () {
                      setState(() => _filterType = _filterType == 'video' ? null : 'video');
                      _loadHistory();
                    },
                    activeColor: AppTheme.accent,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, color: AppTheme.textHint, size: 20),
                    onPressed: _loadHistory,
                    tooltip: 'Refresh',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Divider(color: AppTheme.darkBorder, height: 1),

            // Content
            Expanded(
              child: BlocBuilder<DownloadBloc, DownloadState>(
                buildWhen: (previous, current) =>
                    current is HistoryLoadingState ||
                    current is HistoryErrorState ||
                    current is HistoryLoadedState,
                builder: (context, state) {
                  if (state is HistoryLoadingState) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppTheme.primary),
                    );
                  }
                  if (state is HistoryErrorState) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.wifi_off_rounded, color: AppTheme.error, size: 48),
                          const SizedBox(height: 16),
                          Text(state.message,
                              style: const TextStyle(color: AppTheme.textSecondary),
                              textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _loadHistory,
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }
                  if (state is HistoryLoadedState) {
                    if (state.items.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.primary.withValues(alpha: 0.1),
                              ),
                              child: const Icon(Icons.history_rounded,
                                  color: AppTheme.primary, size: 40),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No downloads yet',
                              style: TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Your download history will appear here',
                              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: state.items.length,
                      itemBuilder: (context, index) {
                        final item = state.items[index];
                        return DownloadCard(
                          item: item,
                          onDelete: item.id != null
                              ? () => _confirmDelete(context, item)
                              : null,
                          onOpen: item.isCompleted && item.filePath != null
                              ? () => _openFile(item)
                              : null,
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, DownloadItem item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.darkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Entry', style: TextStyle(color: AppTheme.textPrimary)),
        content: Text(
          'Remove "${item.title}" from history?',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () {
              Navigator.pop(context);
              context.read<DownloadBloc>().add(DeleteHistoryItemEvent(item.id!));
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showClearConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.darkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear All History', style: TextStyle(color: AppTheme.textPrimary)),
        content: const Text(
          'This will remove all download history entries. The actual files on disk are not affected.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () {
              Navigator.pop(context);
              context.read<DownloadBloc>().add(ClearHistoryEvent());
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _openFile(DownloadItem item) {
    // Would use open_file package to open the file
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('File saved at: ${item.filePath}'),
        backgroundColor: AppTheme.darkCard,
        action: SnackBarAction(
          label: 'OK',
          textColor: AppTheme.primary,
          onPressed: () {},
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color activeColor;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.activeColor = AppTheme.primary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: selected ? activeColor.withValues(alpha: 0.2) : AppTheme.darkCard,
          border: Border.all(
            color: selected ? activeColor : AppTheme.darkBorder,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? activeColor : AppTheme.textSecondary,
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
