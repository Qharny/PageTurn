import 'dart:ui';

import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../data/models/book_model.dart';
import '../../routes.dart';

class BookDetailScreen extends StatefulWidget {
  const BookDetailScreen({super.key, required this.book});
  final Book book;

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  bool _isBookmarked = false;
  bool _descriptionExpanded = false;

  static const _darkBrown = Color(0xFF1A0F0A);
  static const _warmWhite = Color(0xFFF9F5EF);
  static const _mutedText = Color(0xFF7A6B63);
  static const _chocolateBrown = Color(0xFF5C3826);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _warmWhite,
      body: Stack(
        children: [
          // ── Main scrollable content ──────────────────────────────────
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildHeroHeader(context)),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildMetaRow(),
                    const SizedBox(height: 28),
                    _buildActionButtons(context),
                    const SizedBox(height: 32),
                    _buildSpecsRow(),
                    const SizedBox(height: 32),
                    _buildDescription(),
                    const SizedBox(height: 28),
                    _buildTagsRow(),
                    const SizedBox(height: 32),
                    _buildReviews(),
                    const SizedBox(height: 20),
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── HERO HEADER (Twitter/X profile layout) ───────────────────────────────────
  Widget _buildHeroHeader(BuildContext context) {
    const double bannerH = 215.0;
    const double coverW = 116.0;
    const double coverH = 170.0;
    // How far the cover dips below the banner into the white strip
    const double coverBelowBanner = 80.0;
    // Top of cover relative to the Stack
    const double coverTop = bannerH - coverH + coverBelowBanner; // = 125

    return SizedBox(
      height: bannerH + coverBelowBanner + 16,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Full-width blurred banner ─────────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            child: SizedBox(
              height: bannerH,
              child: widget.book.coverAsset.isNotEmpty
                  ? ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
                      child: Image.asset(
                        widget.book.coverAsset,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: _darkBrown),
                      ),
                    )
                  : Container(color: _darkBrown),
            ),
          ),

