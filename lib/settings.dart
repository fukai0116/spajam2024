import 'package:flutter/material.dart';
import 'event_storage_service.dart';
import 'event.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final EventStorageService _storageService = EventStorageService();
  List<Event> _events = [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final events = await _storageService.getEvents();
    setState(() {
      _events = events;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('設定'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('保存されたイベント'),
            subtitle: Text('${_events.length}件のイベントが保存されています'),
          ),
          Divider(),
          ..._events.map((event) => ExpansionTile(
                title: Text(event.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${event.date.toString()} ${event.startTime.format(context)} - ${event.endTime.format(context)}'),
                    Text(
                      '応援メッセージ: ${_extractSupportMessage(event.memo)}',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('メモ:'),
                        Text(event.memo),
                      ],
                    ),
                  ),
                ],
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () async {
                    await _storageService.deleteEvent(event.id);
                    _loadEvents();
                  },
                ),
              )),
          ListTile(
            title: Text('全てのイベントを削除'),
            trailing: Icon(Icons.delete_forever),
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('確認'),
                  content: Text('全てのイベントを削除しますか？'),
                  actions: [
                    TextButton(
                      child: Text('キャンセル'),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                    TextButton(
                      child: Text('削除'),
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                await _storageService.deleteAllEvents();
                _loadEvents();
              }
            },
          ),
        ],
      ),
    );
  }

  String _extractSupportMessage(String memo) {
    final parts = memo.split('\n\n応援メッセージ: ');
    if (parts.length > 1) {
      return parts.last;
    }
    return '応援メッセージが見つかりません';
  }
}