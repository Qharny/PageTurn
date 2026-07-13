import '../../domain/repositories/audio_repository.dart';
import '../../domain/repositories/book_repository.dart';
import '../../domain/repositories/annotation_repository.dart';
import '../sources/local/api_cache_source.dart';
import '../sources/local/hive_local_source.dart';
import '../sources/local/annotation_local_source.dart';
import '../sources/remote/google_books_source.dart';
import '../sources/remote/gutendex_source.dart';
import '../sources/remote/librivox_source.dart';
import '../sources/remote/local_epub_import_source.dart';
import 'audio_repository_impl.dart';
import 'book_repository_impl.dart';
import 'annotation_repository_impl.dart';

/// Wires up the concrete data sources behind the domain repository
/// interfaces. Mirrors the app's existing `Provider.instance` singleton
/// convention (see `LibraryProvider`, `ReadingClubProvider`) rather than
/// introducing a DI package.
class RepositoryLocator {
  RepositoryLocator._();

  static final HiveLocalSource localSource = HiveLocalSource();
  static final ApiCacheSource apiCache = ApiCacheSource();
  static final AnnotationLocalSource annotationLocalSource = AnnotationLocalSource();

  /// Mutable (rather than the repositories below) so tests can swap in a
  /// fake `http.Client`-backed source before the app first touches
  /// [bookRepository]/[audioRepository] — mirrors `init`'s existing
  /// `testDirectoryPath` seam for Hive.
  static GutendexSource gutendex = GutendexSource();
  static GoogleBooksSource googleBooks = GoogleBooksSource();
  static LibriVoxSource libriVox = LibriVoxSource();
  static LocalEpubImportSource importSource = LocalEpubImportSource();

  static BookRepository? _bookRepository;
  static BookRepository get bookRepository => _bookRepository ??= BookRepositoryImpl(
        gutendex: gutendex,
        googleBooks: googleBooks,
        localSource: localSource,
        importSource: importSource,
        cache: apiCache,
      );

  static AudioRepository? _audioRepository;
  static AudioRepository get audioRepository => _audioRepository ??= AudioRepositoryImpl(
        libriVox: libriVox,
        googleBooks: googleBooks,
        localSource: localSource,
        cache: apiCache,
      );

  static AnnotationRepository? _annotationRepository;
  static AnnotationRepository get annotationRepository =>
      _annotationRepository ??= AnnotationRepositoryImpl(localSource: annotationLocalSource);

  /// Must complete before any repository call — opens the local Hive boxes.
  static Future<void> init({String? testDirectoryPath}) async {
    await localSource.init(testDirectoryPath: testDirectoryPath);
    await apiCache.init();
    await annotationLocalSource.init();
  }
}
