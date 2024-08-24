import 'package:flutter/material.dart';

class InputPage extends StatefulWidget {
  @override
  _InputPageState createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  String eventName = '';
  String memo = '';
  Color selectedColor = Colors.purple;

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
          TextButton(
            child: Text('保存', style: TextStyle(color: Colors.white)),
            onPressed: () {
              // TODO: 保存ロジックを実装
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('2024/9/2(月)', style: TextStyle(fontSize: 18)),
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
