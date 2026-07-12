import 'dart:io';

import 'package:hive_flutter/hive_flutter.dart';

import '../../../domain/entities/book.dart';
import 'hive_boxes.dart';

/// Time-boxed, on-device cache of remote API responses (Gutendex/Google
/// Books/LibriVox list pages and individual book lookups). Sits in front of
/// the repository layer's network calls so re-visiting a screen (Home,
/// Explore, Ebooks, Search) within the TTL window reads from disk instead of
/// re-hitting the API. Stores raw fetched books — local reading
/// state (progress/downloads) is merged in by the repository *after*
/// reading from cache, so cached entries never go stale on that front.
class ApiCacheSource {
  Box<Map>? _box;

  static const Duration defaultListTtl = Duration(hours: 1);
  static const Duration defaultBookTtl = Duration(hours: 24);

  Future<void> init() async {
    _box = await Hive.openBox<Map>(HiveBoxes.apiCache);
  }

  Box<Map> get _requireBox {
    final box = _box;
    if (box == null) {
      throw StateError('ApiCacheSource.init() must be awaited before use.');
    }
    return box;
  }

  bool _isFresh(int cachedAtMs, Duration ttl) =>
      DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(cachedAtMs)) <= ttl;

  List<Book>? _getList(String key, Duration ttl) {
    final raw = _requireBox.get(key);
    if (raw == null) return null;
    final cachedAt = raw['cachedAt'] as int?;
    if (cachedAt == null || !_isFresh(cachedAt, ttl)) return null;
    return _decodeList(raw);
  }

  /// Returns any stored list for [key] regardless of TTL — used as offline
  /// fallback when the network fetch fails.
  List<Book>? _getStaleList(String key) {
    final raw = _requireBox.get(key);
    if (raw == null) return null;
    return _decodeList(raw);
  }

  List<Book>? _decodeList(Map raw) {
    try {
      return (raw['items'] as List)
          .map((b) => Book.fromJson(Map<String, dynamic>.from(b as Map)))
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> _putList(String key, List<Book> books) {
    return _requireBox.put(key, {
      'cachedAt': DateTime.now().millisecondsSinceEpoch,
      'items': books.map((b) => b.toJson()).toList(),
    });
  }

  Book? _getBook(String key, Duration ttl) {
    final raw = _requireBox.get(key);
    if (raw == null) return null;
    final cachedAt = raw['cachedAt'] as int?;
    if (cachedAt == null || !_isFresh(cachedAt, ttl)) return null;
    return _decodeBook(raw);
  }

  /// Returns any stored book for [key] regardless of TTL — used as offline
  /// fallback when the network fetch fails.
  Book? _getStaleBook(String key) {
    final raw = _requireBox.get(key);
    if (raw == null) return null;
    return _decodeBook(raw);
  }

  Book? _decodeBook(Map raw) {
    try {
      return Book.fromJson(Map<String, dynamic>.from(raw['item'] as Map));
    } catch (_) {
      return null;
    }
  }

  Future<void> _putBook(String key, Book book) {
    return _requireBox.put(key, {
      'cachedAt': DateTime.now().millisecondsSinceEpoch,
      'item': book.toJson(),
    });
  }

  /// Returns the cached list for [key] if fresh, otherwise calls [fetch],
  /// caches its result, and returns that.
  ///
  /// **Offline fallback**: if [fetch] throws a network/IO error and a stale
  /// entry exists, the stale data is returned instead of propagating the
  /// error. If there is no stale entry at all, the original error is rethrown.
  Future<List<Book>> cachedList(
    String key,
    Future<List<Book>> Function() fetch, {
    Duration ttl = defaultListTtl,
  }) async {
    final cached = _getList(key, ttl);
    if (cached != null) return cached;
    try {
      final books = await fetch();
      await _putList(key, books);
      return books;
    } on SocketException {
      final stale = _getStaleList(key);
      if (stale != null) return stale;
      rethrow;
    } on Exception {
      // Covers TimeoutException, HttpException, and any other network-layer
      // exception surfaced by the remote sources.
      final stale = _getStaleList(key);
      if (stale != null) return stale;
      rethrow;
    }
  }

  /// Returns the cached book for [key] if fresh, otherwise calls [fetch],
  /// caches its result, and returns that.
  ///
  /// **Offline fallback**: same stale-on-error behaviour as [cachedList].
  Future<Book> cachedBook(
    String key,
    Future<Book> Function() fetch, {
    Duration ttl = defaultBookTtl,
  }) async {
    final cached = _getBook(key, ttl);
    if (cached != null) return cached;
    try {
      final book = await fetch();
      await _putBook(key, book);
      return book;
    } on SocketException {
      final stale = _getStaleBook(key);
      if (stale != null) return stale;
      rethrow;
    } on Exception {
      final stale = _getStaleBook(key);
      if (stale != null) return stale;
      rethrow;
    }
  }
}
