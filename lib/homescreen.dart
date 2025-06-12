import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'addtask.dart';
import 'auth_service.dart';
import 'edittask.dart';
import 'login.dart';
import 'calendar_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _controller = TextEditingController();
  final _searchController = TextEditingController();
  String _searchQuery = '';
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }

  String getToday() {
    final now = DateTime.now();
    final hari = [
      'Minggu',
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
    ];
    return '${hari[now.weekday % 7]}, ${DateFormat('d MMMM yyyy').format(now)}';
  }

  Future<void> addTask(String text) async {
    if (text.isEmpty) return;
    await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('tasks')
        .add({'text': text, 'timestamp': FieldValue.serverTimestamp()});
    _controller.clear();
  }

  Future<void> updateTask(String docId, String text) async {
    await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('tasks')
        .doc(docId)
        .update({'text': text});
    _controller.clear();
  }

  Future<void> deleteTask(String docId) async {
    await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('tasks')
        .doc(docId)
        .delete();
  }

  void _signOut() async {
    await AuthService().signOut();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SignInScreen()),
    );
  }

  void _addTask() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddTaskScreen()),
    );
  }

  void _editTask(
    String docId,
    String text,
    DateTime dateTime,
    String category,
    String priority,
  ) {
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
    );
  }

  Future<void> _toggleDone(String docId, bool isDone) async {
    await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('tasks')
        .doc(docId)
        .update({'isCompleted': !isDone});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tasksRef = _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('tasks')
        .orderBy('timestamp');

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Gradient utama
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
          // Soft spot pink/orange
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
          // Panel dan konten utama
          SafeArea(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Header
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Image.asset('assets/dasker.png', height: 48),
                              const SizedBox(width: 12),
                              Text(
                                'Dasker',
                                style: GoogleFonts.merriweather(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red[800],
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Container(
                            margin: const EdgeInsets.only(top: 4, right: 8),
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const CalendarView(),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.calendar_month),
                                  tooltip: 'Calendar View',
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      theme.primaryColor,
                                    ),
                                    foregroundColor: MaterialStateProperty.all(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                FloatingActionButton(
                                  onPressed: _addTask,
                                  backgroundColor: theme.primaryColor,
                                  foregroundColor: Colors.white,
                                  elevation: 2,
                                  shape: const CircleBorder(),
                                  child: const Icon(Icons.add, size: 36),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          getToday(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Progress bar mingguan
                      _WeeklyProgressBar(tasksRef: tasksRef),
                      const SizedBox(height: 16),
                      // Search bar
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) {
                            setState(() {
                              _searchQuery = val.trim();
                            });
                          },
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon:
                                _searchQuery.isNotEmpty
                                    ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() {
                                          _searchQuery = '';
                                        });
                                      },
                                    )
                                    : null,
                            hintText: 'Cari tugas...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: theme.primaryColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: theme.primaryColor,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 0,
                              horizontal: 16,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Grid To-Do List
                            Expanded(
                              flex: 3,
                              child: Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                color: Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'To-Do List',
                                        style: theme.textTheme.titleLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: theme.primaryColor,
                                            ),
                                      ),
                                      const SizedBox(height: 12),
                                      Expanded(
                                        child: StreamBuilder<QuerySnapshot>(
                                          stream: tasksRef.snapshots(),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasError) {
                                              return Center(
                                                child: Text(
                                                  'Terjadi kesalahan',
                                                ),
                                              );
                                            }
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              );
                                            }
                                            if (!snapshot.hasData ||
                                                snapshot.data!.docs.isEmpty) {
                                              return Center(
                                                child: Text(
                                                  'Belum ada tugas. Tambahkan dengan tombol +',
                                                  style:
                                                      theme
                                                          .textTheme
                                                          .bodyMedium,
                                                ),
                                              );
                                            }
                                            final docs = snapshot.data!.docs;
                                            // Urutkan berdasarkan deadline terdekat
                                            final sortedDocs = List.from(docs)
                                              ..sort((a, b) {
                                                var ta =
                                                    (a.data()
                                                            as Map<
                                                              String,
                                                              dynamic
                                                            >)['timestamp']
                                                        as Timestamp?;
                                                var tb =
                                                    (b.data()
                                                            as Map<
                                                              String,
                                                              dynamic
                                                            >)['timestamp']
                                                        as Timestamp?;
                                                if (ta == null || tb == null)
                                                  return 0;
                                                return ta.compareTo(tb);
                                              });
                                            // Filter berdasarkan search query (judul)
                                            final filteredDocs =
                                                _searchQuery.isEmpty
                                                    ? sortedDocs
                                                    : sortedDocs.where((doc) {
                                                      final data =
                                                          doc.data()
                                                              as Map<
                                                                String,
                                                                dynamic
                                                              >;
                                                      final text =
                                                          (data['text'] ?? '')
                                                              .toString()
                                                              .toLowerCase();
                                                      return text.contains(
                                                        _searchQuery
                                                            .toLowerCase(),
                                                      );
                                                    }).toList();
                                            if (filteredDocs.isEmpty) {
                                              return Center(
                                                child: Text(
                                                  'Tidak ada tugas yang cocok.',
                                                  style:
                                                      theme
                                                          .textTheme
                                                          .bodyMedium,
                                                ),
                                              );
                                            }
                                            return GridView.builder(
                                              gridDelegate:
                                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount: 2,
                                                    crossAxisSpacing: 16,
                                                    mainAxisSpacing: 16,
                                                    childAspectRatio: 1.2,
                                                  ),
                                              itemCount: filteredDocs.length,
                                              itemBuilder: (context, index) {
                                                var doc = filteredDocs[index];
                                                var data =
                                                    doc.data()
                                                        as Map<String, dynamic>;
                                                var text =
                                                    data['text'] as String;
                                                var desc =
                                                    data['desc'] as String? ??
                                                    '';
                                                var timestamp =
                                                    data['timestamp']
                                                        as Timestamp?;
                                                DateTime? dateTime =
                                                    timestamp?.toDate();
                                                var category =
                                                    (data['category'] ??
                                                            'Lainnya')
                                                        as String;
                                                var isCompleted =
                                                    (data['isCompleted'] ??
                                                        false) ==
                                                    true;
                                                Color catColor = _categoryColor(
                                                  category,
                                                );
                                                return TaskBox(
                                                  docId: doc.id,
                                                  text: text,
                                                  desc: desc,
                                                  dateTime: dateTime,
                                                  category: category,
                                                  isCompleted: isCompleted,
                                                  catColor: catColor,
                                                  onEdit:
                                                      () => _editTask(
                                                        doc.id,
                                                        text,
                                                        dateTime ??
                                                            DateTime.now(),
                                                        category,
                                                        '',
                                                      ),
                                                  onDelete:
                                                      () => deleteTask(doc.id),
                                                  onToggleDone:
                                                      (_) => _toggleDone(
                                                        doc.id,
                                                        isCompleted,
                                                      ),
                                                  theme: theme,
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 24),
                            // Statistik Kanan
                            Expanded(
                              flex: 1,
                              child: Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                color: Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Statistik',
                                        style: theme.textTheme.titleLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: theme.primaryColor,
                                            ),
                                      ),
                                      const SizedBox(height: 24),
                                      _TaskBarChart(tasksRef: tasksRef),
                                      const SizedBox(height: 24),
                                      _TaskStats(tasksRef: tasksRef),
                                      const SizedBox(height: 24),
                                      _TaskAvgTime(tasksRef: tasksRef),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Tombol logout kiri bawah
                Positioned(
                  left: 24,
                  bottom: 24,
                  child: ElevatedButton.icon(
                    onPressed: _signOut,
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: const Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[700],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Helper warna kategori
Color _categoryColor(String cat) {
  switch (cat.toLowerCase()) {
    case 'kuliah':
      return Colors.blue;
    case 'kerja':
      return Colors.orange;
    case 'pribadi':
      return Colors.purple;
    default:
      return Colors.grey;
  }
}

// Ganti fungsi warna prioritas menjadi otomatis berdasarkan deadline
Color _priorityColorByDeadline(DateTime? deadline) {
  if (deadline == null) return Colors.grey;
  final now = DateTime.now();
  final diff = deadline.difference(now).inHours;
  if (diff <= 24) return Colors.red; // <= 1 hari
  if (diff <= 72) return Colors.amber; // <= 3 hari
  return Colors.green; // > 3 hari
}

String _priorityLabelByDeadline(DateTime? deadline) {
  if (deadline == null) return 'Tidak diketahui';
  final now = DateTime.now();
  final diff = deadline.difference(now).inHours;
  if (diff <= 24) return 'Prioritas Utama';
  if (diff <= 72) return 'Segera Dikerjakan';
  return 'Bisa Nanti';
}

// Progress bar mingguan
class _WeeklyProgressBar extends StatelessWidget {
  final Query tasksRef;
  const _WeeklyProgressBar({required this.tasksRef});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: tasksRef.snapshots(),
      builder: (context, snapshot) {
        int total = 0;
        int selesai = 0;
        final now = DateTime.now();
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            var data = doc.data() as Map<String, dynamic>;
            var ts = data['timestamp'] as Timestamp?;
            if (ts != null && ts.toDate().isAfter(weekStart)) {
              total++;
              if ((data['isCompleted'] ?? false) == true) selesai++;
            }
          }
        }
        double percent = total == 0 ? 0 : selesai / total;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Progress Mingguan',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: percent,
              minHeight: 10,
              backgroundColor: Colors.grey[200],
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            const SizedBox(height: 4),
            Text(
              '${(percent * 100).toStringAsFixed(0)}% dari $total tugas minggu ini',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        );
      },
    );
  }
}

