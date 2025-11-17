// Stub file for web builds - File class is not available on web
// This file is only used when compiling for web platform
import 'dart:typed_data';

class File {
  File(String path);
  Future<Uint8List> readAsBytes() => throw UnsupportedError('File operations not supported on web');
}

