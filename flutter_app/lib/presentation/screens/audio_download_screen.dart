import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../bloc/download_bloc.dart';
import '../bloc/download_event.dart';
import '../bloc/download_state.dart';
import '../widgets/url_input_field.dart';
import '../widgets/quality_selector.dart';
import '../widgets/download_card.dart';
import '../../data/models/download_item.dart';

class AudioDownloadScreen extends StatefulWidget {
  const AudioDownloadScreen({super.key});

  @override
  State<AudioDownloadScreen> createState() => _AudioDownloadScreenState();
}

class _AudioDownloadScreenState extends State<AudioDownloadScreen> {
  final _urlController = TextEditingController();
  String _selectedQuality = '192';
  String _selectedFormat = 'mp3';
  final List<DownloadItem> _activeDownloads = [];

  final _formats = ['mp3', 'm4a', 'opus', 'flac'];

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _startDownload() {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a YouTube URL')),
      );
      return;
    }
    context.read<DownloadBloc>().add(StartAudioDownloadEvent(
      url: url,
      quality: _selectedQuality,
      format: _selectedFormat,
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
                        gradient: AppTheme.audioGradient,
                      ),
                      child: const Icon(Icons.music_note_rounded, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Audio Download',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Text(
                          'Extract audio from YouTube',
                          style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(color: AppTheme.darkBorder, height: 1),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // URL Input
                      UrlInputField(
                        controller: _urlController,
                        hint: 'Paste YouTube URL here...',
                        onSubmitted: (_) => _startDownload(),
                      ),
                      const SizedBox(height: 24),

                      // Quality Selector
                      StaticQualitySelector(
                        isAudio: true,
                        selected: _selectedQuality,
                        onChanged: (q) => setState(() => _selectedQuality = q),
                      ),
                      const SizedBox(height: 24),

                      // Format Selector
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.audio_file_rounded, color: AppTheme.primary, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Output Format',
                                style: TextStyle(
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
                            children: _formats.map((fmt) {
                              final isSelected = fmt == _selectedFormat;
                              return GestureDetector(
                                onTap: () => setState(() => _selectedFormat = fmt),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18, vertical: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: isSelected
                                        ? AppTheme.primary.withValues(alpha: 0.2)
                                        : AppTheme.darkCard,
                                    border: Border.all(
                                      color: isSelected ? AppTheme.primary : AppTheme.darkBorder,
                                      width: isSelected ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Text(
                                    fmt.toUpperCase(),
                                    style: TextStyle(
                                      color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Download Button
                      BlocConsumer<DownloadBloc, DownloadState>(
                        listener: (context, state) {
                          if (state is DownloadStartedState) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.download_rounded, color: Colors.white, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text('Downloading: ${state.title}')),
                                ],
                              ),
                              backgroundColor: AppTheme.primary,
                              duration: const Duration(seconds: 3),
                            ));
                            _urlController.clear();
                          } else if (state is DownloadStartErrorState) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(state.message),
                              backgroundColor: AppTheme.error,
                            ));
                          } else if (state is UpdateDownloadProgressEvent) {
                            // handled below
                          }
                        },
                        builder: (context, state) {
                          final isLoading = state is DownloadStartingState;
                          return SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                gradient: AppTheme.audioGradient,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primary.withValues(alpha: 0.4),
                                    blurRadius: 16,
                                    spreadRadius: 0,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: isLoading ? null : _startDownload,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14)),
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.download_rounded, color: Colors.white, size: 22),
                                          SizedBox(width: 10),
                                          Text(
                                            'Download Audio',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 28),

                      // Active Downloads Section
                      BlocBuilder<DownloadBloc, DownloadState>(
                        builder: (context, state) {
                          if (state is ActiveDownloadsState) {
                            final audioItems = state.items
                                .where((i) => i.isAudio)
                                .toList();
                            if (audioItems.isEmpty) return const SizedBox.shrink();
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Active Downloads',
                                  style: TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ...audioItems.map((item) => Padding(
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
