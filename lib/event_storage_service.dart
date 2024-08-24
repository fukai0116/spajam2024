import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'event.dart';

class EventStorageService {
  static const String _keyEvents = 'events';

  Future<void> saveEvent(Event event) async {
    final prefs = await SharedPreferences.getInstance();
    final events = await getEvents();
    events.add(event);
    await prefs.setString(_keyEvents, jsonEncode(events.map((e) => e.toJson()).toList()));
  }

  Future<List<Event>> getEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final eventsJson = prefs.getString(_keyEvents);
    if (eventsJson == null) {
      return [];
    }
    final eventsList = jsonDecode(eventsJson) as List;
    return eventsList.map((e) => Event.fromJson(e)).toList();
  }

  Future<void> deleteEvent(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final events = await getEvents();
    events.removeWhere((event) => event.id == id);
    await prefs.setString(_keyEvents, jsonEncode(events.map((e) => e.toJson()).toList()));
  }

  Future<void> updateEvent(Event updatedEvent) async {
    final prefs = await SharedPreferences.getInstance();
    final events = await getEvents();
    final index = events.indexWhere((event) => event.id == updatedEvent.id);
    if (index != -1) {
      events[index] = updatedEvent;
      await prefs.setString(_keyEvents, jsonEncode(events.map((e) => e.toJson()).toList()));
    }
  }
}