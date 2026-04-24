import 'package:flutter/material.dart';
import '../../../../core/theme.dart';

class ProductCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final double price;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.price,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ProductNetworkImage(
                imageUrl: imageUrl,
                size: double.infinity,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '৳${price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Extracted reusable network image widget
class ProductNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double size;
  final BoxFit fit;
  final double borderRadius;

  const ProductNetworkImage({
    super.key,
    required this.imageUrl,
    this.size = 80,
    this.fit = BoxFit.cover,
    this.borderRadius = 12,
  });

  String _extractGoogleDriveFileId(Uri uri) {
    final segments = uri.pathSegments;
    final fileIndex = segments.indexOf('d');
    if (fileIndex != -1 && fileIndex + 1 < segments.length) {
      return segments[fileIndex + 1];
    }

    final idFromQuery = uri.queryParameters['id'];
    if (idFromQuery != null && idFromQuery.trim().isNotEmpty) {
      return idFromQuery.trim();
    }

    return '';
  }

  String _resolveImageUrl(String rawUrl) {
    final trimmed = rawUrl.trim();
    if (trimmed.isEmpty) return '';

    final schemeNormalized = trimmed.startsWith('//')
        ? 'https:$trimmed'
        : trimmed;

    final uri = Uri.tryParse(schemeNormalized);
    if (uri == null) {
      return schemeNormalized;
    }

    final host = uri.host.toLowerCase();
    final isGoogleDrive =
        host.contains('drive.google.com') || host.contains('docs.google.com');

    if (!isGoogleDrive) {
      return schemeNormalized;
    }

    final fileId = _extractGoogleDriveFileId(uri);
    if (fileId.isEmpty) {
      return schemeNormalized;
    }

    // Use Drive thumbnail endpoint because share links return HTML, not image bytes.
    return 'https://drive.google.com/thumbnail?id=$fileId&sz=w1600';
  }

  @override
  Widget build(BuildContext context) {
    final normalizedUrl = _resolveImageUrl(imageUrl);

    final image = normalizedUrl.isEmpty
        ? Container(
            color: Colors.grey[200],
            child: const Center(
              child: Icon(Icons.image_not_supported_outlined),
            ),
          )
        : Image.network(
            normalizedUrl,
            fit: fit,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: Colors.grey[200],
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            },
            errorBuilder: (_, child, details) => Container(
              color: Colors.grey[200],
              child: const Center(child: Icon(Icons.broken_image)),
            ),
          );

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: size.isFinite
          ? SizedBox(width: size, height: size, child: image)
          : SizedBox.expand(child: image),
    );
  }
}
