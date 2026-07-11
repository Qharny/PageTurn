import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../config/env.dart';
import '../../../core/errors/app_exception.dart';
import '../../models/librivox_audiobook_model.dart';

/// Talks to https://librivox.org/api/feed/audiobooks — public-domain
/// audiobooks with streamable MP3 sections. Paginated via offset/limit.
class LibriVoxSource {
  final http.Client _client;

  LibriVoxSource({http.Client? client}) : _client = client ?? http.Client();

  Future<List<LibriVoxAudiobookModel>> search({
    String? title,
    String? author,
    String? genre,
    int limit = 20,
    int offset = 0,
  }) {
    final params = <String, String>{
      'format': 'json',
      'extended': '1',
      'limit': '$limit',
      'offset': '$offset',
    };
    if (title != null && title.isNotEmpty) params['title'] = '^$title';
    if (author != null && author.isNotEmpty) params['author'] = '^$author';
    if (genre != null && genre.isNotEmpty) params['genre'] = genre;
    return _fetch(params);
  }

  Future<List<LibriVoxAudiobookModel>> recent({int limit = 20, int offset = 0}) {
    return _fetch({
      'format': 'json',
      'extended': '1',
      'limit': '$limit',
      'offset': '$offset',
    });
  }

  Future<LibriVoxAudiobookModel> getById(String id) async {
    final results = await _fetch({'format': 'json', 'extended': '1', 'id': id});
    if (results.isEmpty) {
      throw const NotFoundException('That audiobook could not be found.');
    }
    return results.first;
  }

  Future<List<LibriVoxAudiobookModel>> _fetch(Map<String, String> params) async {
    final uri = Uri.parse('${AppConfig.libriVoxBaseUrl}/').replace(queryParameters: params);
    http.Response response;
    try {
      response = await _client.get(uri).timeout(AppConfig.httpTimeout);
    } on SocketException catch (e) {
      throw NetworkException('Network error. Check your connection.', e);
    } on HttpException catch (e) {
      throw NetworkException('Network error. Check your connection.', e);
    } catch (e) {
      throw NetworkException('Could not reach LibriVox.', e);
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ServerException('LibriVox returned an error (${response.statusCode}).');
    }

    Map<String, dynamic> json;
    try {
      json = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      throw ParseException('Could not read the response from LibriVox.', e);
    }

    // LibriVox returns {"error": "..."} with a 200/404 status when a query
    // matches nothing, rather than an empty `books` array.
    if (json.containsKey('error') || json['books'] == null) {
      return [];
    }

    final books = json['books'] as List<dynamic>;
    return books.map((b) => LibriVoxAudiobookModel.fromJson(b as Map<String, dynamic>)).toList();
  }

  void dispose() => _client.close();
}
