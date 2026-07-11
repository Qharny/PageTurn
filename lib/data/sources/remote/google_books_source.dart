import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../config/env.dart';
import '../../../core/errors/app_exception.dart';
import '../../models/google_book_volume_model.dart';

class BookEnrichment {
  final String? description;
  final String? coverUrl;

  const BookEnrichment({this.description, this.coverUrl});
}

/// Talks to the Google Books volumes API. Used both directly (quick-add
/// search) and indirectly, as a best-effort enrichment lookup for sources
/// (Gutendex, LibriVox) that don't provide a description or cover.
class GoogleBooksSource {
  final http.Client _client;

  GoogleBooksSource({http.Client? client}) : _client = client ?? http.Client();

  Future<List<GoogleBookVolumeModel>> searchVolumes(String query, {int startIndex = 0, int maxResults = 20}) async {
    final uri = Uri.parse(AppConfig.googleBooksBaseUrl).replace(queryParameters: {
      'q': query,
      'startIndex': '$startIndex',
      'maxResults': '$maxResults',
    });
    final json = await _getJson(uri);
    final items = (json['items'] as List<dynamic>? ?? []);
    return items.map((i) => GoogleBookVolumeModel.fromJson(i as Map<String, dynamic>)).toList();
  }

  Future<GoogleBookVolumeModel> getVolume(String id) async {
    final uri = Uri.parse('${AppConfig.googleBooksBaseUrl}/$id');
    final json = await _getJson(uri);
    return GoogleBookVolumeModel.fromJson(json);
  }

  /// Best-effort lookup used to fill in a missing description/cover for a
  /// book from another source. Never throws — returns null on any failure
  /// (including rate limiting) since enrichment should degrade silently.
  Future<BookEnrichment?> enrichMetadata(String title, String author) async {
    try {
      final results = await searchVolumes('intitle:"$title" inauthor:"$author"', maxResults: 1);
      if (results.isEmpty) return null;
      final match = results.first;
      return BookEnrichment(description: match.description, coverUrl: match.thumbnailUrl);
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    http.Response response;
    try {
      response = await _client.get(uri).timeout(AppConfig.httpTimeout);
    } on SocketException catch (e) {
      throw NetworkException('Network error. Check your connection.', e);
    } on HttpException catch (e) {
      throw NetworkException('Network error. Check your connection.', e);
    } catch (e) {
      throw NetworkException('Could not reach Google Books.', e);
    }

    if (response.statusCode == 429) {
      throw const ServerException('Google Books rate limit reached. Try again shortly.');
    }
    if (response.statusCode == 404) {
      throw const NotFoundException('That book could not be found.');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ServerException('Google Books returned an error (${response.statusCode}).');
    }

    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      throw ParseException('Could not read the response from Google Books.', e);
    }
  }

  void dispose() => _client.close();
}
