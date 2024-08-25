import 'package:flutter/material.dart';
import 'dart:async';

class TimelinePage extends StatefulWidget {
  @override
  _TimelinePageState createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  List<List<StickyNoteData>> weeklyNotes = [
    // 1週目
    [
      StickyNoteData(
        id: '1',
        color: Color(0xFF5DE4E6),
        position: Offset(20, 50),
        title: "朝のジョギング",
        content: "30分のランニング",
        startTime: "06:00",
        endTime: "06:30",
      ),
      StickyNoteData(
        id: '2',
        color: Color(0xFFFFEE5C),
        position: Offset(200, 80),
        title: "買い物",
        content: "野菜と牛乳を購入",
        startTime: "17:00",
        endTime: "18:00",
      ),
      StickyNoteData(
        id: '3',
        color: Color(0xFFFF97A5),
        position: Offset(50, 250),
        title: "読書",
        content: "新しい小説を30ページ",
        startTime: "21:00",
        endTime: "22:00",
      ),
      StickyNoteData(
        id: '4',
        color: Color(0xFFB6F77F),
        position: Offset(230, 280),
        title: "料理",
        content: "チキンカレーを作る",
        startTime: "19:00",
        endTime: "20:00",
      ),
    ],
    // 2週目
    [
      StickyNoteData(
        id: '5',
        color: Color(0xFF5DE4E6),
        position: Offset(20, 50),
        title: "瞑想",
        content: "15分の集中瞑想",
        startTime: "07:00",
        endTime: "07:15",
      ),
      StickyNoteData(
        id: '6',
        color: Color(0xFFFFEE5C),
        position: Offset(200, 80),
        title: "掃除",
        content: "リビングの大掃除",
        startTime: "10:00",
        endTime: "12:00",
      ),
      StickyNoteData(
        id: '7',
        color: Color(0xFFFF97A5),
        position: Offset(50, 250),
        title: "映画鑑賞",
        content: "新作アクション映画",
        startTime: "20:00",
        endTime: "22:30",
      ),
      StickyNoteData(
        id: '8',
        color: Color(0xFFB6F77F),
        position: Offset(230, 280),
        title: "ガーデニング",
        content: "新しい花を植える",
        startTime: "15:00",
        endTime: "16:30",
      ),
    ],
    // 3週目
    [
      StickyNoteData(
        id: '9',
        color: Color(0xFF5DE4E6),
        position: Offset(20, 50),
        title: "ヨガ",
        content: "45分のモーニングヨガ",
        startTime: "06:30",
        endTime: "07:15",
      ),
      StickyNoteData(
        id: '10',
        color: Color(0xFFFFEE5C),
        position: Offset(200, 80),
        title: "語学学習",
        content: "フランス語30分",
        startTime: "18:00",
        endTime: "18:30",
      ),
      StickyNoteData(
        id: '11',
        color: Color(0xFFFF97A5),
        position: Offset(50, 250),
        title: "友人とのビデオ通話",
        content: "海外の友人と近況報告",
        startTime: "21:00",
        endTime: "22:00",
      ),
      StickyNoteData(
        id: '12',
        color: Color(0xFFB6F77F),
        position: Offset(230, 280),
        title: "新しいレシピに挑戦",
        content: "ベジタリアンラザニア",
        startTime: "19:00",
        endTime: "20:30",
      ),
    ],
  ];

  int currentWeekIndex = 0;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 5), (Timer t) {
      setState(() {
        currentWeekIndex = (currentWeekIndex + 1) % weeklyNotes.length;
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void addReaction(String noteId) {
    setState(() {
      var note =
          weeklyNotes[currentWeekIndex].firstWhere((note) => note.id == noteId);
      if (note.reactionCount == 0) {
        note.reactionCount = 1;
      } else {
        note.reactionCount++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Timeline'),
      ),
      body: Stack(
        children: [
          GridPaperBackground(),
          ...weeklyNotes[currentWeekIndex]
              .map((note) => LongPressDraggableStickyNote(
                    key: ObjectKey(note),
                    note: note,
                    onDragEnd: (Offset newPosition) {
                      setState(() {
                        note.position = newPosition;
                      });
                    },
                    onTap: () {
                      addReaction(note.id);
                    },
                  )),
        ],
      ),
    );
  }
}

class GridPaperBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: CustomPaint(
        painter: GridPainter(),
        child: Container(),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 0.5;

    for (double i = 0; i < size.width; i += 20) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    for (double i = 0; i < size.height; i += 20) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class StickyNoteData {
  final String id;
  final Color color;
  Offset position;
  final String title;
  final String content;
  final String startTime;
  final String endTime;
  int reactionCount;

  StickyNoteData({
    required this.id,
    required this.color,
    required this.position,
    required this.title,
    required this.content,
    required this.startTime,
    required this.endTime,
    this.reactionCount = 0,
  });
}

class LongPressDraggableStickyNote extends StatelessWidget {
  final StickyNoteData note;
  final Function(Offset) onDragEnd;
  final VoidCallback onTap;

  const LongPressDraggableStickyNote({
    Key? key,
    required this.note,
    required this.onDragEnd,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: note.position.dx,
      top: note.position.dy,
      child: GestureDetector(
        onTap: onTap,
        child: LongPressDraggable<StickyNoteData>(
          data: note,
          feedback: StickyNote(note: note, isBeingDragged: true),
          childWhenDragging: Container(),
          onDragEnd: (details) {
            onDragEnd(details.offset);
          },
          child: StickyNote(note: note),
        ),
      ),
    );
  }
}

class StickyNote extends StatelessWidget {
  final StickyNoteData note;
  final bool isBeingDragged;

  const StickyNote({Key? key, required this.note, this.isBeingDragged = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 180,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isBeingDragged ? note.color.withOpacity(0.8) : note.color,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            note.title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 8),
          Text(
            note.content,
            style: TextStyle(fontSize: 14),
            overflow: TextOverflow.ellipsis,
            maxLines: 3,
          ),
          Spacer(),
          Text(
            '${note.startTime} - ${note.endTime}',
            style: TextStyle(fontSize: 12),
          ),
          SizedBox(height: 4),
          Reaction(count: note.reactionCount),
        ],
      ),
    );
  }
}

class Reaction extends StatelessWidget {
  final int count;

  const Reaction({Key? key, required this.count}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (count == 0) {
      return SizedBox.shrink();
    } else if (count == 1) {
      return Text('👍', style: TextStyle(fontSize: 20));
    } else {
      return Row(
        children: [
          Text('👍', style: TextStyle(fontSize: 20)),
          SizedBox(width: 4),
          Text('$count',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      );
    }
  }
}
