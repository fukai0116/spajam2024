import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';

class InputPage extends StatefulWidget {
  @override
  _InputPageState createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  String eventName = '';
  String memo = '';
  Color selectedColor = Colors.purple;
  DateTime selectedDate = DateTime.now();
  TimeOfDay startTime = TimeOfDay.now();
  TimeOfDay endTime = TimeOfDay.now().replacing(hour: TimeOfDay.now().hour + 1);

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
              onPressed: () {
                // TODO: 保存ロジックを実装
                Navigator.of(context).pop();
              },
              backgroundColor: Colors.blue,
              mini: true,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
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
            TextField(
              decoration: InputDecoration(
                hintText: 'タップして入力',
                border: UnderlineInputBorder(),
              ),
              onChanged: (value) => setState(() => eventName = value),
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
            TextField(
              decoration: InputDecoration(
                hintText: 'タップして入力',
                border: UnderlineInputBorder(),
              ),
              onChanged: (value) => setState(() => memo = value),
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
}

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
                color:
                    Color.fromRGBO(red.round(), green.round(), blue.round(), 1),
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

  Widget buildColorSlider(
      String label, double value, Color color, ValueChanged<double> onChanged) {
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
