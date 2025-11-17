import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:typed_data';

class ImageViewerDialog extends StatelessWidget {
  final String? imageUrl;
  final Uint8List? imageBytes;
  final String imageName;

  const ImageViewerDialog({
    super.key,
    this.imageUrl,
    this.imageBytes,
    required this.imageName,
  }) : assert(imageUrl != null || imageBytes != null, 'Either imageUrl or imageBytes must be provided');

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Stack(
        children: [
          // Image viewer
          Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: imageUrl!,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.error,
                        color: Colors.red,
                        size: 48,
                      ),
                    )
                  : Image.memory(
                      imageBytes!,
                      fit: BoxFit.contain,
                    ),
            ),
          ),
          // Close button
          Positioned(
            top: 10,
            right: 10,
            child: Material(
              color: Colors.black54,
              shape: const CircleBorder(),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
          // Image name
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: Material(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  imageName,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

