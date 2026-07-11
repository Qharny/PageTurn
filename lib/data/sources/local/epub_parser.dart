import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:xml/xml.dart';

import '../../../core/errors/app_exception.dart';
import '../../../domain/entities/chapter.dart';

class ParsedEpubMetadata {
  final String title;
  final String author;
  final Uint8List? coverBytes;

  const ParsedEpubMetadata({required this.title, required this.author, this.coverBytes});
}

class ParsedEpubBook {
  final ParsedEpubMetadata metadata;
  final List<EpubChapterRef> chapters;

  const ParsedEpubBook({required this.metadata, required this.chapters});
}

/// Top-level so it can be run on a background isolate via `compute()` —
/// parsing a large EPUB (hundreds of chapters) synchronously on the UI
/// isolate can block the main thread for many seconds.
ParsedEpubBook parseEpubFile(String path) => EpubParser().parse(File(path));

/// Minimal EPUB (OCF/OPF) parser built on `archive` + `xml`, avoiding the
/// `epubx` package (its `image` dependency conflicts with
/// `flutter_launcher_icons`, already a dev dependency of this project).
///
/// Reads META-INF/container.xml to find the .opf package file, then the
/// .opf's metadata/manifest/spine to resolve title, author, cover image, and
/// chapter content in reading order.
class EpubParser {
  Archive _readArchive(File file) {
    try {
      final bytes = file.readAsBytesSync();
      return ZipDecoder().decodeBytes(bytes);
    } catch (e) {
      throw FileException('This does not look like a valid EPUB file.', e);
    }
  }

  ArchiveFile? _findFile(Archive archive, String path) {
    final normalized = path.replaceAll('\\', '/');
    for (final f in archive.files) {
      if (f.name.replaceAll('\\', '/') == normalized) return f;
    }
    return null;
  }

  String _opfPathFrom(Archive archive) {
    final container = _findFile(archive, 'META-INF/container.xml');
    if (container == null) {
      throw const FileException('This EPUB is missing its container.xml.');
    }
    final doc = XmlDocument.parse(utf8DecodeSafe(container.content as List<int>));
    final rootfileElements = doc.findAllElements('rootfile');
    final rootfile = rootfileElements.isEmpty ? null : rootfileElements.first;
    final path = rootfile?.getAttribute('full-path');
    if (path == null || path.isEmpty) {
      throw const FileException('Could not locate this EPUB\'s content file.');
    }
    return path;
  }

  ParsedEpubBook parse(File file) {
    final archive = _readArchive(file);
    final opfPath = _opfPathFrom(archive);
    final opfFile = _findFile(archive, opfPath);
    if (opfFile == null) {
      throw const FileException('This EPUB\'s package file is missing.');
    }
    final opfDoc = XmlDocument.parse(utf8DecodeSafe(opfFile.content as List<int>));
    final opfDir = opfPath.contains('/') ? opfPath.substring(0, opfPath.lastIndexOf('/') + 1) : '';

    final title = _firstText(opfDoc, 'title') ?? file.uri.pathSegments.last;
    final author = _firstText(opfDoc, 'creator') ?? 'Unknown';

    final manifest = <String, String>{}; // id -> href
    final manifestTypes = <String, String>{}; // id -> media-type/properties
    for (final item in opfDoc.findAllElements('item')) {
      final id = item.getAttribute('id');
      final href = item.getAttribute('href');
      if (id != null && href != null) {
        manifest[id] = href;
        manifestTypes[id] = '${item.getAttribute('media-type') ?? ''}|${item.getAttribute('properties') ?? ''}';
      }
    }

    final coverBytes = _extractCover(archive, opfDoc, manifest, manifestTypes, opfDir);

    final spineIds = opfDoc
        .findAllElements('spine')
        .expand((s) => s.findElements('itemref'))
        .map((e) => e.getAttribute('idref'))
        .whereType<String>()
        .toList();

    final chapters = <EpubChapterRef>[];
    for (var i = 0; i < spineIds.length; i++) {
      final href = manifest[spineIds[i]];
      if (href == null) continue;
      final contentFile = _findFile(archive, '$opfDir$href');
      if (contentFile == null) continue;
      final html = utf8DecodeSafe(contentFile.content as List<int>);
      chapters.add(EpubChapterRef(
        title: _extractChapterTitle(html) ?? 'Chapter ${i + 1}',
        contentHtml: html,
        order: i,
      ));
    }

    if (chapters.isEmpty) {
      throw const FileException('This EPUB has no readable chapters.');
    }

    return ParsedEpubBook(
      metadata: ParsedEpubMetadata(title: title, author: author, coverBytes: coverBytes),
      chapters: chapters,
    );
  }