// Grafik batang jumlah tugas per hari minggu ini
class _TaskBarChart extends StatelessWidget {
  final Query tasksRef;
  const _TaskBarChart({required this.tasksRef});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: tasksRef.snapshots(),
      builder: (context, snapshot) {
        final now = DateTime.now();
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final days = List.generate(7, (i) => weekStart.add(Duration(days: i)));
        final counts = List.filled(7, 0);
        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            var data = doc.data() as Map<String, dynamic>;
            var ts = data['timestamp'] as Timestamp?;
            if (ts != null) {
              for (int i = 0; i < 7; i++) {
                if (ts.toDate().year == days[i].year &&
                    ts.toDate().month == days[i].month &&
                    ts.toDate().day == days[i].day) {
                  counts[i]++;
                }
              }
            }
          }
        }
        return SizedBox(
          height: 60,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (i) {
              return Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      height: counts[i] * 12.0,
                      width: 16,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('E').format(days[i]),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

// Statistik tambahan
class _TaskStats extends StatelessWidget {
  final Query tasksRef;
  const _TaskStats({required this.tasksRef});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: tasksRef.snapshots(),
      builder: (context, snapshot) {
        int total = 0;
        int selesai = 0;
        int overdue = 0;
        final now = DateTime.now();
        if (snapshot.hasData) {
          total = snapshot.data!.docs.length;
          for (var doc in snapshot.data!.docs) {
            var data = doc.data() as Map<String, dynamic>;
            if ((data['isCompleted'] ?? false) == true) selesai++;
            var timestamp = data['timestamp'] as Timestamp?;
            if (timestamp != null && (data['isCompleted'] ?? false) != true) {
              if (timestamp.toDate().isBefore(now)) overdue++;
            }
          }
        }
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total', style: Theme.of(context).textTheme.bodyMedium),
                Text('$total', style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Selesai', style: Theme.of(context).textTheme.bodyMedium),
                Text('$selesai', style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Terlambat',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '$overdue',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.red),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

// Rata-rata waktu penyelesaian tugas
class _TaskAvgTime extends StatelessWidget {
  final Query tasksRef;
  const _TaskAvgTime({required this.tasksRef});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: tasksRef.snapshots(),
      builder: (context, snapshot) {
        int selesai = 0;
        int totalMinutes = 0;
        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            var data = doc.data() as Map<String, dynamic>;
            if ((data['isCompleted'] ?? false) == true &&
                data['createdAt'] != null &&
                data['timestamp'] != null) {
              var created = (data['createdAt'] as Timestamp).toDate();
              var deadline = (data['timestamp'] as Timestamp).toDate();
              totalMinutes += deadline.difference(created).inMinutes.abs();
              selesai++;
            }
          }
        }
        if (selesai == 0) {
          return Text(
            'Belum ada tugas selesai',
            style: Theme.of(context).textTheme.bodySmall,
          );
        }
        final avg = (totalMinutes / selesai).round();
        return Text(
          'Rata-rata waktu penyelesaian: $avg menit',
          style: Theme.of(context).textTheme.bodySmall,
        );
      },
    );
  }
}

// Tambahkan widget TaskBox
class TaskBox extends StatefulWidget {
  final String docId;
  final String text;
  final String desc;
  final DateTime? dateTime;
  final String category;
  final bool isCompleted;
  final Color catColor;
  final Function() onEdit;
  final Function() onDelete;
  final Function(bool) onToggleDone;
  final ThemeData theme;
  const TaskBox({
    super.key,
    required this.docId,
    required this.text,
    required this.desc,
    required this.dateTime,
    required this.category,
    required this.isCompleted,
    required this.catColor,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleDone,
    required this.theme,
  });
  @override
  State<TaskBox> createState() => _TaskBoxState();
}

class _TaskBoxState extends State<TaskBox> {
  bool isHovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onEdit,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          transform:
              isHovered
                  ? (Matrix4.identity()..scale(1.03))
                  : Matrix4.identity(),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.isCompleted ? Colors.grey[100] : Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
            boxShadow:
                isHovered
                    ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.10),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                    : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
            border: Border.all(
              color:
                  widget.isCompleted
                      ? Colors.green
                      : _priorityColorByDeadline(widget.dateTime),
              width: isHovered ? 3 : 2,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: widget.onEdit,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: widget.isCompleted,
                        onChanged:
                            (val) => widget.onToggleDone(widget.isCompleted),
                        activeColor: Colors.green,
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: widget.onDelete,
                        tooltip: 'Hapus',
                      ),
                    ],
                  ),
                  Text(
                    widget.text,
                    style: widget.theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: widget.isCompleted ? Colors.grey : Colors.black,
                      decoration:
                          widget.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.desc.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      widget.desc,
                      style: widget.theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: widget.catColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.category,
                          style: TextStyle(
                            color: widget.catColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.flag,
                        color: _priorityColorByDeadline(widget.dateTime),
                        size: 18,
                      ),
                      Text(
                        _priorityLabelByDeadline(widget.dateTime),
                        style: TextStyle(
                          color: _priorityColorByDeadline(widget.dateTime),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: widget.theme.primaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.dateTime != null
                            ? DateFormat(
                              'd MMM yyyy, HH:mm',
                            ).format(widget.dateTime!)
                            : '-',
                        style: widget.theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
