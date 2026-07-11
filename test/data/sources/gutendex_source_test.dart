import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pageturn/core/errors/app_exception.dart';
import 'package:pageturn/data/sources/remote/gutendex_source.dart';

http.Response _emptyPage() =>
    http.Response(jsonEncode({'count': 0, 'next': null, 'previous': null, 'results': []}), 200);

void main() {
  group('GutendexSource request building', () {
    late Uri? capturedUri;

    GutendexSource sourceCapturing(http.Response Function(Uri uri) respond) {
      return GutendexSource(
        client: MockClient((request) async {
          capturedUri = request.url;
          return respond(request.url);
        }),
      );
    }

    test('searchBooks sends `search` and `page` query params', () async {
      final source = sourceCapturing((_) => _emptyPage());
      await source.searchBooks('dune', page: 3);

      expect(capturedUri!.path, '/books/');
      expect(capturedUri!.queryParameters['search'], 'dune');
      expect(capturedUri!.queryParameters['page'], '3');
    });

    test('browseByTopic sends the `topic` query param', () async {
      final source = sourceCapturing((_) => _emptyPage());
      await source.browseByTopic('fantasy', page: 1);

      expect(capturedUri!.queryParameters['topic'], 'fantasy');
      expect(capturedUri!.queryParameters['page'], '1');
    });

    test('popularBooks explicitly sends sort=popular', () async {
      final source = sourceCapturing((_) => _emptyPage());
      await source.popularBooks(page: 2);

      expect(capturedUri!.queryParameters['sort'], 'popular');
      expect(capturedUri!.queryParameters['page'], '2');
    });

    test('hasNextPage reflects Gutendex\'s `next` field', () async {
      final source = GutendexSource(
        client: MockClient((request) async => http.Response(
              jsonEncode({'count': 1, 'next': 'https://gutendex.com/books/?page=2', 'previous': null, 'results': []}),
              200,
            )),
      );
      final page = await source.searchBooks('x');
      expect(page.hasNextPage, isTrue);
    });
  });

  group('GutendexSource error mapping', () {
    test('maps a 404 to NotFoundException', () async {
      final source = GutendexSource(client: MockClient((_) async => http.Response('not found', 404)));
      expect(() => source.getBook('999999'), throwsA(isA<NotFoundException>()));
    });

    test('maps a 500 to ServerException', () async {
      final source = GutendexSource(client: MockClient((_) async => http.Response('boom', 500)));
      expect(() => source.searchBooks('x'), throwsA(isA<ServerException>()));
    });

    test('maps invalid JSON to ParseException', () async {
      final source = GutendexSource(client: MockClient((_) async => http.Response('not json {{{', 200)));
      expect(() => source.searchBooks('x'), throwsA(isA<ParseException>()));
    });

    test('maps a thrown network error to NetworkException', () async {
      final source = GutendexSource(client: MockClient((_) async => throw Exception('socket closed')));
      expect(() => source.searchBooks('x'), throwsA(isA<NetworkException>()));
    });
  });
}
