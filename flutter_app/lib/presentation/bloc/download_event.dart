import 'package:equatable/equatable.dart';
import '../../../data/models/download_item.dart';

abstract class DownloadEvent extends Equatable {
  const DownloadEvent();
  @override
  List<Object?> get props => [];
}

class FetchVideoInfoEvent extends DownloadEvent {
  final String url;
  const FetchVideoInfoEvent(this.url);
  @override
  List<Object?> get props => [url];
}

class StartAudioDownloadEvent extends DownloadEvent {
  final String url;
  final String quality;
  final String format;
  const StartAudioDownloadEvent({
    required this.url,
    required this.quality,
    this.format = 'mp3',
  });
  @override
  List<Object?> get props => [url, quality, format];
}

class StartVideoDownloadEvent extends DownloadEvent {
  final String url;
  final String quality;
  final String format;
  const StartVideoDownloadEvent({
    required this.url,
    required this.quality,
    this.format = 'mp4',
  });
  @override
  List<Object?> get props => [url, quality, format];
}

class StartBulkDownloadEvent extends DownloadEvent {
  final List<String> urls;
  final String downloadType;
  final String quality;
  final String format;
  const StartBulkDownloadEvent({
    required this.urls,
    required this.downloadType,
    this.quality = 'best',
    this.format = 'mp4',
  });
  @override
  List<Object?> get props => [urls, downloadType, quality, format];
}

class UpdateDownloadProgressEvent extends DownloadEvent {
  final DownloadItem item;
  const UpdateDownloadProgressEvent(this.item);
  @override
  List<Object?> get props => [item];
}

class CancelDownloadEvent extends DownloadEvent {
  final String jobId;
  const CancelDownloadEvent(this.jobId);
  @override
  List<Object?> get props => [jobId];
}

class LoadHistoryEvent extends DownloadEvent {
  final String? search;
  final String? type;
  const LoadHistoryEvent({this.search, this.type});
  @override
  List<Object?> get props => [search, type];
}

class DeleteHistoryItemEvent extends DownloadEvent {
  final int id;
  const DeleteHistoryItemEvent(this.id);
  @override
  List<Object?> get props => [id];
}

class ClearHistoryEvent extends DownloadEvent {}

class CheckBackendEvent extends DownloadEvent {}

class ResetVideoInfoEvent extends DownloadEvent {}
