import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

import '../models/download_item.dart';
import '../datasources/local_database.dart';

class DownloadRepository {
  final Dio _dio = Dio();
  final LocalDatabase _db = LocalDatabase();
  final _uuid = const Uuid();

  static const _mediaScannerChannel = MethodChannel('com.ytdownloader.yt_downloader/media_scanner');

  Future<void> _scanFile(String path) async {
    try {
      if (Platform.isAndroid) {
        await _mediaScannerChannel.invokeMethod('scanFile', {'path': path});
      }
    } catch (e) {
      // Ignored
    }
  }

  final Map<String, StreamController<DownloadItem>> _progressStreams = {};
  final Map<String, CancelToken> _activeTokens = {};

  Future<String> _getServerUrl() async {
    final prefs = await SharedPreferences.getInstance();
    String url = prefs.getString('server_url') ?? 'http://localhost:8000';
    // Ensure no trailing slash
    if (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    return url;
  }

  Future<bool> checkBackendHealth() async {
     try {
        final serverUrl = await _getServerUrl();
        final response = await _dio.get('$serverUrl/health', options: Options(
           sendTimeout: const Duration(seconds: 3),
           receiveTimeout: const Duration(seconds: 3),
        ));
        return response.statusCode == 200;
     } catch(e) {
        return false;
     }
  }

  Future<dynamic> _getBackendData(String url) async {
    final serverUrl = await _getServerUrl();
    try {
      final response = await _dio.get('$serverUrl/api/info', queryParameters: {'url': url}, options: Options(
        sendTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
      ));
      if (response.statusCode == 200 && response.data != null) {
        return response.data;
      }
    } catch (e) {
      throw Exception('Failed to connect to local backend at $serverUrl. Make sure the Python script is running! Error: ${e.toString()}');
    }
    throw Exception('Invalid response from backend.');
  }

  Future<VideoInfo> fetchVideoInfo(String url) async {
    try {
      final data = await _getBackendData(url);
      
      final List<FormatInfo> audioFormats = [];
      for (var stream in (data['audioStreams'] ?? [])) {
        audioFormats.add(FormatInfo(
          formatId: stream['formatId']?.toString() ?? '',
          ext: stream['ext'] ?? 'mp3',
          qualityLabel: stream['qualityLabel'] ?? 'Audio',
        ));
      }

      final List<FormatInfo> videoFormats = [];
      for (var stream in (data['videoStreams'] ?? [])) {
        videoFormats.add(FormatInfo(
          formatId: stream['formatId']?.toString() ?? '',
          ext: stream['ext'] ?? 'mp4',
          resolution: stream['resolution'] ?? 'Unknown',
          qualityLabel: stream['qualityLabel'] ?? 'Video',
        ));
      }

      if (videoFormats.isEmpty) {
         videoFormats.add(const FormatInfo(formatId: 'error', ext: 'mp4', qualityLabel: 'No Streams Found'));
      }

      return VideoInfo(
        title: data['title'] ?? 'YouTube Video',
        duration: data['duration'],
        thumbnail: data['thumbnailUrl'] ?? '',
        uploader: data['uploader'] ?? 'Unknown',
        audioFormats: audioFormats,
        videoFormats: videoFormats,
      );
    } catch (e) {
      throw Exception('Failed to fetch from backend: ${e.toString()}');
    }
  }

  Future<String> startAudioDownload({required String url, required String quality, String format = 'mp3'}) async {
    return _enqueueDownload(url: url, type: 'audio', quality: quality, ext: format);
  }

  Future<String> startVideoDownload({required String url, required String quality, String format = 'mp4'}) async {
    return _enqueueDownload(url: url, type: 'video', quality: quality, ext: format);
  }

  Future<Map<String, dynamic>> startBulkDownload({required List<String> urls, required String downloadType, String quality = 'best', String format = 'mp4'}) async {
    final List<Map<String, dynamic>> jobs = [];
    int queued = 0;
    for (final url in urls) {
      final jobId = await _enqueueDownload(url: url, type: downloadType, quality: quality, ext: format);
      jobs.add({'job_id': jobId, 'url': url});
      queued++;
    }
    return {'queued': queued, 'failed': 0, 'jobs': jobs};
  }

  Future<String> _enqueueDownload({required String url, required String type, required String quality, required String ext}) async {
    final jobId = _uuid.v4();
    var item = DownloadItem(
      jobId: jobId, url: url, title: 'Fetching Info from Local Backend...', downloadType: type, quality: quality, status: 'queued', createdAt: DateTime.now().toIso8601String(),
    );
    item = item.copyWith(id: await _db.insertItem(item));
    _executeDownload(item, ext);
    return jobId;
  }

  Future<void> _executeDownload(DownloadItem initialItem, String requestedExt) async {
    var item = initialItem.copyWith(status: 'processing');
    _broadcast(item);
    
    final cancelToken = CancelToken();
    _activeTokens[item.jobId] = cancelToken;

    try {
      final data = await _getBackendData(item.url);
      final title = data['title'] ?? 'YouTube_Video';
      
      item = item.copyWith(
        title: title,
        thumbnail: data['thumbnailUrl'] ?? '',
      );
      _broadcast(item);

      // Find stream URL
      String? streamUrl;
      if (item.downloadType == 'audio') {
        final streams = data['audioStreams'] as List<dynamic>?;
        if (streams != null && streams.isNotEmpty) {
           streamUrl = streams.first['url'];
           requestedExt = streams.first['ext'] ?? requestedExt;
        }
      } else {
        final streams = data['videoStreams'] as List<dynamic>?;
        if (streams != null && streams.isNotEmpty) {
           streamUrl = streams.first['url'];
           requestedExt = streams.first['ext'] ?? requestedExt;
        }
      }

      if (streamUrl == null) throw Exception('No suitable stream found for this video. Note: yt-dlp might need an update.');

      final safeTitle = title.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
      final filename = '${safeTitle}_${item.jobId.substring(0, 5)}.$requestedExt';

      // Force Save into Public Gallery folder
      Directory? dir;
      if (Platform.isAndroid) {
        dir = Directory('/storage/emulated/0/Download/YTDownloader');
        if (!await dir.exists()) {
          try {
             await dir.create(recursive: true);
          } catch(e) {
             dir = Directory('/storage/emulated/0/Download');
          }
        }
      } else {
        dir = await getApplicationDocumentsDirectory();
      }
      
      final filePath = '${dir!.path}/$filename';

      item = item.copyWith(status: 'downloading', filename: filename, filePath: filePath, fileSize: 0);
      _broadcast(item);

      final serverUrl = await _getServerUrl();
      final downloadUrl = '$serverUrl/api/proxy?url=${Uri.encodeComponent(streamUrl)}';

      final startTime = DateTime.now();
      await _dio.download(
        downloadUrl, filePath, cancelToken: cancelToken,
        options: Options(
          headers: {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
          }
        ),
        onReceiveProgress: (received, total) {
          final progress = total > 0 ? (received / total) * 100 : 0.0;
          final elapsed = DateTime.now().difference(startTime).inSeconds;
          String speedStr = '', etaStr = 'Downloading...';
          if (elapsed > 0) {
            final bps = received / elapsed;
            speedStr = '${(bps / 1024 / 1024).toStringAsFixed(2)} MB/s';
            if (total > 0) {
              final remainingBytes = total - received;
              etaStr = '${(remainingBytes / bps).toInt()}s remaining';
            }
          }
          item = item.copyWith(
            progress: progress > 0 ? progress : item.progress, speed: speedStr, eta: etaStr, fileSize: total > 0 ? total : item.fileSize,
          );
          _broadcast(item);
        },
      );

      item = item.copyWith(status: 'completed', progress: 100, completedAt: DateTime.now().toIso8601String());
      await _scanFile(filePath);

    } on DioException catch (e) {
      item = item.copyWith(status: CancelToken.isCancel(e) ? 'cancelled' : 'failed', error: e.message);
    } catch (e) {
      item = item.copyWith(status: 'failed', error: e.toString());
    } finally {
      _activeTokens.remove(item.jobId);
      _broadcast(item);
      await _db.updateItem(item);
    }
  }

  void _broadcast(DownloadItem item) => _progressStreams[item.jobId]?.add(item);
  Future<bool> cancelDownload(String jobId) async {
    if (_activeTokens.containsKey(jobId)) { _activeTokens[jobId]!.cancel(); _activeTokens.remove(jobId); return true; }
    return false;
  }
  Future<List<DownloadItem>> getHistory({int limit=50, int offset=0, String? search, String? type}) async => await _db.getHistory(search: search, type: type);
  Future<bool> deleteHistoryItem(int id) async { await _db.deleteItem(id); return true; }
  Future<bool> clearHistory() async { await _db.clearHistory(); return true; }
  Future<List<DownloadItem>> getActiveDownloads() async => await _db.getActiveDownloads();
  Stream<DownloadItem> watchDownloadProgress(String jobId, DownloadItem initial) {
    if (!_progressStreams.containsKey(jobId)) _progressStreams[jobId] = StreamController<DownloadItem>.broadcast();
    return _progressStreams[jobId]!.stream;
  }
}
