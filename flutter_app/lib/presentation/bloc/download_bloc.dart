import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/download_repository.dart';
import '../../data/models/download_item.dart';
import 'download_event.dart';
import 'download_state.dart';

class DownloadBloc extends Bloc<DownloadEvent, DownloadState> {
  final DownloadRepository _repo;
  final Map<String, StreamSubscription> _wsSubscriptions = {};
  final Map<String, DownloadItem> _activeDownloads = {};

  DownloadBloc({DownloadRepository? repo})
      : _repo = repo ?? DownloadRepository(),
        super(DownloadInitial()) {
    on<CheckBackendEvent>(_onCheckBackend);
    on<FetchVideoInfoEvent>(_onFetchVideoInfo);
    on<ResetVideoInfoEvent>((_, emit) => emit(DownloadInitial()));
    on<StartAudioDownloadEvent>(_onStartAudio);
    on<StartVideoDownloadEvent>(_onStartVideo);
    on<StartBulkDownloadEvent>(_onStartBulk);
    on<CancelDownloadEvent>(_onCancel);
    on<LoadHistoryEvent>(_onLoadHistory);
    on<DeleteHistoryItemEvent>(_onDeleteHistory);
    on<ClearHistoryEvent>(_onClearHistory);
    on<UpdateDownloadProgressEvent>(_onUpdateProgress);
  }

  Future<void> _onCheckBackend(
    CheckBackendEvent event, Emitter<DownloadState> emit,
  ) async {
    emit(BackendCheckingState());
    final ok = await _repo.checkBackendHealth();
    if (ok) {
      emit(BackendOnlineState());
    } else {
      emit(const BackendOfflineState(
        'Cannot connect to backend. Make sure the server is running on port 8000.',
      ));
    }
  }

  Future<void> _onFetchVideoInfo(
    FetchVideoInfoEvent event, Emitter<DownloadState> emit,
  ) async {
    emit(VideoInfoLoadingState());
    try {
      final info = await _repo.fetchVideoInfo(event.url);
      emit(VideoInfoLoadedState(info));
    } catch (e) {
      emit(VideoInfoErrorState(_parseError(e)));
    }
  }

  Future<void> _onStartAudio(
    StartAudioDownloadEvent event, Emitter<DownloadState> emit,
  ) async {
    emit(DownloadStartingState());
    try {
      final info = await _repo.fetchVideoInfo(event.url);
      final jobId = await _repo.startAudioDownload(
        url: event.url,
        quality: event.quality,
        format: event.format,
      );
      final item = DownloadItem(
        jobId: jobId,
        url: event.url,
        title: info.title,
        thumbnail: info.thumbnail,
        downloadType: 'audio',
        quality: event.quality,
        status: 'queued',
        duration: info.duration,
        createdAt: DateTime.now().toIso8601String(),
      );
      emit(DownloadStartedState(jobId: jobId, title: info.title));
      _subscribeToProgress(item);
    } catch (e) {
      emit(DownloadStartErrorState(_parseError(e)));
    }
  }

  Future<void> _onStartVideo(
    StartVideoDownloadEvent event, Emitter<DownloadState> emit,
  ) async {
    emit(DownloadStartingState());
    try {
      final info = await _repo.fetchVideoInfo(event.url);
      final jobId = await _repo.startVideoDownload(
        url: event.url,
        quality: event.quality,
        format: event.format,
      );
      final item = DownloadItem(
        jobId: jobId,
        url: event.url,
        title: info.title,
        thumbnail: info.thumbnail,
        downloadType: 'video',
        quality: event.quality,
        status: 'queued',
        duration: info.duration,
        createdAt: DateTime.now().toIso8601String(),
      );
      emit(DownloadStartedState(jobId: jobId, title: info.title));
      _subscribeToProgress(item);
    } catch (e) {
      emit(DownloadStartErrorState(_parseError(e)));
    }
  }

