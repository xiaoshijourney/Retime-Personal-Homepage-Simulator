class ContentItem {
  final String title;
  final String userInfo;
  final String tag;
  final String time;
  final String imageUrl;
  final DateTime dateTime;

  ContentItem({
    required this.title,
    required this.userInfo,
    required this.tag,
    required this.time,
    required this.imageUrl,
    DateTime? dateTime,
  }) : dateTime = dateTime ?? ContentItem._parseTime(time);

  static DateTime _parseTime(String t) {
    try {
      return DateTime.parse(t.replaceFirst(' ', 'T'));
    } catch (_) {}
    try {
      final parts = t.split(' ');
      final d = parts[0].split('-');
      final tm = parts[1].split(':');
      return DateTime(2026, int.parse(d[0]), int.parse(d[1]), int.parse(tm[0]), int.parse(tm[1]));
    } catch (_) {
      return DateTime(2026, 1, 1);
    }
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'userInfo': userInfo,
    'tag': tag,
    'time': time,
    'imageUrl': imageUrl,
    'dateTime': dateTime.toIso8601String(),
  };

  factory ContentItem.fromJson(Map<String, dynamic> json) {
    DateTime dt;
    try {
      dt = DateTime.parse(json['dateTime'] ?? '');
    } catch (_) {
      dt = ContentItem._parseTime(json['time'] ?? '');
    }
    return ContentItem(
      title: json['title'] ?? '',
      userInfo: json['userInfo'] ?? '',
      tag: json['tag'] ?? '',
      time: json['time'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      dateTime: dt,
    );
  }
}
