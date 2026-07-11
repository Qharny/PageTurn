import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/errors/app_exception.dart';
import '../../../domain/entities/book.dart';
import '../local/epub_parser.dart';

/// Lets the user pick an EPUB from device storage, copies it into app
/// storage, and parses just enough metadata (title, author, cover) to add
/// it to the library. Corrupt/unparseable files fail with a typed
/// [FileException] instead of crashing, and any partially-copied file is
/// cleaned up.
class LocalEpubImportSource {
  final EpubParser _parser;

  LocalEpubImportSource({EpubParser? parser}) : _parser = parser ?? EpubParser();

  /// Returns null if the user cancelled the picker.
  Future<Book?> pickAndImport() async {
    FilePickerResult? result;
    try {
      result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['epub'],
      );
    } catch (e) {
      throw FileException('Could not open the file picker.', e);
    }

    if (result == null || result.files.isEmpty || result.files.single.path == null) {
      return null;
    }

    final pickedPath = result.files.single.path!;
    final id = 'local_${DateTime.now().millisecondsSinceEpoch}';

    final docsDir = await getApplicationDocumentsDirectory();
    final epubDir = Directory('${docsDir.path}/epubs');
    if (!await epubDir.exists()) {
      await epubDir.create(recursive: true);
    }
    final destPath = '${epubDir.path}/$id.epub';

    try {
      await File(pickedPath).copy(destPath);
    } catch (e) {
      throw FileException('Could not import this file.', e);
    }

    final ParsedEpubMetadata metadata;
    try {
      metadata = _parser.parseMetadataOnly(File(destPath));
    } catch (e) {
      try {
        await File(destPath).delete();
      } catch (_) {
        // best-effort cleanup only
      }
      rethrow;
    }

    String? coverPath;
    if (metadata.coverBytes != null) {
      final coversDir = Directory('${docsDir.path}/covers');
      if (!await coversDir.exists()) {
        await coversDir.create(recursive: true);
      }
      coverPath = '${coversDir.path}/$id.jpg';
      await File(coverPath).writeAsBytes(metadata.coverBytes!);
    }

    return Book(
      id: id,
      title: metadata.title,
      author: metadata.author,
      coverAsset: '',
      coverUrl: coverPath,
      rating: 0,
      reviewCount: '0',
      length: '',
      audioDuration: '',
      language: 'Eng',
      description: 'Imported from your device.',
      tags: const [],
      reviews: const [],
      sourceType: BookSourceType.localImport,
      localFilePath: destPath,
    );
  }
}
