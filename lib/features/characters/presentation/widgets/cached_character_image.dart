import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/app_colors.dart';

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
          color: AppColors.imagePlaceholder,
          alignment: Alignment.center,
          child: SizedBox(
            width: 20.r,
            height: 20.r,
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          width: width,
          height: height,
          color: AppColors.imageError,
          alignment: Alignment.center,
          child: Icon(Icons.broken_image_outlined, size: iconSize),
        ),
      ),
    );
  }
}
