/// A single streamable section of a LibriVox audiobook.
class AudiobookChapter {
  final String title;
  final String listenUrl; // direct MP3 stream URL
  final int durationSeconds;
  final int order;

  const AudiobookChapter({
    required this.title,
    required this.listenUrl,
    required this.durationSeconds,
    required this.order,
  });

  factory AudiobookChapter.fromJson(Map<String, dynamic> json) {
    return AudiobookChapter(
      title: (json['title'] as String?)?.trim().isNotEmpty == true
          ? json['title'] as String
          : 'Untitled section',
      listenUrl: json['listenUrl'] as String? ?? '',
      durationSeconds: json['durationSeconds'] as int? ?? 0,
      order: json['order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'listenUrl': listenUrl,
        'durationSeconds': durationSeconds,
        'order': order,
      };
}
