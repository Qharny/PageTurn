import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../config/env.dart';
import '../../../core/errors/app_exception.dart';
import '../../models/gutendex_book_model.dart';

class GutendexPage {
  final List<GutendexBookModel> books;
  final bool hasNextPage;

  const GutendexPage({required this.books, required this.hasNextPage});
}

/// Talks to https://gutendex.com — a REST index over the Project Gutenberg
/// catalog. All list endpoints are paginated via `?page=`.
class GutendexSource {
  final http.Client _client;

  GutendexSource({http.Client? client}) : _client = client ?? http.Client();

  Future<GutendexPage> searchBooks(String query, {int page = 1}) {
    return _fetchPage({'search': query, 'page': '$page'});
  }

  Future<GutendexPage> browseByTopic(String topic, {int page = 1}) {
    return _fetchPage({'topic': topic, 'page': '$page'});
  }

  /// Gutendex sorts by download count by default; `sort=popular` is passed
  /// explicitly so behaviour doesn't depend on that default staying in place.
  Future<GutendexPage> popularBooks({int page = 1}) {
    return _fetchPage({'sort': 'popular', 'page': '$page'});
  }

  Future<GutendexBookModel> getBook(String id) async {
    final uri = Uri.parse('${AppConfig.gutendexBaseUrl}/books/$id/');
    final json = await _getJson(uri);
    return GutendexBookModel.fromJson(json as Map<String, dynamic>);
  }

  Future<GutendexPage> _fetchPage(Map<String, String> params) async {
    final uri = Uri.parse('${AppConfig.gutendexBaseUrl}/books/').replace(queryParameters: params);
    final json = await _getJson(uri);
    final map = json as Map<String, dynamic>;
    final results = (map['results'] as List<dynamic>? ?? [])
        .map((b) => GutendexBookModel.fromJson(b as Map<String, dynamic>))
        .toList();
    return GutendexPage(books: results, hasNextPage: map['next'] != null);
  }

  Future<dynamic> _getJson(Uri uri) async {
    http.Response response;
    try {
      response = await _client.get(uri).timeout(AppConfig.httpTimeout);
    } on SocketException catch (e) {
      throw NetworkException('Network error. Check your connection.', e);
    } on HttpException catch (e) {
      throw NetworkException('Network error. Check your connection.', e);
    } catch (e) {
      throw NetworkException('Could not reach Gutendex.', e);
    }

    if (response.statusCode == 404) {
      throw const NotFoundException('That book could not be found.');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ServerException('Gutendex returned an error (${response.statusCode}).');
    }

    try {
      return jsonDecode(response.body);
    } catch (e) {
      throw ParseException('Could not read the response from Gutendex.', e);
    }
  }

  void dispose() => _client.close();
}
