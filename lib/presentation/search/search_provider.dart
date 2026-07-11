import 'package:flutter/foundation.dart';

import '../../core/errors/app_exception.dart';
import '../../data/models/book_model.dart';
import '../../data/repositories/repository_locator.dart';

enum SearchStatus { idle, loading, loadingMore, ready, empty, error }

/// Drives ebook search: queries Gutendex (paginated via `page`) for the
/// main result list.
class SearchProvider extends ChangeNotifier {
  SearchStatus status = SearchStatus.idle;
  String? errorMessage;
  List<Book> results = [];
  String _query = '';
  int _page = 1;
  bool _hasMore = true;

  bool get hasMore => _hasMore;

  Future<void> search(String query) async {
    if (query.trim().isEmpty) return;
    _query = query.trim();
    _page = 1;
    status = SearchStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      final books = await RepositoryLocator.bookRepository.searchBooks(_query, page: _page);
      results = books;
      _hasMore = books.isNotEmpty;
      status = results.isEmpty ? SearchStatus.empty : SearchStatus.ready;
    } on AppException catch (e) {
      status = SearchStatus.error;
      errorMessage = e.message;
    }
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (!_hasMore || status == SearchStatus.loadingMore || _query.isEmpty) return;
    status = SearchStatus.loadingMore;
    notifyListeners();

    try {
      final nextPage = _page + 1;
      final books = await RepositoryLocator.bookRepository.searchBooks(_query, page: nextPage);
      _page = nextPage;
      _hasMore = books.isNotEmpty;
      results = [...results, ...books];
      status = SearchStatus.ready;
    } on AppException catch (e) {
      status = SearchStatus.ready; // keep existing results visible
      errorMessage = e.message;
    }
    notifyListeners();
  }
}
