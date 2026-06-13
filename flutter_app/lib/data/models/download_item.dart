import 'dart:convert';

class DownloadItem {
  final String jobId;
  final String url;
  final String title;
  final String? thumbnail;
  final String downloadType; // 'audio' or 'video'
  final String quality;
  final String status;
  final double progress;
  final String? speed;
  final String? eta;
  final String? filename;
  final String? filePath;
  final int? fileSize;
  final int? duration;
  final String? error;
  final String createdAt;
  final String? completedAt;
  final int? id; // DB id

  const DownloadItem({
    required this.jobId,
    required this.url,
    required this.title,
    this.thumbnail,
    required this.downloadType,
    required this.quality,
    required this.status,
    this.progress = 0.0,
    this.speed,
    this.eta,
    this.filename,
    this.filePath,
    this.fileSize,
    this.duration,
    this.error,
    required this.createdAt,
    this.completedAt,
    this.id,
  });

  DownloadItem copyWith({
    String? status,
    double? progress,
    String? speed,
    String? eta,
    String? filename,
    String? filePath,
    int? fileSize,
    int? duration,
    String? error,
    String? completedAt,
    String? title,
    String? thumbnail,
    int? id,
  }) {
    return DownloadItem(
      jobId: jobId,
      url: url,
      title: title ?? this.title,
      thumbnail: thumbnail ?? this.thumbnail,
      downloadType: downloadType,
      quality: quality,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      speed: speed ?? this.speed,
      eta: eta ?? this.eta,
      filename: filename ?? this.filename,
      filePath: filePath ?? this.filePath,
      fileSize: fileSize ?? this.fileSize,
      duration: duration ?? this.duration,
      error: error ?? this.error,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
      id: id ?? this.id,
    );
  }

  factory DownloadItem.fromJson(Map<String, dynamic> json) {
    return DownloadItem(
      jobId: json['job_id'] ?? '',
      url: json['url'] ?? '',
      title: json['title'] ?? 'Unknown',
      thumbnail: json['thumbnail'],
      downloadType: json['download_type'] ?? 'video',
      quality: json['quality'] ?? 'best',
      status: json['status'] ?? 'queued',
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      speed: json['speed'],
      eta: json['eta'],
      filename: json['filename'],
      filePath: json['file_path'],
      fileSize: json['file_size'],
      duration: json['duration'],
      error: json['error'],
      createdAt: json['created_at'] ?? DateTime.now().toIso8601String(),
      completedAt: json['completed_at'],
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() => {
    'job_id': jobId,
    'url': url,
    'title': title,
    'thumbnail': thumbnail,
    'download_type': downloadType,
    'quality': quality,
    'status': status,
    'progress': progress,
    'speed': speed,
    'eta': eta,
    'filename': filename,
    'file_path': filePath,
    'file_size': fileSize,
    'duration': duration,
    'error': error,
    'created_at': createdAt,
    'completed_at': completedAt,
    'id': id,
  };

  bool get isActive => ['queued', 'downloading', 'processing'].contains(status);
  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
  bool get isCancelled => status == 'cancelled';
  bool get isAudio => downloadType == 'audio';

  String get formattedFileSize {
    if (fileSize == null) return '';
    if (fileSize! > 1024 * 1024 * 1024) {
      return '${(fileSize! / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    } else if (fileSize! > 1024 * 1024) {
      return '${(fileSize! / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else if (fileSize! > 1024) {
      return '${(fileSize! / 1024).toStringAsFixed(1)} KB';
    }
    return '$fileSize B';
  }

  String get formattedDuration {
    if (duration == null) return '';
    final hours = duration! ~/ 3600;
    final mins = (duration! % 3600) ~/ 60;
    final secs = duration! % 60;
    if (hours > 0) {
      return '${hours}h ${mins}m';
    }
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }
}

class VideoInfo {
  final String title;
  final int? duration;
  final String? thumbnail;
  final String? uploader;
  final int? viewCount;
  final String? uploadDate;
  final String? description;
  final List<FormatInfo> audioFormats;
  final List<FormatInfo> videoFormats;

  const VideoInfo({
    required this.title,
    this.duration,
    this.thumbnail,
    this.uploader,
    this.viewCount,
    this.uploadDate,
    this.description,
    required this.audioFormats,
    required this.videoFormats,
  });

  factory VideoInfo.fromJson(Map<String, dynamic> json) {
    return VideoInfo(
      title: json['title'] ?? 'Unknown',
      duration: json['duration'],
      thumbnail: json['thumbnail'],
      uploader: json['uploader'],
      viewCount: json['view_count'],
      uploadDate: json['upload_date'],
      description: json['description'],
      audioFormats: (json['audio_formats'] as List?)
          ?.map((f) => FormatInfo.fromJson(f))
          .toList() ?? [],
      videoFormats: (json['video_formats'] as List?)
          ?.map((f) => FormatInfo.fromJson(f))
          .toList() ?? [],
    );
  }
}

class FormatInfo {
  final String formatId;
  final String ext;
  final String? resolution;
  final int? height;
  final int? fps;
  final int? filesize;
  final String? vcodec;
  final String? acodec;
  final double? abr;
  final String? qualityLabel;

  const FormatInfo({
    required this.formatId,
    required this.ext,
    this.resolution,
    this.height,
    this.fps,
    this.filesize,
    this.vcodec,
    this.acodec,
    this.abr,
    this.qualityLabel,
  });

  factory FormatInfo.fromJson(Map<String, dynamic> json) {
    return FormatInfo(
      formatId: json['format_id'] ?? '',
      ext: json['ext'] ?? '',
      resolution: json['resolution'],
      height: json['height'],
      fps: json['fps'],
      filesize: json['filesize'],
      vcodec: json['vcodec'],
      acodec: json['acodec'],
      abr: (json['abr'] as num?)?.toDouble(),
      qualityLabel: json['quality_label'],
    );
  }
}
