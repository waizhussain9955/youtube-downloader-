import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../bloc/download_bloc.dart';
import '../bloc/download_event.dart';
import '../bloc/download_state.dart';
import 'audio_download_screen.dart';
import 'video_download_screen.dart';
import 'bulk_download_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late final AnimationController _heroAnim;
  late final Animation<double> _heroFade;
  late final Animation<Offset> _heroSlide;

  final _screens = const [
    _HomeContent(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _heroAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _heroFade = CurvedAnimation(parent: _heroAnim, curve: Curves.easeOut);
    _heroSlide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _heroAnim, curve: Curves.easeOut));

    // Check backend connectivity on launch
    context.read<DownloadBloc>().add(CheckBackendEvent());
  }

  @override
  void dispose() {
    _heroAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppTheme.darkSurface,
          border: Border(top: BorderSide(color: AppTheme.darkBorder)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_rounded),
              activeIcon: Icon(Icons.history_rounded),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_rounded),
              activeIcon: Icon(Icons.settings_rounded),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'YT Downloader',
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            foreground: Paint()
                              ..shader = const LinearGradient(
                                colors: [AppTheme.primary, Color(0xFF9B59F5)],
                              ).createShader(const Rect.fromLTWH(0, 0, 200, 50)),
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Download YouTube content in any quality',
                          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Architecture Status Indicator
                  BlocBuilder<DownloadBloc, DownloadState>(
                    builder: (context, state) {
                      Color dotColor = AppTheme.textHint;
                      String statusText = 'Unknown';
                      String tooltip = 'Checking connection...';

                      if (state is BackendCheckingState) {
                        dotColor = AppTheme.accentOrange;
                        statusText = 'Checking';
                        tooltip = 'Checking backend connection...';
                      } else if (state is BackendOnlineState || state is VideoInfoLoadedState || state is ActiveDownloadsState || state is HistoryLoadedState) {
                        dotColor = AppTheme.success;
                        statusText = 'Connected';
                        tooltip = 'Connected to Backend Server';
                      } else if (state is BackendOfflineState) {
                        dotColor = AppTheme.error;
                        statusText = 'Offline';
                        tooltip = state.message;
                      }

                      return Tooltip(
                        message: tooltip,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: dotColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: dotColor.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: dotColor,
                                  shape: BoxShape.circle,
                                  boxShadow: [BoxShadow(color: dotColor, blurRadius: 6)],
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                statusText,
                                style: TextStyle(
                                  color: dotColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Action Cards
              Text(
                'What do you want to download?',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),

              // Audio Card
              _FeatureCard(
                title: 'Audio Download',
                subtitle: 'Save music & podcasts\nas MP3, M4A, OPUS, FLAC',
                icon: Icons.music_note_rounded,
                gradient: AppTheme.audioGradient,
                quality: 'Up to 320kbps',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AudioDownloadScreen()),
                ),
              ),
              const SizedBox(height: 14),

              // Video Card
              _FeatureCard(
                title: 'Video Download',
                subtitle: 'Save videos in HD,\n4K, or any resolution',
                icon: Icons.videocam_rounded,
                gradient: AppTheme.videoGradient,
                quality: 'Up to 4K',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const VideoDownloadScreen()),
                ),
              ),
              const SizedBox(height: 14),

              // Bulk Card
              _FeatureCard(
                title: 'Bulk Download',
                subtitle: 'Download multiple URLs\nat once with queue',
                icon: Icons.playlist_add_check_rounded,
                gradient: AppTheme.bulkGradient,
                quality: 'Up to 50 URLs',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BulkDownloadScreen()),
                ),
              ),

              const SizedBox(height: 32),
              // Stats row
              _StatsRow(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final LinearGradient gradient;
  final String quality;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.quality,
    required this.onTap,
  });

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.96,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = _anim;
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _anim.reverse(),
      onTapUp: (_) {
        _anim.forward();
        widget.onTap();
      },
      onTapCancel: () => _anim.forward(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppTheme.darkCard,
            border: Border.all(color: AppTheme.darkBorder),
            boxShadow: [
              BoxShadow(
                color: widget.gradient.colors.first.withValues(alpha: 0.08),
                blurRadius: 20,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon box
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: widget.gradient,
                  boxShadow: [
                    BoxShadow(
                      color: widget.gradient.colors.first.withValues(alpha: 0.4),
                      blurRadius: 12,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Icon(widget.icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              // Quality badge + arrow
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: widget.gradient,
                    ),
                    child: Text(
                      widget.quality,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Icon(Icons.arrow_forward_ios_rounded,
                      color: AppTheme.textHint, size: 14),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppTheme.darkCard,
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatItem('yt-dlp', '2026.06', Icons.star_rounded, AppTheme.accentOrange),
          _StatDivider(),
          _StatItem('Formats', '2000+', Icons.language_rounded, AppTheme.primary),
          _StatDivider(),
          _StatItem('Quality', '8K HDR', Icons.hd_rounded, AppTheme.accent),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatItem(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(
          color: color, fontSize: 14, fontWeight: FontWeight.w700,
        )),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(
          color: AppTheme.textHint, fontSize: 11,
        )),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 40, color: AppTheme.darkBorder);
  }
}
