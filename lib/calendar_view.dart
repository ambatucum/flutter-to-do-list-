import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'edittask.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // Map untuk menyimpan tugas per hari
  Map<DateTime, List<Map<String, dynamic>>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final tasksRef = _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('tasks');

    final snapshot = await tasksRef.get();
    final events = <DateTime, List<Map<String, dynamic>>>{};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final timestamp = data['timestamp'] as Timestamp?;
      if (timestamp != null) {
        final date = timestamp.toDate();
        final day = DateTime(date.year, date.month, date.day);

        if (events[day] == null) events[day] = [];
        events[day]!.add({...data, 'id': doc.id});
      }
    }

    setState(() {
      _events = events;
    });
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  Color _getTaskColor(Map<String, dynamic> task) {
    final timestamp = task['timestamp'] as Timestamp?;
    if (timestamp == null) return Colors.grey;

    final deadline = timestamp.toDate();
    final now = DateTime.now();
    final diff = deadline.difference(now).inHours;

    if (diff <= 24) return Colors.red;
    if (diff <= 72) return Colors.amber;
    return Colors.green;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
  }

  void _editTask(String docId, String text, DateTime dateTime) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => EditTaskScreen(
              docId: docId,
              existingText: text,
              existingDateTime: dateTime,
            ),
      ),
    ).then((_) => _loadEvents());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFFFE5D0), // peach
                  Color(0xFFFFB199), // orange
                  Color(0xFFFFD6E0), // pink muda
                  Color(0xFFFFFFFF), // putih
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Soft spots
          Positioned(
            left: -80,
            top: 80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(0xFFFFB199).withOpacity(0.5),
                    Colors.transparent,
                  ],
                  radius: 0.8,
                ),
              ),
            ),
          ),
          Positioned(
            right: -60,
            bottom: 60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(0xFFFF8C94).withOpacity(0.4),
                    Colors.transparent,
                  ],
                  radius: 0.8,
                ),
              ),
            ),
          ),
          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Header
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Calendar View',
                        style: GoogleFonts.merriweather(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Calendar
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TableCalendar(
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: _focusedDay,
                      calendarFormat: _calendarFormat,
                      selectedDayPredicate: (day) {
                        return isSameDay(_selectedDay, day);
                      },
                      onDaySelected: _onDaySelected,
                      onFormatChanged: (format) {
                        setState(() {
                          _calendarFormat = format;
                        });
                      },
                      onPageChanged: (focusedDay) {
                        _focusedDay = focusedDay;
                      },
                      calendarStyle: CalendarStyle(
                        markersMaxCount: 3,
                        markerDecoration: BoxDecoration(
                          color: theme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      eventLoader: _getEventsForDay,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Selected day tasks
                  Expanded(
                    child: Card(
                      color: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tasks for ${DateFormat('EEEE, d MMMM yyyy').format(_selectedDay!)}',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Color(0xFF9B1C1C),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: ListView.builder(
                                itemCount:
                                    _getEventsForDay(_selectedDay!).length,
                                itemBuilder: (context, index) {
                                  final task =
                                      _getEventsForDay(_selectedDay!)[index];
                                  final timestamp =
                                      task['timestamp'] as Timestamp?;
                                  final dateTime = timestamp?.toDate();

                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(
                                        color: _getTaskColor(task),
                                        width: 2,
                                      ),
                                    ),
                                    child: ListTile(
                                      title: Text(
                                        task['text'] ?? '',
                                        style: TextStyle(
                                          decoration:
                                              (task['isCompleted'] ?? false)
                                                  ? TextDecoration.lineThrough
                                                  : null,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (task['desc']?.isNotEmpty ??
                                              false) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              task['desc'],
                                              style: theme.textTheme.bodySmall,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                          const SizedBox(height: 4),
                                          Text(
                                            dateTime != null
                                                ? DateFormat(
                                                  'HH:mm',
                                                ).format(dateTime)
                                                : 'No time set',
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                  color: _getTaskColor(task),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                        ],
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Checkbox(
                                            value: task['isCompleted'] ?? false,
                                            onChanged: (value) async {
                                              await _firestore
                                                  .collection('users')
                                                  .doc(_auth.currentUser!.uid)
                                                  .collection('tasks')
                                                  .doc(task['id'])
                                                  .update({
                                                    'isCompleted': value,
                                                  });
                                              _loadEvents();
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.edit),
                                            onPressed:
                                                () => _editTask(
                                                  task['id'],
                                                  task['text'],
                                                  dateTime ?? DateTime.now(),
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
