import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/book_model.dart';
import '../../data/repositories/repository_locator.dart';
import '../../services/auth_service.dart';
import '../../services/supabase_service.dart';

/// The user's library: bookmarked/downloaded books, reading progress, and
/// finished status.
///
/// Guests (anonymous sessions) get local-only storage via Hive, same as
/// before. Signed-in (non-anonymous) accounts additionally sync to the
/// Supabase `library_books` table so the library survives reinstalls and
/// syncs across devices — any books added while still a guest are pushed up
/// automatically the first time the session becomes a real account.
class LibraryProvider extends ChangeNotifier {
  static final LibraryProvider instance = LibraryProvider._internal();
  LibraryProvider._internal() {
    _libraryBooks.addAll(RepositoryLocator.localSource.getAllBooks());
    if (AuthService.instance.isAuthenticated) {
      _syncFromCloud();
    }
  }

  final List<Book> _libraryBooks = [];
  final Map<String, DateTime> _addedAt = {};
  final Map<String, DateTime> _updatedAt = {};
  bool _isSyncing = false;

  List<Book> get books => List.unmodifiable(_libraryBooks);
  bool get isSyncing => _isSyncing;

  /// Real timestamps only — null when unknown (e.g. a guest book added in a
  /// previous app run, before this session's in-memory tracking started).
  DateTime? addedAtFor(String bookId) => _addedAt[bookId];
  DateTime? updatedAtFor(String bookId) => _updatedAt[bookId];

  bool get _isSupabaseInitialized {
    try {
      Supabase.instance;
      return true;
    } catch (_) {
      return false;
    }
  }

  bool get _cloudEnabled => _isSupabaseInitialized && AuthService.instance.isAuthenticated;

  bool isBookmarked(String bookId) {
    return _libraryBooks.any((book) => book.id == bookId);
  }

  void toggleBookmark(Book book) {
    final index = _libraryBooks.indexWhere((b) => b.id == book.id);
    if (index >= 0) {
      _libraryBooks.removeAt(index);
      _addedAt.remove(book.id);
      _updatedAt.remove(book.id);
      RepositoryLocator.localSource.deleteBook(book.id);
      if (_cloudEnabled) _deleteFromCloud(book.id);
    } else {
      _libraryBooks.add(book);
      _addedAt[book.id] = DateTime.now();
      RepositoryLocator.localSource.saveBook(book);
      if (_cloudEnabled) _upsertToCloud(book);
    }
    notifyListeners();
  }

  void addBook(Book book) {
    if (!_libraryBooks.any((b) => b.id == book.id)) {
      _libraryBooks.add(book);
      _addedAt[book.id] = DateTime.now();
      RepositoryLocator.localSource.saveBook(book);
      notifyListeners();
      if (_cloudEnabled) _upsertToCloud(book);
    }
  }

  void removeBook(String bookId) {
    _libraryBooks.removeWhere((b) => b.id == bookId);
    _addedAt.remove(bookId);
    _updatedAt.remove(bookId);
    RepositoryLocator.localSource.deleteBook(bookId);
    notifyListeners();
    if (_cloudEnabled) _deleteFromCloud(bookId);
  }

  /// Replaces a book's entry entirely (e.g. after a download completes and
  /// it now has a [Book.localFilePath]), persisting the new state.
  void updateBook(Book updated) {
    final index = _libraryBooks.indexWhere((b) => b.id == updated.id);
    if (index >= 0) {
      _libraryBooks[index] = updated;
    } else {
      _libraryBooks.add(updated);
      _addedAt[updated.id] = DateTime.now();
    }
    _updatedAt[updated.id] = DateTime.now();
    RepositoryLocator.localSource.saveBook(updated);
    notifyListeners();
    if (_cloudEnabled) _upsertToCloud(updated);
  }

