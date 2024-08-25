import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'dart:async';
import 'input.dart';
import 'timeline.dart';
import 'dart:ui' as ui;
import 'settings.dart';
import 'event.dart';
import 'event_storage_service.dart';

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

class AnimatedSupportMessage extends StatefulWidget {
  final String message;

  AnimatedSupportMessage({required this.message});

  @override
  _AnimatedSupportMessageState createState() => _AnimatedSupportMessageState();
}

class _AnimatedSupportMessageState extends State<AnimatedSupportMessage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Text(
                widget.message,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
    );
  }
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
  bool showColon = true;
  bool showTaskTime = false;
  late Timer timer;
  final EventStorageService _storageService = EventStorageService();
  List<Event> _events = [];
  String? currentSupportMessage;
  Event? currentEvent;
  Event? nextEvent;
  Color backgroundColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _loadEvents();
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        currentDate = DateTime.now();
        showColon = !showColon;
        _checkCurrentEvent();
        _checkNextEvent();
      });
    });
  }

  void _checkNextEvent() {
    final now = DateTime.now();
    setState(() {
      nextEvent = null;
    });

    for (var event in _events) {
      final startDateTime = DateTime(
        event.date.year,
        event.date.month,
        event.date.day,
        event.startTime.hour,
        event.startTime.minute,
      );

      if (startDateTime.isAfter(now)) {
        setState(() {
          nextEvent = event;
        });
        return;
      }
    }
  }

  Widget buildClock() {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              showTaskTime = !showTaskTime;
            });
          },
          child: Container(
            padding: EdgeInsets.all(16),
            child: CustomPaint(
              painter: ClockPainter(
                currentTime: currentDate,
                backgroundColor: backgroundColor,
                currentEvent: currentEvent,
                showTaskTime: showTaskTime,
              ),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _getDisplayTime(),
                        style: TextStyle(
                            fontSize: 40, fontWeight: FontWeight.bold),
                      ),
                      if (currentEvent != null) ...[
                        SizedBox(height: 20),
                        Text(
                          currentEvent!.name,
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10),
                        Text(
                          currentEvent!.memo,
                          style: TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (nextEvent != null)
          Positioned(
            left: 20,
            bottom: 20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: nextEvent!.color.withOpacity(0.7), // ここを変更
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    '次:\n${nextEvent!.name}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _loadEvents() async {
    final events = await _storageService.getEvents();
    setState(() {
      _events = events;
    });
  }

  void _checkCurrentEvent() {
    final now = DateTime.now();
    setState(() {
      currentEvent = null;
      backgroundColor = Colors.white;
      currentSupportMessage = null;
    });

    for (var event in _events) {
      final startDateTime = DateTime(
        event.date.year,
        event.date.month,
        event.date.day,
        event.startTime.hour,
        event.startTime.minute,
      );
      final endDateTime = DateTime(
        event.date.year,
        event.date.month,
        event.date.day,
        event.endTime.hour,
        event.endTime.minute,
      );

      if (now.isAfter(startDateTime) && now.isBefore(endDateTime)) {
        setState(() {
          currentEvent = event;
          backgroundColor = event.color;
          currentSupportMessage = event.supportMessage;
        });
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 40),
          buildDateSelector(),
          Expanded(child: buildClock()),
          if (currentSupportMessage != null)
            AnimatedSupportMessage(message: currentSupportMessage!),
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
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

  String _getDisplayTime() {
    if (!showTaskTime || currentEvent == null) {
      return '${currentDate.hour.toString().padLeft(2, '0')}:${currentDate.minute.toString().padLeft(2, '0')}';
    } else {
      final startTime = currentEvent!.startTime;
      final endTime = currentEvent!.endTime;
      return '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')} - ${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
    }
  }

  Widget buildAddButton() {
    return FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => InputPage()),
        ).then((_) => _loadEvents());
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

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }
}

class ClockPainter extends CustomPainter {
  final DateTime currentTime;
  final Color backgroundColor;
  final Event? currentEvent;
  final bool showTaskTime;

  ClockPainter({
    required this.currentTime,
    required this.backgroundColor,
    required this.currentEvent,
    required this.showTaskTime,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;

    // 背景を描画
    final backgroundPaint = Paint()..color = backgroundColor;
    canvas.drawCircle(center, radius, backgroundPaint);

    // 時計の外枠を描画
    final outlinePaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, radius, outlinePaint);

    // プログレスバーを描画
    final progressPaint = Paint()
      ..color = showTaskTime ? Colors.orange : Colors.blue // ここを変更
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    double progress;
    if (showTaskTime && currentEvent != null) {
      final startTime = _timeOfDayToDateTime(currentEvent!.startTime);
      final endTime = _timeOfDayToDateTime(currentEvent!.endTime);
      final totalDuration = endTime.difference(startTime).inSeconds;
      final elapsedDuration = currentTime.difference(startTime).inSeconds;
      progress = elapsedDuration / totalDuration;
    } else {
      progress = (currentTime.hour * 3600 +
              currentTime.minute * 60 +
              currentTime.second) /
          (24 * 3600);
    }

    final sweepAngle = 2 * pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );

    // 時間のマーカーを描画
    final markerPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

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

      canvas.drawLine(start, end, markerPaint);

      if (i % 6 == 0) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: i == 0 ? '24' : i.toString(),
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
          textDirection: ui.TextDirection.ltr,
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

  DateTime _timeOfDayToDateTime(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    return DateTime(
        now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