  Future<void> _onStartBulk(
    StartBulkDownloadEvent event, Emitter<DownloadState> emit,
  ) async {
    emit(BulkDownloadStartingState());
    try {
      final result = await _repo.startBulkDownload(
        urls: event.urls,
        downloadType: event.downloadType,
        quality: event.quality,
        format: event.format,
      );
      final jobs = result['jobs'] as List;
      // Subscribe to each queued job
      for (final job in jobs) {
        if (job['job_id'] != null) {
          final item = DownloadItem(
            jobId: job['job_id'],
            url: job['url'] ?? '',
            title: job['title'] ?? 'Unknown',
            downloadType: event.downloadType,
            quality: event.quality,
            status: 'queued',
            createdAt: DateTime.now().toIso8601String(),
          );
          _subscribeToProgress(item);
        }
      }
      emit(BulkDownloadStartedState(
        queued: result['queued'] as int,
        failed: result['failed'] as int,
        jobs: jobs,
      ));
    } catch (e) {
      emit(DownloadStartErrorState(_parseError(e)));
    }
  }

  Future<void> _onCancel(
    CancelDownloadEvent event, Emitter<DownloadState> emit,
  ) async {
    _wsSubscriptions[event.jobId]?.cancel();
    _wsSubscriptions.remove(event.jobId);
    await _repo.cancelDownload(event.jobId);
    emit(DownloadCancelledState(event.jobId));
  }

  Future<void> _onLoadHistory(
    LoadHistoryEvent event, Emitter<DownloadState> emit,
  ) async {
    emit(HistoryLoadingState());
    try {
      final items = await _repo.getHistory(search: event.search, type: event.type);
      emit(HistoryLoadedState(items));
    } catch (e) {
      emit(HistoryErrorState(_parseError(e)));
    }
  }

  Future<void> _onDeleteHistory(
    DeleteHistoryItemEvent event, Emitter<DownloadState> emit,
  ) async {
    await _repo.deleteHistoryItem(event.id);
    add(const LoadHistoryEvent());
  }

  Future<void> _onClearHistory(
    ClearHistoryEvent event, Emitter<DownloadState> emit,
  ) async {
    await _repo.clearHistory();
    emit(const HistoryLoadedState([]));
  }

  void _onUpdateProgress(
    UpdateDownloadProgressEvent event, Emitter<DownloadState> emit,
  ) {
    if (event.item.isCompleted || event.item.status == 'failed' || event.item.status == 'cancelled') {
      _activeDownloads.remove(event.item.jobId);
    } else {
      _activeDownloads[event.item.jobId] = event.item;
    }
    emit(ActiveDownloadsState(_activeDownloads.values.toList()));
  }

  void _subscribeToProgress(DownloadItem initial) {
    final stream = _repo.watchDownloadProgress(initial.jobId, initial);
    final sub = stream.listen(
      (item) => add(UpdateDownloadProgressEvent(item)),
      onError: (_) {},
    );
    _wsSubscriptions[initial.jobId] = sub;
  }

  String _parseError(dynamic e) {
    final msg = e.toString();
    if (msg.contains('SocketException') || msg.contains('Connection refused')) {
      return 'Check your internet connection.';
    }
    if (msg.contains('VideoUnplayableException')) return 'This video cannot be played or downloaded.';
    if (msg.contains('VideoRequiresPurchaseException')) return 'This video requires payment to download.';
    if (msg.contains('404')) return 'Video not found or unavailable.';
    if (msg.contains('403')) return 'This video is private or age-restricted.';
    if (msg.contains('400')) {
      final detail = _extractDetail(msg);
      return detail ?? 'Invalid URL or unsupported video.';
    }
    return msg.length > 120 ? '${msg.substring(0, 120)}...' : msg;
  }

  String? _extractDetail(String msg) {
    final match = RegExp(r'"detail":"([^"]+)"').firstMatch(msg);
    return match?.group(1);
  }

  @override
  Future<void> close() {
    for (final sub in _wsSubscriptions.values) {
      sub.cancel();
    }
    return super.close();
  }
}
