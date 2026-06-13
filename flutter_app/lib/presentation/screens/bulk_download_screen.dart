import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../bloc/download_bloc.dart';
import '../bloc/download_event.dart';
import '../bloc/download_state.dart';
import '../widgets/download_card.dart';

class BulkDownloadScreen extends StatefulWidget {
  const BulkDownloadScreen({super.key});

  @override
  State<BulkDownloadScreen> createState() => _BulkDownloadScreenState();
}

class _BulkDownloadScreenState extends State<BulkDownloadScreen>
    with SingleTickerProviderStateMixin {
  final _urlsController = TextEditingController();
  late final TabController _tabController;
  String _selectedAudioQuality = '192';
  String _selectedVideoQuality = '720';
  final List<Map<String, dynamic>> _jobs = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _urlsController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _urlsController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  List<String> get _validUrls {
    return _urlsController.text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty && (l.contains('youtube.com') || l.contains('youtu.be')))
        .toList();
  }

  void _startBulkDownload(bool isAudio) {
    final urls = _validUrls;
    if (urls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one valid YouTube URL')),
      );
      return;
    }
    final quality = isAudio ? _selectedAudioQuality : _selectedVideoQuality;
    context.read<DownloadBloc>().add(StartBulkDownloadEvent(
      urls: urls,
      downloadType: isAudio ? 'audio' : 'video',
      quality: quality,
      format: isAudio ? 'mp3' : 'mp4',
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_rounded, color: AppTheme.textPrimary),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: AppTheme.bulkGradient,
                      ),
                      child: const Icon(Icons.playlist_add_check_rounded, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bulk Download',
                          style: TextStyle(
                              color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                        Text('Download multiple URLs at once',
                            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(color: AppTheme.darkBorder, height: 1),

              // Tab bar
              Container(
                color: AppTheme.darkSurface,
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: AppTheme.accentGreen,
                  indicatorWeight: 3,
                  labelColor: AppTheme.accentGreen,
                  unselectedLabelColor: AppTheme.textHint,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  tabs: const [
                    Tab(icon: Icon(Icons.music_note_rounded, size: 18), text: 'Bulk Audio'),
                    Tab(icon: Icon(Icons.videocam_rounded, size: 18), text: 'Bulk Video'),
                  ],
                ),
              ),

              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _BulkTab(
                      urlsController: _urlsController,
                      isAudio: true,
                      selectedQuality: _selectedAudioQuality,
                      onQualityChanged: (q) => setState(() => _selectedAudioQuality = q),
                      onDownload: () => _startBulkDownload(true),
                      validCount: _validUrls.length,
                      jobs: _jobs,
                    ),
                    _BulkTab(
                      urlsController: _urlsController,
                      isAudio: false,
                      selectedQuality: _selectedVideoQuality,
                      onQualityChanged: (q) => setState(() => _selectedVideoQuality = q),
                      onDownload: () => _startBulkDownload(false),
                      validCount: _validUrls.length,
                      jobs: _jobs,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BulkTab extends StatelessWidget {
  final TextEditingController urlsController;
  final bool isAudio;
  final String selectedQuality;
  final ValueChanged<String> onQualityChanged;
  final VoidCallback onDownload;
  final int validCount;
  final List<Map<String, dynamic>> jobs;

  const _BulkTab({
    required this.urlsController,
    required this.isAudio,
    required this.selectedQuality,
    required this.onQualityChanged,
    required this.onDownload,
    required this.validCount,
    required this.jobs,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = isAudio ? AppTheme.audioGradient : AppTheme.videoGradient;
    final accentColor = isAudio ? AppTheme.primary : AppTheme.accent;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // URL Text Area
          const Row(
            children: [
              Icon(Icons.list_rounded, color: AppTheme.accentGreen, size: 18),
              SizedBox(width: 8),
              Text('YouTube URLs (one per line)',
                  style: TextStyle(
                      color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: AppTheme.darkCard,
              border: Border.all(color: AppTheme.darkBorder),
            ),
            child: TextField(
              controller: urlsController,
              maxLines: 8,
              style: const TextStyle(
                  color: AppTheme.textPrimary, fontSize: 13, height: 1.7, fontFamily: 'monospace'),
              decoration: InputDecoration(
                hintText:
                    'https://youtube.com/watch?v=...\nhttps://youtu.be/...\nhttps://youtube.com/watch?v=...',
                hintStyle: const TextStyle(color: AppTheme.textHint, fontSize: 12),
                filled: false,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // URL count badge
          StatefulBuilder(builder: (ctx, setS) {
            return Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: validCount > 0 ? AppTheme.accentGreen.withValues(alpha: 0.15) : AppTheme.darkCard,
                    border: Border.all(
                      color: validCount > 0 ? AppTheme.accentGreen.withValues(alpha: 0.4) : AppTheme.darkBorder,
                    ),
                  ),
                  child: Text(
                    '$validCount valid URL${validCount != 1 ? 's' : ''} detected',
                    style: TextStyle(
                      color: validCount > 0 ? AppTheme.accentGreen : AppTheme.textHint,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 24),

          // Quality selector
          Row(
            children: [
              Icon(
                isAudio ? Icons.equalizer_rounded : Icons.hd_rounded,
                color: accentColor,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                isAudio ? 'Audio Quality' : 'Video Resolution',
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (isAudio ? ['64', '128', '192', '320'] : ['360', '480', '720', '1080'])
                .map((opt) {
              final isSelected = opt == selectedQuality;
              return GestureDetector(
                onTap: () => onQualityChanged(opt),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: isSelected ? gradient : null,
                    color: isSelected ? null : AppTheme.darkCard,
                    border: Border.all(
                      color: isSelected ? Colors.transparent : AppTheme.darkBorder,
                    ),
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
          const SizedBox(height: 28),

          // Download Button
          BlocConsumer<DownloadBloc, DownloadState>(
            listener: (context, state) {
              if (state is BulkDownloadStartedState) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Row(children: [
                    const Icon(Icons.playlist_add_check_rounded, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text('${state.queued} downloads queued'
                        '${state.failed > 0 ? ', ${state.failed} failed' : ''}'),
                  ]),
                  backgroundColor: AppTheme.accentGreen,
                  duration: const Duration(seconds: 4),
                ));
                urlsController.clear();
              } else if (state is DownloadStartErrorState) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppTheme.error,
                ));
              }
            },
            builder: (context, state) {
              final isLoading = state is BulkDownloadStartingState;
              return SizedBox(
                width: double.infinity,
                height: 54,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: gradient,
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: isLoading ? null : onDownload,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isAudio ? Icons.music_note_rounded : Icons.videocam_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                isAudio ? 'Download All Audio' : 'Download All Videos',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppTheme.info.withValues(alpha: 0.07),
              border: Border.all(color: AppTheme.info.withValues(alpha: 0.2)),
            ),
            child: const Row(
              children: [
                Icon(Icons.queue_music_rounded, color: AppTheme.info, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Up to 50 URLs supported. Downloads are queued and processed 3 at a time.',
                    style: TextStyle(color: AppTheme.info, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          BlocBuilder<DownloadBloc, DownloadState>(
            builder: (context, state) {
              if (state is ActiveDownloadsState) {
                final bulkItems = state.items.where((i) => i.downloadType == (isAudio ? 'audio' : 'video')).toList();
                if (bulkItems.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Active Downloads',
                        style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    ...bulkItems.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: DownloadCard(
                        item: item,
                        onCancel: item.isActive
                            ? () => context.read<DownloadBloc>()
                                .add(CancelDownloadEvent(item.jobId))
                            : null,
                      ),
                    )),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}
