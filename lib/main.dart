import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.init();
  runApp(const StudentPortalApp());
}

class StudentPortalApp extends StatelessWidget {
  const StudentPortalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Framework Portal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        fontFamily: 'Roboto',
      ),
      home: const LoginScreen(),
    );
  }
}

// ================= LOCAL SQLITE DATABASE HELPER =================
class DatabaseHelper {
  static late Database db;
  static Future<void> init() async {
    db = await openDatabase(
      p.join(await getDatabasesPath(), 'student_portal.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('CREATE TABLE prof (name TEXT, reg TEXT)');
        await db.execute('CREATE TABLE tasks (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, due TEXT, comp INTEGER DEFAULT 0)');
      },
    );
  }
}

// ================= UI CONSTANTS & DECORATION =================
const Color primaryDark = Color(0xFF1D2433);     // Dark Signature Navy from your UI
const Color textSecondary = Color(0xFF64748B);   // Soft Muted Subtitle Slate

InputDecoration cleanInputStyle(String hint, IconData icon) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: textSecondary, fontSize: 15, fontWeight: FontWeight.w400),
    prefixIcon: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Icon(icon, color: primaryDark.withValues(alpha: 0.7), size: 22),
    ),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFF8E9AA8), width: 1.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: primaryDark, width: 1.5),
    ),
  );
}

// ================= SCREEN 1: LOGIN SCREEN (MATCHED TO IMAGE) =================
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                const Text(
                  'Welcome Back',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: primaryDark, letterSpacing: -0.5),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Sign in to manage your study space',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: textSecondary, fontWeight: FontWeight.w400),
                ),
                const SizedBox(height: 48),
                TextField(
                  style: const TextStyle(color: primaryDark, fontSize: 15),
                  decoration: cleanInputStyle('Student Email Address', Icons.mail_outline_rounded),
                ),
                const SizedBox(height: 16),
                TextField(
                  obscureText: true,
                  style: const TextStyle(color: primaryDark, fontSize: 15),
                  decoration: cleanInputStyle('Password', Icons.lock_open_outlined),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(58),
                    backgroundColor: primaryDark,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), // Fully rounded capsule button
                  ),
                  onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardScreen())),
                  child: const Text('Sign In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                  child: const Text(
                    'Create Student Account',
                    style: TextStyle(color: textSecondary, fontSize: 14, fontWeight: FontWeight.w500, decoration: TextDecoration.underline),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ================= SCREEN 2: REGISTRATION SCREEN =================
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final n = TextEditingController(), r = TextEditingController();

  @override
  void dispose() {
    n.dispose();
    r.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: primaryDark)),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Framework Initialization', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: primaryDark, letterSpacing: -0.5)),
            const SizedBox(height: 6),
            const Text('Bind details to the SQLite data architecture layer.', style: TextStyle(color: textSecondary, fontSize: 14)),
            const SizedBox(height: 36),
            TextField(controller: n, decoration: cleanInputStyle('Full Student Name', Icons.badge_outlined)),
            const SizedBox(height: 16),
            TextField(controller: r, decoration: cleanInputStyle('Institutional Registration ID', Icons.fingerprint_rounded)),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                backgroundColor: primaryDark,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: () async {
                if (n.text.isNotEmpty && r.text.isNotEmpty) {
                  await DatabaseHelper.db.delete('prof');
                  await DatabaseHelper.db.insert('prof', {'name': n.text, 'reg': r.text});
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile Stack Saved Locally!')));
                  Navigator.pop(context);
                }
              },
              child: const Text('Commit Credentials', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= SCREEN 3: PORTAL DASHBOARD =================
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Map<String, dynamic>> tasks = [];
  String studentName = "User Stack";

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    final pData = await DatabaseHelper.db.query('prof', limit: 1);
    final tData = await DatabaseHelper.db.query('tasks', orderBy: 'id DESC');
    if (!mounted) return;
    setState(() {
      if (pData.isNotEmpty) studentName = pData.first['name'].toString().split(' ')[0];
      tasks = tData;
    });
  }

  @override
  Widget build(BuildContext context) {
    int comp = tasks.where((e) => e['comp'] == 1).length;
    int pending = tasks.length - comp;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hello, $studentName! 👋', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryDark, letterSpacing: -0.5)),
                      const Text('Academic Core Matrix Workspace', style: TextStyle(color: textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.admin_panel_settings_outlined, color: primaryDark, size: 26),
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())).then((_) => loadData()),
                      ),
                      IconButton(
                        icon: const Icon(Icons.power_settings_new_rounded, color: Colors.redAccent, size: 24),
                        onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                      ),
                    ],
                  )
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [primaryDark, Color(0xFF334155)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: primaryDark.withValues(alpha: 0.12), blurRadius: 12, offset: const Offset(0, 6))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMetricCell('Pending Logs', '$pending', Colors.amberAccent),
                  Container(width: 1, height: 40, color: Colors.white24),
                  _buildMetricCell('Completed Core', '$comp', Colors.greenAccent),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 24.0, top: 32.0, bottom: 12.0),
              child: Text(
                'ACTIVE OPERATIONAL RECORDS',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textSecondary, letterSpacing: 1.2),
              ),
            ),
            Expanded(
              child: tasks.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.layers_clear_outlined, size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    const Text('Operational database array is clear.', style: TextStyle(color: textSecondary, fontSize: 14, fontWeight: FontWeight.w500)),
                  ],
                ),
              )
                  : ListView.builder(
                itemCount: tasks.length,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemBuilder: (context, i) {
                  final item = tasks[i];
                  bool isDone = item['comp'] == 1;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: isDone ? const Color(0xFFF1F5F9) : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isDone ? const Color(0xFFE2E8F0) : Colors.transparent),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      leading: IconButton(
                        icon: Icon(isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded, color: isDone ? Colors.green : primaryDark, size: 24),
                        onPressed: () async {
                          await DatabaseHelper.db.update('tasks', {'comp': isDone ? 0 : 1}, where: 'id = ?', whereArgs: [item['id']]);
                          loadData();
                        },
                      ),
                      title: Text(item['title'], style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, decoration: isDone ? TextDecoration.lineThrough : null, color: isDone ? textSecondary : primaryDark)),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Row(
                          children: [
                            Icon(Icons.bookmark_border_rounded, size: 13, color: isDone ? textSecondary : primaryDark),
                            const SizedBox(width: 4),
                            Text(item['due'], style: const TextStyle(fontSize: 12, color: textSecondary, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryDark,
        foregroundColor: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        icon: const Icon(Icons.add_task_rounded, size: 20),
        label: const Text('Add Metric Log', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddTaskScreen())).then((_) => loadData()),
      ),
    );
  }

  Widget _buildMetricCell(String label, String value, Color highlightColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: highlightColor, letterSpacing: -0.5)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

