import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/download_repository.dart';
import 'presentation/bloc/download_bloc.dart';
import 'presentation/screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait orientation
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style for dark theme
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppTheme.darkSurface,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(const YTDownloaderApp());
}

class YTDownloaderApp extends StatelessWidget {
  const YTDownloaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => DownloadRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<DownloadBloc>(
            create: (context) => DownloadBloc(
              repo: context.read<DownloadRepository>(),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'YT Downloader',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          home: const HomeScreen(),
        ),
      ),
    );
  }
}