  /// Auto-adds [bookId]'s book to the library (if not already present) and
  /// records reading progress — called by the reader as chapters advance.
  void updateBookProgress(String bookId, double progress) {
    final index = _libraryBooks.indexWhere((b) => b.id == bookId);
    if (index >= 0) {
      final updated = _libraryBooks[index].copyWith(
        progress: progress,
        isFinished: progress >= 1.0,
      );
      _libraryBooks[index] = updated;
      _updatedAt[bookId] = DateTime.now();
      RepositoryLocator.localSource.saveBook(updated);
      notifyListeners();
      if (_cloudEnabled) _upsertToCloud(updated);
    }
  }

  // ── Cloud sync (signed-in accounts only) ─────────────────────

  Future<void> _syncFromCloud() async {
    _isSyncing = true;
    notifyListeners();
    try {
      await _migrateLocalToCloud();

      final user = AuthService.instance.currentUser!;
      final res = await SupabaseService.client
          .from('library_books')
          .select()
          .eq('profile_id', user.id);

      for (final row in (res as List)) {
        final map = Map<String, dynamic>.from(row as Map);
        final bookData = Map<String, dynamic>.from(map['book_data'] as Map);
        final localFilePath =
            RepositoryLocator.localSource.getBook(map['book_id'] as String)?.localFilePath;
        final book = Book.fromJson(bookData).copyWith(
          progress: (map['progress'] as num?)?.toDouble(),
          isFinished: map['is_finished'] as bool? ?? false,
          localFilePath: localFilePath,
        );

        final index = _libraryBooks.indexWhere((b) => b.id == book.id);
        if (index >= 0) {
          _libraryBooks[index] = book;
        } else {
          _libraryBooks.add(book);
        }
        _addedAt[book.id] = DateTime.parse(map['added_at'] as String);
        _updatedAt[book.id] = DateTime.parse(map['updated_at'] as String);
        // Keep the local cache warm so the merge-on-fetch in BookRepository
        // (progress/localFilePath overlay) still works offline.
        RepositoryLocator.localSource.saveBook(book);
      }
    } catch (e) {
      debugPrint('Error syncing library from cloud: $e');
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// One-time push of any local-only (guest) books into the cloud the first
  /// time this session becomes a real account, so guest activity isn't lost.
  Future<void> _migrateLocalToCloud() async {
    if (_libraryBooks.isEmpty) return;
    final user = AuthService.instance.currentUser!;
    try {
      final existing = await SupabaseService.client
          .from('library_books')
          .select('book_id')
          .eq('profile_id', user.id);
      final existingIds = (existing as List).map((r) => r['book_id'] as String).toSet();

      for (final book in _libraryBooks.where((b) => !existingIds.contains(b.id))) {
        await _upsertToCloud(book);
      }
    } catch (e) {
      debugPrint('Error migrating local library to cloud: $e');
    }
  }

  Future<void> _upsertToCloud(Book book) async {
    if (!_cloudEnabled) return;
    final user = AuthService.instance.currentUser!;
    try {
      final bookJson = book.toJson();
      bookJson['localFilePath'] = null; // device-specific, not synced

      await SupabaseService.client.from('library_books').upsert(
        {
          'profile_id': user.id,
          'book_id': book.id,
          'book_data': bookJson,
          'progress': book.progress,
          'is_finished': book.isFinished ?? false,
        },
        onConflict: 'profile_id,book_id',
      );
    } catch (e) {
      debugPrint('Error syncing book to cloud: $e');
    }
  }

  Future<void> _deleteFromCloud(String bookId) async {
    if (!_isSupabaseInitialized) return;
    final user = AuthService.instance.currentUser;
    if (user == null) return;
    try {
      await SupabaseService.client
          .from('library_books')
          .delete()
          .eq('book_id', bookId)
          .eq('profile_id', user.id);
    } catch (e) {
      debugPrint('Error removing book from cloud: $e');
    }
  }

  /// Called by SessionProvider when auth state changes (e.g. sign in / out).
  void onAuthChanged() {
    if (AuthService.instance.isAuthenticated) {
      _syncFromCloud();
    }
  }
}
