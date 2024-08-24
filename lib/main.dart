import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:math';
import 'input.dart';
import 'timeline.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ja_JP', null);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clock App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('ja', 'JP'),
      ],
      home: MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  @override
  _MainNavigationScreenState createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    ClockScreen(),
    TimelinePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.watch_later),
            label: 'Clock',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timeline),
            label: 'Timeline',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}

class ClockScreen extends StatefulWidget {
  @override
  _ClockScreenState createState() => _ClockScreenState();
}

class _ClockScreenState extends State<ClockScreen> {
  DateTime currentDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // 1秒ごとに現在時刻を更新
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        currentDate = DateTime.now();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 40),
          buildDateSelector(),
          Expanded(child: buildClock()),
        ],
      ),
      floatingActionButton: buildAddButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget buildDateSelector() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.grey),
            onPressed: () {
              // 設定機能の実装
            },
          ),
          Text(
            '${currentDate.year} ${_getMonthName(currentDate.month)} ${currentDate.day.toString().padLeft(2, '0')} ${_getDayOfWeek(currentDate.weekday)}',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          ElevatedButton(
            child: Text('今日へ'),
            onPressed: () {
              setState(() {
                currentDate = DateTime.now();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildClock() {
    return Container(
      padding: EdgeInsets.all(16),
      child: CustomPaint(
        painter: ClockPainter(),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: Center(
            child: Text(
              '${currentDate.hour.toString().padLeft(2, '0')}:${currentDate.minute.toString().padLeft(2, '0')}',
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildAddButton() {
    return FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => InputPage()),
        );
      },
    );
  }

  String _getMonthName(int month) {
    const monthNames = [
      '1月',
      '2月',
      '3月',
      '4月',
      '5月',
      '6月',
      '7月',
      '8月',
      '9月',
      '10月',
      '11月',
      '12月'
    ];
    return monthNames[month - 1];
  }

  String _getDayOfWeek(int day) {
    const dayNames = ['月', '火', '水', '木', '金', '土', '日'];
    return dayNames[day - 1];
  }
}

class ClockPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;

    final paint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, radius, paint);

    for (int i = 0; i < 24; i++) {
      final angle = i * (2 * pi / 24) - pi / 2;
      final hourMarkLength = i % 6 == 0 ? 15.0 : 5.0;

      final start = Offset(
        center.dx + (radius - hourMarkLength) * cos(angle),
        center.dy + (radius - hourMarkLength) * sin(angle),
      );
      final end = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );

      canvas.drawLine(start, end, paint);

      if (i % 6 == 0 && i != 0) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: i.toString(),
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            center.dx + (radius - 30) * cos(angle) - textPainter.width / 2,
            center.dy + (radius - 30) * sin(angle) - textPainter.height / 2,
          ),
        );
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
