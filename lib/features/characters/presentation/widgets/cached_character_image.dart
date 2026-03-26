import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CachedCharacterImage extends StatelessWidget {
  const CachedCharacterImage({
    super.key,
    required this.imageUrl,
    required this.width,
    required this.height,
    required this.borderRadius,
    this.iconSize = 28,
  });

  final String imageUrl;
  final double width;
  final double height;
  final BorderRadius borderRadius;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: width,
          height: height,
          color: const Color(0xFFF3F4F6),
          alignment: Alignment.center,
          child: const CircularProgressIndicator(strokeWidth: 2),
        ),
        errorWidget: (context, url, error) => Container(
          width: width,
          height: height,
          color: const Color(0xFFE5E7EB),
          alignment: Alignment.center,
          child: Icon(Icons.broken_image_outlined, size: iconSize),
        ),
      ),
    );
  }
}
