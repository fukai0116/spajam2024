import 'package:flutter/material.dart';

class Event {
  String id;
  String name;
  DateTime date;
  TimeOfDay startTime;
  TimeOfDay endTime;
  String memo;
  String supportMessage;
  Color color;

  Event({
    required this.id,
    required this.name,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.memo,
    required this.supportMessage,
    required this.color,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      name: json['name'],
      date: DateTime.parse(json['date']),
      startTime: TimeOfDay(
          hour: json['startTime']['hour'], minute: json['startTime']['minute']),
      endTime: TimeOfDay(
          hour: json['endTime']['hour'], minute: json['endTime']['minute']),
      memo: json['memo'],
      supportMessage: json['supportMessage'], // JSONからの読み込みに追加
      color: Color(json['color']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date': date.toIso8601String(),
      'startTime': {'hour': startTime.hour, 'minute': startTime.minute},
      'endTime': {'hour': endTime.hour, 'minute': endTime.minute},
      'memo': memo,
      'supportMessage': supportMessage, // JSONへの変換に追加
      'color': color.value,
    };
  }
}
