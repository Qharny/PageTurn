import '../../domain/repositories/audio_repository.dart';
import '../../domain/repositories/book_repository.dart';
import '../sources/local/hive_local_source.dart';
import '../sources/remote/google_books_source.dart';
import '../sources/remote/gutendex_source.dart';
import '../sources/remote/librivox_source.dart';
import '../sources/remote/local_epub_import_source.dart';
import 'audio_repository_impl.dart';
import 'book_repository_impl.dart';

/// Wires up the concrete data sources behind the domain repository
/// interfaces. Mirrors the app's existing `Provider.instance` singleton
/// convention (see `LibraryProvider`, `ReadingClubProvider`) rather than
/// introducing a DI package.
class RepositoryLocator {
  RepositoryLocator._();

  static final HiveLocalSource localSource = HiveLocalSource();

  static final GutendexSource _gutendex = GutendexSource();
  static final GoogleBooksSource _googleBooks = GoogleBooksSource();
  static final LibriVoxSource _libriVox = LibriVoxSource();
  static final LocalEpubImportSource _importSource = LocalEpubImportSource();

  static final BookRepository bookRepository = BookRepositoryImpl(
    gutendex: _gutendex,
    googleBooks: _googleBooks,
    localSource: localSource,
    importSource: _importSource,
  );

  static final AudioRepository audioRepository = AudioRepositoryImpl(
    libriVox: _libriVox,
    googleBooks: _googleBooks,
    localSource: localSource,
  );

  /// Must complete before any repository call — opens the local Hive index.
  static Future<void> init({String? testDirectoryPath}) =>
      localSource.init(testDirectoryPath: testDirectoryPath);
}