  /// Cheaper parse used by the quick-add/import flow — metadata + cover only.
  ParsedEpubMetadata parseMetadataOnly(File file) {
    final archive = _readArchive(file);
    final opfPath = _opfPathFrom(archive);
    final opfFile = _findFile(archive, opfPath);
    if (opfFile == null) {
      throw const FileException('This EPUB\'s package file is missing.');
    }
    final opfDoc = XmlDocument.parse(utf8DecodeSafe(opfFile.content as List<int>));
    final opfDir = opfPath.contains('/') ? opfPath.substring(0, opfPath.lastIndexOf('/') + 1) : '';

    final manifest = <String, String>{};
    final manifestTypes = <String, String>{};
    for (final item in opfDoc.findAllElements('item')) {
      final id = item.getAttribute('id');
      final href = item.getAttribute('href');
      if (id != null && href != null) {
        manifest[id] = href;
        manifestTypes[id] = '${item.getAttribute('media-type') ?? ''}|${item.getAttribute('properties') ?? ''}';
      }
    }

    return ParsedEpubMetadata(
      title: _firstText(opfDoc, 'title') ?? file.uri.pathSegments.last,
      author: _firstText(opfDoc, 'creator') ?? 'Unknown',
      coverBytes: _extractCover(archive, opfDoc, manifest, manifestTypes, opfDir),
    );
  }

  Uint8List? _extractCover(
    Archive archive,
    XmlDocument opfDoc,
    Map<String, String> manifest,
    Map<String, String> manifestTypes,
    String opfDir,
  ) {
    String? coverId;
    for (final meta in opfDoc.findAllElements('meta')) {
      if (meta.getAttribute('name') == 'cover') {
        coverId = meta.getAttribute('content');
        break;
      }
    }
    coverId ??= manifestTypes.entries
        .firstWhere((e) => e.value.split('|').last.contains('cover-image'), orElse: () => const MapEntry('', ''))
        .key;
    if (coverId.isEmpty) {
      // Fall back to the first raster image in the manifest.
      coverId = manifestTypes.entries
          .firstWhere((e) => e.value.split('|').first.startsWith('image/'), orElse: () => const MapEntry('', ''))
          .key;
    }
    if (coverId.isEmpty) return null;

    final href = manifest[coverId];
    if (href == null) return null;
    final file = _findFile(archive, '$opfDir$href');
    final content = file?.content;
    if (content == null) return null;
    return Uint8List.fromList(content);
  }

  /// Matches by local element name only (e.g. 'title' matches both
  /// `<title>` and namespace-prefixed `<dc:title>`), since OPF metadata
  /// conventionally uses the `dc:` (Dublin Core) prefix.
  String? _firstText(XmlDocument doc, String localName) {
    for (final element in doc.descendants.whereType<XmlElement>()) {
      if (element.name.local == localName) {
        final text = element.innerText.trim();
        if (text.isNotEmpty) return text;
      }
    }
    return null;
  }

  String? _extractChapterTitle(String html) {
    final match = RegExp(r'<title[^>]*>(.*?)</title>', dotAll: true, caseSensitive: false).firstMatch(html) ??
        RegExp(r'<h[12][^>]*>(.*?)</h[12]>', dotAll: true, caseSensitive: false).firstMatch(html);
    final raw = match?.group(1)?.replaceAll(RegExp(r'<[^>]+>'), '').trim();
    return (raw == null || raw.isEmpty) ? null : raw;
  }
}

String utf8DecodeSafe(List<int> bytes) {
  try {
    return const Utf8Codec(allowMalformed: true).decode(bytes);
  } catch (_) {
    return String.fromCharCodes(bytes);
  }
}