          // Dark overlay on banner so text is readable
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              height: bannerH,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _darkBrown.withValues(alpha: 0.62),
                    _darkBrown.withValues(alpha: 0.28),
                  ],
                ),
              ),
            ),
          ),

          // ── Warm-white strip below the banner ────────────────────────
          Positioned(
            top: bannerH, left: 0, right: 0, bottom: 0,
            child: Container(color: _warmWhite),
          ),

          // ── Back (top-left) + Share (top-right) on banner ────────────
          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _navButton(icon: Icons.arrow_back_rounded, onTap: () => Navigator.pop(context)),
                    _navButton(icon: Icons.share_outlined, onTap: () {}),
                  ],
                ),
              ),
            ),
          ),

          // ── Title + Author: right side of banner ──────────────────────
          Positioned(
            left: coverW + 36,
            right: 16,
            top: 64,
            bottom: coverBelowBanner + 8,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.book.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Literata',
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                      shadows: [Shadow(color: Colors.black54, blurRadius: 10)],
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    widget.book.author,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.78),
                      shadows: const [Shadow(color: Colors.black38, blurRadius: 6)],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Book cover overlapping the banner/white junction ──────────
          Positioned(
            top: coverTop,
            left: 20,
            child: Container(
              width: coverW,
              height: coverH,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _warmWhite, width: 3.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.38),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: widget.book.coverAsset.isNotEmpty
                    ? Image.asset(
                        widget.book.coverAsset,
                        fit: BoxFit.cover,
                        width: coverW,
                        height: coverH,
                        errorBuilder: (_, __, ___) => _fallbackCover(),
                      )
                    : _fallbackCover(),
              ),
            ),
          ),

          // ── Animated Save button: white strip, bottom-right ──────────
          Positioned(
            top: bannerH + (coverBelowBanner - 38) / 2,
            right: 20,
            child: GestureDetector(
              onTap: () => setState(() => _isBookmarked = !_isBookmarked),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: _isBookmarked ? AppTheme.primary : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: _isBookmarked ? AppTheme.primary : const Color(0xFFDDD4C4),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.07),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                      color: _isBookmarked ? Colors.white : _chocolateBrown,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isBookmarked ? 'Saved' : 'Save',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: _isBookmarked ? Colors.white : _chocolateBrown,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallbackCover() {
    return Container(
      width: 116,
      height: 170,
      color: const Color(0xFF2C3E50),
      child: Center(
        child: Text(
          widget.book.title,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'Inter'),
        ),
      ),
    );
  }

  Widget _navButton({required IconData icon, required VoidCallback onTap, bool filled = false}) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 40,
        height: 40,
        child: Icon(
          icon,
          color: filled ? AppTheme.primary : Colors.white,
          size: 24,
        ),
      ),
    );
  }

  // ── META ROW (rating + reviews) ──────────────────────────────────────────────
  Widget _buildMetaRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.star_rounded, color: Color(0xFFF4A836), size: 18),
        const SizedBox(width: 5),
        Text(
          '${widget.book.rating}',
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: _chocolateBrown,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '(${widget.book.reviewCount} reviews)',
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            color: _mutedText,
          ),
        ),
        const SizedBox(width: 16),
        Container(width: 1, height: 14, color: const Color(0xFFE2DDD5)),
        const SizedBox(width: 16),
        const Icon(Icons.language_rounded, color: _mutedText, size: 14),
        const SizedBox(width: 4),
        Text(
          widget.book.language,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            color: _mutedText,
          ),
        ),
      ],
    );
  }

  // ── CTA BUTTONS ──────────────────────────────────────────────────────────────
  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Primary Read button — full width
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, AppRoutes.reader, arguments: widget.book),
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFF1A0F0A),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.menu_book_rounded, color: Colors.white, size: 18),
                SizedBox(width: 10),
                Text(
                  'Read Now',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            // Listen button
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, AppRoutes.player, arguments: widget.book),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE8E0D4), width: 1.5),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.headphones_rounded, color: _chocolateBrown, size: 17),
                      SizedBox(width: 8),
                      Text(
                        'Listen',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: _chocolateBrown,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Download button
            Expanded(
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE8E0D4), width: 1.5),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.download_rounded, color: _chocolateBrown, size: 17),
                      SizedBox(width: 8),
                      Text(
                        'Save',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: _chocolateBrown,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── SPECS ROW ────────────────────────────────────────────────────────────────
  Widget _buildSpecsRow() {
    final specs = [
      _Spec(icon: Icons.import_contacts_rounded, label: 'Pages', value: widget.book.length),
      _Spec(icon: Icons.headphones_rounded, label: 'Audio', value: widget.book.audioDuration),
      _Spec(icon: Icons.translate_rounded, label: 'Language', value: widget.book.language),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFF3EDE3),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (int i = 0; i < specs.length; i++) ...[
            if (i > 0) Container(width: 1, height: 32, color: const Color(0xFFE0D4C4)),
            _buildSpecItem(specs[i]),
          ],
        ],
      ),
    );
  }

  Widget _buildSpecItem(_Spec spec) {
    return Column(
      children: [
        Icon(spec.icon, color: AppTheme.primary, size: 20),
        const SizedBox(height: 6),
        Text(
          spec.value,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: _chocolateBrown,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          spec.label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 10,
            color: _mutedText,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }

  // ── DESCRIPTION ──────────────────────────────────────────────────────────────
  Widget _buildDescription() {
    const maxLength = 180;
    final isLong = widget.book.description.length > maxLength;
    final displayText = (!_descriptionExpanded && isLong)
        ? '${widget.book.description.substring(0, maxLength)}…'
        : widget.book.description;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'About',
          style: TextStyle(
            fontFamily: 'Literata',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _chocolateBrown,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          displayText,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: _mutedText,
            height: 1.65,
          ),
        ),
        if (isLong) ...[
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () => setState(() => _descriptionExpanded = !_descriptionExpanded),
            child: Text(
              _descriptionExpanded ? 'Show less' : 'Read more',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ── TAGS ─────────────────────────────────────────────────────────────────────
  Widget _buildTagsRow() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.book.tags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: Color(tag.backgroundColorValue),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            tag.text,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(tag.textColorValue),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── REVIEWS ──────────────────────────────────────────────────────────────────
  Widget _buildReviews() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Reviews',
              style: TextStyle(
                fontFamily: 'Literata',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _chocolateBrown,
              ),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              child: const Text(
                'See all',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _mutedText,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...widget.book.reviews.map((r) => _buildReviewCard(r)),
      ],
    );
  }

  Widget _buildReviewCard(BookReview review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF0E8DC), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar circle with initial
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primary.withValues(alpha: 0.1),
                ),
                alignment: Alignment.center,
                child: Text(
                  review.reviewerName.substring(0, 1),
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppTheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.reviewerName,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _chocolateBrown,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: List.generate(5, (i) {
                        return Icon(
                          Icons.star_rounded,
                          size: 12,
                          color: i < review.rating
                              ? const Color(0xFFF4A836)
                              : const Color(0xFFE0D5C8),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.comment,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: _mutedText,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}

class _Spec {
  final IconData icon;
  final String label;
  final String value;
  _Spec({required this.icon, required this.label, required this.value});
}