// ================= SCREEN 4: PROFILE SCREEN =================
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Core Structural Profile', style: TextStyle(color: primaryDark, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: primaryDark),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseHelper.db.query('prof', limit: 1),
        builder: (context, snap) {
          String name = "No Profile Configured";
          String reg = "Execute System Initialization";
          if (snap.hasData && snap.data!.isNotEmpty) {
            name = snap.data!.first['name'];
            reg = snap.data!.first['reg'];
          }
          return Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: primaryDark.withValues(alpha: 0.2), width: 3)),
                    child: const CircleAvatar(radius: 42, backgroundColor: primaryDark, child: Icon(Icons.account_tree_rounded, size: 36, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 36),
                _buildProfileNode(Icons.assignment_ind_outlined, 'Full Config Name', name),
                _buildProfileNode(Icons.perm_identity_rounded, 'System Registry Key', reg),
                _buildProfileNode(Icons.inventory_2_outlined, 'Storage Matrix Core', 'SQLite Architecture Engine'),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileNode(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, color: primaryDark, size: 22),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: textSecondary, fontSize: 11, fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: primaryDark, fontSize: 14)),
            ],
          )
        ],
      ),
    );
  }
}

// ================= SCREEN 5: ADD TASK SCREEN =================
class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});
  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final t = TextEditingController(), d = TextEditingController();

  @override
  void dispose() {
    t.dispose();
    d.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Create New Structural Metric', style: TextStyle(color: primaryDark, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: primaryDark),
      ),
      body: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          children: [
            TextField(controller: t, decoration: cleanInputStyle('Metric Activity Title', Icons.post_add_rounded)),
            const SizedBox(height: 16),
            TextField(controller: d, decoration: cleanInputStyle('Timeline Scope Parameter', Icons.history_toggle_off_rounded)),
            const SizedBox(height: 36),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
                backgroundColor: primaryDark,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: () async {
                if (t.text.isNotEmpty) {
                  await DatabaseHelper.db.insert('tasks', {'title': t.text, 'due': d.text.isEmpty ? 'Status: Unscheduled' : d.text});
                  if (!mounted) return;
                  Navigator.pop(context);
                }
              },
              child: const Text('Commit Metric Node', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}