import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pageturn/data/repositories/book_repository_impl.dart';
import 'package:pageturn/data/sources/local/api_cache_source.dart';
import 'package:pageturn/data/sources/local/hive_local_source.dart';
import 'package:pageturn/data/sources/remote/google_books_source.dart';
import 'package:pageturn/data/sources/remote/gutendex_source.dart';
import 'package:pageturn/data/sources/remote/local_epub_import_source.dart';

Future<void> main() async {
  final tempDir = Directory.systemTemp.createTempSync('debug_cache_');
  final localSource = HiveLocalSource();
  await localSource.init(testDirectoryPath: tempDir.path);
  final apiCache = ApiCacheSource();
  await apiCache.init();

  final fixture = File('test/fixtures/gutendex_search_alice.json').readAsStringSync();
  print('fixture results count: ${(jsonDecode(fixture) as Map)['results'].length}');

  final gutendex = GutendexSource(
    client: MockClient((request) async {
      print('MOCK CLIENT CALLED: ${request.url}');
      return http.Response(fixture, 200);
    }),
  );

  final repo = BookRepositoryImpl(
    gutendex: gutendex,
    googleBooks: GoogleBooksSource(),
    localSource: localSource,
    importSource: LocalEpubImportSource(),
    cache: apiCache,
  );

  final popular = await repo.popularBooks();
  print('popular.length = ${popular.length}');
  for (final b in popular) {
    print(' - ${b.title}');
  }

  final spotlight = await repo.browseByTopic('african');
  print('spotlight.length = ${spotlight.length}');
}
