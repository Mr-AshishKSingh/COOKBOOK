import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class CookAttendanceScreen extends StatefulWidget {
  final String cookId;
  final String userId;
  final String cookName;

  const CookAttendanceScreen({
    super.key, 
    required this.cookId, 
    required this.userId,
    required this.cookName,
  });

  @override
  State<CookAttendanceScreen> createState() => _CookAttendanceScreenState();
}

class _CookAttendanceScreenState extends State<CookAttendanceScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, bool> _attendanceMap = {};

  @override
  void initState() {
    super.initState();
    _loadAttendance();
  }

  Future<void> _loadAttendance() async {
    final doc = await FirebaseFirestore.instance
        .collection('attendance')
        .doc('${widget.userId}_${widget.cookId}')
        .get();

    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      setState(() {
        _attendanceMap = Map.fromEntries(
          data.entries.map((e) => MapEntry(
            DateTime.parse(e.key),
            e.value as bool,
          )),
        );
      });
    }
  }

  Future<void> _toggleAttendance(DateTime day) async {
    final dateStr = day.toString().split(' ')[0];
    final isPresent = !(_attendanceMap[day] ?? false);

    await FirebaseFirestore.instance
        .collection('attendance')
        .doc('${widget.userId}_${widget.cookId}')
        .set({
      dateStr: isPresent,
    }, SetOptions(merge: true));

    setState(() {
      _attendanceMap[day] = isPresent;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.cookName}\'s Attendance',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.brown[800],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.brown[800]),
      ),
      backgroundColor: const Color(0xFFF8F6F0),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: TableCalendar(
              firstDay: DateTime.utc(2024, 1, 1),
              lastDay: DateTime.utc(2025, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                _toggleAttendance(selectedDay);
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: Colors.brown[700],
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.brown[300],
                  shape: BoxShape.circle,
                ),
              ),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  final isPresent = _attendanceMap[day] ?? false;
                  return Container(
                    margin: const EdgeInsets.all(4),
                    decoration: isPresent
                        ? BoxDecoration(
                            color: Colors.green[100],
                            shape: BoxShape.circle,
                          )
                        : null,
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          color: isPresent ? Colors.green[700] : null,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendItem(
                color: Colors.green[100]!,
                label: 'Present',
              ),
              const SizedBox(width: 16),
              _LegendItem(
                color: Colors.white,
                label: 'Absent',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey[300]!),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.brown[700],
          ),
        ),
      ],
    );
  }
}