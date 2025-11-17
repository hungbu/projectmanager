import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:typed_data';
import 'image_viewer_dialog.dart';

class ImageThumbnailWidget extends StatelessWidget {
  final String? imageUrl;
  final Uint8List? imageBytes;
  final String imageName;
  final VoidCallback? onRemove;
  final VoidCallback? onTap;
  final double size;

  const ImageThumbnailWidget({
    super.key,
    this.imageUrl,
    this.imageBytes,
    required this.imageName,
    this.onRemove,
    this.onTap,
    this.size = 30.0,
  }) : assert(imageUrl != null || imageBytes != null, 'Either imageUrl or imageBytes must be provided');

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () {
        showDialog(
          context: context,
          builder: (context) => ImageViewerDialog(
            imageUrl: imageUrl,
            imageBytes: imageBytes,
            imageName: imageName,
          ),
        );
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image, size: 16),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.broken_image, size: 16),
                      ),
                    )
                  : Image.memory(
                      imageBytes!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.broken_image, size: 16),
                      ),
                    ),
            ),
          ),
          // Remove button (X)
          if (onRemove != null)
            Positioned(
              top: -6,
              right: -6,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

