import 'dart:typed_data';

// Wrapper class for file data that works on both web and mobile
class PickedFile {
  final String name;
  final Uint8List? bytes;
  final String? path;

  PickedFile({
    required this.name,
    this.bytes,
    this.path,
  });

  bool get isWeb => bytes != null;
  
  // Check if file is an image based on extension
  bool get isImage {
    final extension = name.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'svg'].contains(extension);
  }
  
  // Get image bytes for display
  Uint8List? get imageBytes => isImage ? (bytes ?? null) : null;
}

// Helper extension for attachment URLs
extension AttachmentUrlExtension on String {
  bool get isImageUrl {
    final url = toLowerCase();
    return url.contains('.jpg') || 
           url.contains('.jpeg') || 
           url.contains('.png') || 
           url.contains('.gif') || 
           url.contains('.bmp') || 
           url.contains('.webp') ||
           url.contains('.svg');
  }
}

