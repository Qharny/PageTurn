import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pageturn/core/errors/app_exception.dart';
import 'package:pageturn/data/sources/local/epub_parser.dart';

/// Builds a minimal-but-valid EPUB (OCF container + OPF package + one
/// XHTML chapter + a cover image) as an in-memory zip, since neither
/// Gutendex nor a device file picker is available in a unit test.
File _buildTestEpub(Directory dir, {String name = 'test.epub'}) {
  final archive = Archive();

  void addText(String path, String content) {
    final bytes = content.codeUnits;
    archive.addFile(ArchiveFile(path, bytes.length, bytes));
  }

  addText('mimetype', 'application/epub+zip');
  addText('META-INF/container.xml', '''
<?xml version="1.0"?>
<container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container">
  <rootfiles>
    <rootfile full-path="OEBPS/content.opf" media-type="application/oebps-package+xml"/>
  </rootfiles>
</container>
''');
  addText('OEBPS/content.opf', '''
<?xml version="1.0"?>
<package xmlns="http://www.idpf.org/2007/opf" version="2.0">
  <metadata xmlns:dc="http://purl.org/dc/elements/1.1/">
    <dc:title>Test Book</dc:title>
    <dc:creator>Ada Lovelace</dc:creator>
    <meta name="cover" content="cover-img"/>
  </metadata>
  <manifest>
    <item id="cover-img" href="cover.jpg" media-type="image/jpeg"/>
    <item id="chap1" href="chap1.xhtml" media-type="application/xhtml+xml"/>
    <item id="chap2" href="chap2.xhtml" media-type="application/xhtml+xml"/>
  </manifest>
  <spine>
    <itemref idref="chap1"/>
    <itemref idref="chap2"/>
  </spine>
</package>
''');
  addText('OEBPS/chap1.xhtml', '''
<html><head><title>Chapter One</title></head>
<body><h1>Chapter One</h1><p>It was a dark and stormy night.</p></body></html>
''');
  addText('OEBPS/chap2.xhtml', '''
<html><head><title>Chapter Two</title></head>
<body><h1>Chapter Two</h1><p>The plot thickens.</p></body></html>
''');
  final coverBytes = List<int>.generate(16, (i) => i);
  archive.addFile(ArchiveFile('OEBPS/cover.jpg', coverBytes.length, coverBytes));

  final zipBytes = ZipEncoder().encode(archive);
  final file = File('${dir.path}/$name');
  file.writeAsBytesSync(zipBytes);
  return file;
}

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('epub_parser_test_');
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  group('EpubParser.parse', () {
    test('extracts title, author, cover bytes, and chapters in spine order', () {
      final file = _buildTestEpub(tempDir);
      final result = EpubParser().parse(file);

      expect(result.metadata.title, 'Test Book');
      expect(result.metadata.author, 'Ada Lovelace');
      expect(result.metadata.coverBytes, isNotNull);
      expect(result.metadata.coverBytes!.length, 16);

      expect(result.chapters, hasLength(2));
      expect(result.chapters[0].title, 'Chapter One');
      expect(result.chapters[0].contentHtml, contains('dark and stormy night'));
      expect(result.chapters[1].title, 'Chapter Two');
      expect(result.chapters[0].order, 0);
      expect(result.chapters[1].order, 1);
    });

    test('throws a user-facing FileException for a corrupt/non-EPUB file', () {
      final garbage = File('${tempDir.path}/corrupt.epub');
      garbage.writeAsBytesSync([1, 2, 3, 4, 5, 6, 7, 8]);

      expect(() => EpubParser().parse(garbage), throwsA(isA<FileException>()));
    });
  });

  group('EpubParser.parseMetadataOnly', () {
    test('extracts metadata without requiring chapter content', () {
      final file = _buildTestEpub(tempDir);
      final metadata = EpubParser().parseMetadataOnly(file);

      expect(metadata.title, 'Test Book');
      expect(metadata.author, 'Ada Lovelace');
      expect(metadata.coverBytes, isNotNull);
    });

    test('throws a user-facing FileException for a corrupt/non-EPUB file', () {
      final garbage = File('${tempDir.path}/corrupt.epub');
      garbage.writeAsBytesSync([9, 9, 9]);

      expect(() => EpubParser().parseMetadataOnly(garbage), throwsA(isA<FileException>()));
    });
  });
}
