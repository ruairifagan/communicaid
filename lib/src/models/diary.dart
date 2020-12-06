import 'package:meta/meta.dart';

class Diary {
  final String color;
  final String desc;
  final String title;
  final String timestamp;

  Diary({
    @required this.color,
    @required this.desc,
    @required this.title,
    @required this.timestamp,
  });

  Diary.fromJson(Map<String, dynamic> parsedJson)
      : color = parsedJson['color'] as String,
        desc = parsedJson['desc'] as String,
        title = parsedJson['title'] as String,
        timestamp = parsedJson['timestamp'] as String;

  Map<String, dynamic> toMap() {
    return {
      'color': color,
      'desc': desc,
      'title': title,
      'timestamp': timestamp,
    };
  }
}