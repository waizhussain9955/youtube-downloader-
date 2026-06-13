import 'package:equatable/equatable.dart';
import '../../../data/models/download_item.dart';

abstract class DownloadState extends Equatable {
  const DownloadState();
  @override
  List<Object?> get props => [];
}

class DownloadInitial extends DownloadState {}

// Backend
class BackendCheckingState extends DownloadState {}
class BackendOnlineState extends DownloadState {}
class BackendOfflineState extends DownloadState {
  final String message;
  const BackendOfflineState(this.message);
  @override
  List<Object?> get props => [message];
}

// Video Info
class VideoInfoLoadingState extends DownloadState {}
class VideoInfoLoadedState extends DownloadState {
  final VideoInfo info;
  const VideoInfoLoadedState(this.info);
  @override
  List<Object?> get props => [info];
}
class VideoInfoErrorState extends DownloadState {
  final String message;
  const VideoInfoErrorState(this.message);
  @override
  List<Object?> get props => [message];
}

// Download Start
class DownloadStartingState extends DownloadState {}
class DownloadStartedState extends DownloadState {
  final String jobId;
  final String title;
  const DownloadStartedState({required this.jobId, required this.title});
  @override
  List<Object?> get props => [jobId, title];
}
class DownloadStartErrorState extends DownloadState {
  final String message;
  const DownloadStartErrorState(this.message);
  @override
  List<Object?> get props => [message];
}

// Active Downloads
class ActiveDownloadsState extends DownloadState {
  final List<DownloadItem> items;
  const ActiveDownloadsState(this.items);
  @override
  List<Object?> get props => [items];
}

// History
class HistoryLoadingState extends DownloadState {}
class HistoryLoadedState extends DownloadState {
  final List<DownloadItem> items;
  const HistoryLoadedState(this.items);
  @override
  List<Object?> get props => [items];
}
class HistoryErrorState extends DownloadState {
  final String message;
  const HistoryErrorState(this.message);
  @override
  List<Object?> get props => [message];
}

// Bulk
class BulkDownloadStartingState extends DownloadState {}
class BulkDownloadStartedState extends DownloadState {
  final int queued;
  final int failed;
  final List<dynamic> jobs;
  const BulkDownloadStartedState({
    required this.queued,
    required this.failed,
    required this.jobs,
  });
  @override
  List<Object?> get props => [queued, failed];
}

// Cancel
class DownloadCancelledState extends DownloadState {
  final String jobId;
  const DownloadCancelledState(this.jobId);
  @override
  List<Object?> get props => [jobId];
}
