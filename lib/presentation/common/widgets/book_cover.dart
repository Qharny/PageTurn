import 'package:flutter/material.dart';

class BookCover extends StatelessWidget {
  final String coverAsset;
  final String title;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;

  const BookCover({
    super.key,
    required this.coverAsset,
    required this.title,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    if (coverAsset.isEmpty) {
      return _buildPlaceholder(context);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.asset(
        coverAsset,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder(context);
        },
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF1E1E1E),
                    const Color(0xFF2C2C2C),
                  ]
                : [
                    const Color(0xFF2C1810),
                    const Color(0xFF8C481A),
                  ],
          ),
        ),
        padding: const EdgeInsets.all(8),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.book_rounded,
                color: Colors.white.withValues(alpha: 0.7),
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Literata',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
