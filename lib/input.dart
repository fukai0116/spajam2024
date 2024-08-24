import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';
import 'event.dart';
import 'event_storage_service.dart';

class InputPage extends StatefulWidget {
  @override
  _InputPageState createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  final _formKey = GlobalKey<FormState>();
  final _storageService = EventStorageService();
  String eventName = '';
  String memo = '';
  Color selectedColor = Colors.purple;
  DateTime selectedDate = DateTime.now();
  TimeOfDay startTime = TimeOfDay.now();
  TimeOfDay endTime = TimeOfDay.now().replacing(hour: TimeOfDay.now().hour + 1);

  // 事前に用意した応援メッセージのリスト
  final List<String> supportMessages = [
    'がんばってください！',
    '素晴らしい一日になりますように！',
    'あなたならできる！',
    '最高の結果を期待しています！',
    '頑張る姿を応援しています！',
    '目標達成を信じています！',
    'あなたの成功を祈っています！',
    'ポジティブな気持ちで頑張りましょう！',
    '全力で応援しています！',
    'きっと素晴らしい結果が待っています！',
  ];

  // ランダムな応援メッセージを取得する関数
  String getRandomSupportMessage() {
    final random = Random();
    return supportMessages[random.nextInt(supportMessages.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('新しい予定'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton(
              child: Icon(Icons.save),
              onPressed: _saveEvent,
              backgroundColor: Colors.blue,
              mini: true,
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('yyyy/M/d(E)', 'ja_JP').format(selectedDate),
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),
              Text('予定名'),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'タップして入力',
                  border: UnderlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '予定名を入力してください';
                  }
                  return null;
                },
                onSaved: (value) => eventName = value!,
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('開始時刻'),
                        InkWell(
                          onTap: () => _selectTime(context, true),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              border: UnderlineInputBorder(),
                            ),
                            child: Text(startTime.format(context)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('終了時刻'),
                        InkWell(
                          onTap: () => _selectTime(context, false),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              border: UnderlineInputBorder(),
                            ),
                            child: Text(endTime.format(context)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text('メモ'),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'タップして入力',
                  border: UnderlineInputBorder(),
                ),
                onSaved: (value) => memo = value!,
              ),
              SizedBox(height: 20),
              Text('色の選択'),
              SizedBox(height: 10),
              RGBColorPicker(
                selectedColor: selectedColor,
                onColorChanged: (color) => setState(() => selectedColor = color),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? startTime : endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startTime = picked;
        } else {
          endTime = picked;
        }
      });
    }
  }

  void _saveEvent() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final supportMessage = getRandomSupportMessage();
      final event = Event(
        id: Uuid().v4(),
        name: eventName,
        date: selectedDate,
        startTime: startTime,
        endTime: endTime,
        memo: memo + '\n\n応援メッセージ: ' + supportMessage,
        color: selectedColor,
      );

      try {
        await _storageService.saveEvent(event);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('イベントが保存されました')),
        );
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('イベントの保存に失敗しました')),
        );
      }
    }
  }
}

// RGBColorPickerクラスは変更なし
class RGBColorPicker extends StatefulWidget {
  final Color selectedColor;
  final ValueChanged<Color> onColorChanged;

  RGBColorPicker({required this.selectedColor, required this.onColorChanged});

  @override
  _RGBColorPickerState createState() => _RGBColorPickerState();
}

class _RGBColorPickerState extends State<RGBColorPicker> {
  late double red, green, blue;

  @override
  void initState() {
    super.initState();
    red = widget.selectedColor.red.toDouble();
    green = widget.selectedColor.green.toDouble();
    blue = widget.selectedColor.blue.toDouble();
  }

  void updateColor() {
    final color = Color.fromRGBO(red.round(), green.round(), blue.round(), 1);
    widget.onColorChanged(color);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 50,
                color: Color.fromRGBO(red.round(), green.round(), blue.round(), 1),
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        buildColorSlider('R', red, Colors.red, (value) {
          setState(() => red = value);
          updateColor();
        }),
        buildColorSlider('G', green, Colors.green, (value) {
          setState(() => green = value);
          updateColor();
        }),
        buildColorSlider('B', blue, Colors.blue, (value) {
          setState(() => blue = value);
          updateColor();
        }),
      ],
    );
  }

  Widget buildColorSlider(String label, double value, Color color, ValueChanged<double> onChanged) {
    return Row(
      children: [
        Container(
          width: 20,
          child: Text(label),
        ),
        Expanded(
          child: Slider(
            value: value,
            min: 0,
            max: 255,
            activeColor: color,
            inactiveColor: color.withOpacity(0.3),
            onChanged: onChanged,
          ),
        ),
        Container(
          width: 40,
          child: Text(value.round().toString()),
        ),
      ],
    );
  }
}