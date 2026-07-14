import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../data/models/book_model.dart';
import '../../../data/repositories/repository_locator.dart';
import '../../../domain/entities/color_category.dart';
import '../../../domain/usecases/books/extract_dominant_color.dart';

/// Loads a corpus of real books and buckets each by its cover's dominant
/// color, so "Browse by Color" reflects actual cover art rather than any
/// fabricated/preset grouping. Colors are resolved a few books at a time
/// (network fetch + on-device decode) and cached on disk per book id so the
/// same cover is never re-analyzed.
class ColorSearchProvider extends ChangeNotifier {
  static final ColorSearchProvider instance = ColorSearchProvider._internal();
  ColorSearchProvider._internal();

  static const int _concurrency = 6;

  final Map<String, Book> _booksById = {};
  final Map<String, ColorCategory> _categoryByBookId = {};
  bool _isLoading = false;
  bool _hasLoadedOnce = false;
  String? _error;
  ColorCategory? _selected;

  bool get isLoading => _isLoading;
  String? get error => _error;
  ColorCategory? get selected => _selected;

  Map<ColorCategory, int> get countsByCategory {
    final counts = <ColorCategory, int>{};
    for (final category in _categoryByBookId.values) {
      counts[category] = (counts[category] ?? 0) + 1;
    }
    return counts;
  }

  List<Book> booksFor(ColorCategory category) {
    return _categoryByBookId.entries
        .where((e) => e.value == category)
        .map((e) => _booksById[e.key])
        .whereType<Book>()
        .toList();
  }

  void selectCategory(ColorCategory category) {
    _selected = category;
    notifyListeners();
  }

  Future<void> loadIfNeeded() async {
    if (_hasLoadedOnce) return;
    _hasLoadedOnce = true;
    await refresh();
  }

  Future<void> refresh() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final pages = await Future.wait([
        RepositoryLocator.bookRepository.popularBooks(page: 1),
        RepositoryLocator.bookRepository.popularBooks(page: 2),
      ]);

      for (final page in pages) {
        for (final book in page) {
          _booksById[book.id] = book;
        }
      }

      final pending = _booksById.values
          .where((b) => !_categoryByBookId.containsKey(b.id))
          .toList();

      for (var i = 0; i < pending.length; i += _concurrency) {
        final batch = pending.skip(i).take(_concurrency);
        await Future.wait(batch.map(_resolveCategory));
        notifyListeners();
      }
    } catch (e) {
      _error = "Couldn't load books to browse by color.";
      debugPrint('Error loading color search corpus: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _resolveCategory(Book book) async {
    final cachedName = RepositoryLocator.coverColorCache.get(book.id);
    if (cachedName != null) {
      final cached = ColorCategory.fromName(cachedName);
      if (cached != null) {
        _categoryByBookId[book.id] = cached;
        return;
      }
    }

    final url = book.coverUrl;
    if (url == null || !url.startsWith('http')) return;

    try {
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return;

      final category = await extractDominantColorCategory(response.bodyBytes);
      if (category == null) return;

      _categoryByBookId[book.id] = category;
      await RepositoryLocator.coverColorCache.put(book.id, category.name);
    } catch (e) {
      debugPrint('Error analyzing cover color for ${book.id}: $e');
    }
  }
}
