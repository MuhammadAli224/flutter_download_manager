import 'package:flutter/material.dart';

class FileHelper {
  static String getExtension(String fileName) {
    final parts = fileName.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }

  static IconData getFileIcon(String fileName) {
    switch (getExtension(fileName)) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
      case 'svg':
        return Icons.image;
      case 'mp4':
      case 'avi':
      case 'mkv':
      case 'mov':
        return Icons.video_file;
      case 'mp3':
      case 'wav':
      case 'aac':
      case 'flac':
        return Icons.audio_file;
      case 'zip':
      case 'rar':
      case '7z':
      case 'tar':
      case 'gz':
        return Icons.archive;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'txt':
        return Icons.text_snippet;
      case 'apk':
        return Icons.android;
      default:
        return Icons.insert_drive_file;
    }
  }

  static String getFileType(String fileName) {
    switch (getExtension(fileName)) {
      case 'pdf':
        return 'PDF Document';
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return 'Image';
      case 'mp4':
      case 'avi':
      case 'mkv':
      case 'mov':
        return 'Video';
      case 'mp3':
      case 'wav':
      case 'aac':
      case 'flac':
        return 'Audio';
      case 'zip':
      case 'rar':
      case '7z':
        return 'Archive';
      case 'doc':
      case 'docx':
        return 'Word Document';
      case 'xls':
      case 'xlsx':
        return 'Excel File';
      case 'ppt':
      case 'pptx':
        return 'PowerPoint';
      case 'apk':
        return 'Android App';
      default:
        return 'File';
    }
  }

  /// Format bytes to human-readable string
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  /// Format speed in bytes/sec to human-readable string
  static String formatSpeed(double bytesPerSec) {
    if (bytesPerSec < 1024) return '${bytesPerSec.toStringAsFixed(0)} B/s';
    if (bytesPerSec < 1024 * 1024) {
      return '${(bytesPerSec / 1024).toStringAsFixed(1)} KB/s';
    }
    return '${(bytesPerSec / (1024 * 1024)).toStringAsFixed(1)} MB/s';
  }

  /// Get MIME type from extension (used for Android MediaStore)
  static String getMimeType(String fileName) {
    switch (getExtension(fileName)) {
      case 'pdf':
        return 'application/pdf';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'mp4':
        return 'video/mp4';
      case 'avi':
        return 'video/x-msvideo';
      case 'mkv':
        return 'video/x-matroska';
      case 'mp3':
        return 'audio/mpeg';
      case 'wav':
        return 'audio/wav';
      case 'aac':
        return 'audio/aac';
      case 'zip':
        return 'application/zip';
      case 'rar':
        return 'application/x-rar-compressed';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'apk':
        return 'application/vnd.android.package-archive';
      case 'txt':
        return 'text/plain';
      default:
        return 'application/octet-stream';
    }
  }
}