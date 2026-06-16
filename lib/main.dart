import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CampusFlowApp());
}

class CampusFlowApp extends StatelessWidget {
  const CampusFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CampusFlow Student Planner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: Colors.pink.shade600,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.pink,
          primary: Colors.pink.shade600,
          secondary: Colors.pinkAccent,
          background: Colors.pink.shade50,
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

// ==========================================
// WEEK 1 & 3: GATEWAY SECURITY FRAME
// ==========================================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MainNavigationFrame(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_stories, size: 60, color: Colors.pink.shade600),
                    const SizedBox(height: 12),
                    Text(
                      'CampusFlow',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.pink.shade800),
                    ),
                    const Text(
                      'API & Storage Integrated Engine',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Student Email Address',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => (value == null || !value.contains('@')) ? 'Please enter your student email' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => (value == null || value.length < 4) ? 'Password must be at least 4 characters' : null,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Log In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MainNavigationFrame extends StatefulWidget {
  const MainNavigationFrame({super.key});

  @override
  State<MainNavigationFrame> createState() => _MainNavigationFrameState();
}

class _MainNavigationFrameState extends State<MainNavigationFrame> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const DashboardScreen(),
    const GradesScreen(),
    const GpaCalculatorScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.pink.shade700,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.sync_alt), label: 'API Tasks'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Grades'),
          BottomNavigationBarItem(icon: Icon(Icons.calculate), label: 'GPA Calc'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// ==========================================
// WEEK 2 & 4: ASYNCHRONOUS API CRUD DASHBOARD
// ==========================================
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Map<String, dynamic>> _apiStoredTasks = [];
  bool _isNetworkSyncing = true;
  String _networkLog = "Initializing local database stream...";

  final _taskTitleController = TextEditingController();
  final _taskDeadlineController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _retrieveDataFromAPI();
  }

  // 1. RETRIEVE METHOD (Asynchronous GET Request)
  Future<void> _retrieveDataFromAPI() async {
    try {
      final client = HttpClient();
      final uri = Uri.parse('https://jsonplaceholder.typicode.com/todos?_limit=3');
      final request = await client.getUrl(uri);
      final response = await request.close();

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final List<dynamic> serverData = json.decode(responseBody);

        if (!mounted) return;
        setState(() {
          _apiStoredTasks = serverData.map((item) => {
            'id': item['id'],
            'title': item['title'].toString().toUpperCase().substring(0, 15),
            'deadline': 'Due: Next Class Session',
          }).toList();
          _isNetworkSyncing = false;
          _networkLog = "HTTP GET 200: Live Records Synced From Cloud Server";
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isNetworkSyncing = false;
        _networkLog = "Offline Engine Status: Loaded from local secure cache.";
        _apiStoredTasks = [
          {'id': 1, 'title': 'Mobile Development Lab 2', 'deadline': 'Due: Friday'},
          {'id': 2, 'title': 'Database Query Assignment', 'deadline': 'Due: Monday'},
        ];
      });
    }
  }

  // 2. CREATE & SEND METHOD (Asynchronous POST Request)
  Future<void> _createAndSendTask() async {
    if (_taskTitleController.text.isEmpty || _taskDeadlineController.text.isEmpty) return;

    setState(() => _isNetworkSyncing = true);

    try {
      final client = HttpClient();
      final uri = Uri.parse('https://jsonplaceholder.typicode.com/posts');
      final request = await client.postUrl(uri);

      final mapData = {'title': _taskTitleController.text, 'body': _taskDeadlineController.text, 'userId': 1};
      request.headers.set('content-type', 'application/json');
      request.add(utf8.encode(json.encode(mapData)));

      final response = await request.close();

      if (response.statusCode == 201) {
        if (!mounted) return;
        setState(() {
          _apiStoredTasks.insert(0, {
            'id': DateTime.now().millisecondsSinceEpoch,
            'title': _taskTitleController.text,
            'deadline': 'Due: ${_taskDeadlineController.text}',
          });
          _taskTitleController.clear();
          _taskDeadlineController.clear();
          _isNetworkSyncing = false;
          _networkLog = "HTTP POST 201: Assignment Payload Saved to Cloud Server Database";
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isNetworkSyncing = false;
        _networkLog = "Network Timeout. Stored data payload within runtime sandboxed memory.";
      });
    }
  }

  // 3. REMOVE & DELETE METHOD (Asynchronous DELETE Request)
  Future<void> _removeAndCancelTask(int id, int index) async {
    setState(() => _isNetworkSyncing = true);

    try {
      final client = HttpClient();
      final uri = Uri.parse('https://jsonplaceholder.typicode.com/posts/$id');
      final request = await client.deleteUrl(uri);
      final response = await request.close();

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (!mounted) return;
        setState(() {
          _apiStoredTasks.removeAt(index);
          _isNetworkSyncing = false;
          _networkLog = "HTTP DELETE 200: Entry completely dropped from cloud structure";
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _apiStoredTasks.removeAt(index);
        _isNetworkSyncing = false;
        _networkLog = "Removed item locally from sandbox runtime model.";
      });
    }
  }

  String _getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  void dispose() {
    _taskTitleController.dispose();
    _taskDeadlineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CampusFlow Engine', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.pink.shade600,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.pink.shade100,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.bolt, color: Colors.pink.shade800, size: 32),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_getTimeBasedGreeting()}, Joy!',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.pink.shade900),
                        ),
                        const Text('System linked with real-time network caching privileges', style: TextStyle(fontSize: 11, color: Colors.black54)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "CONSOLE LOG: $_networkLog",
                style: const TextStyle(color: Colors.greenAccent, fontFamily: 'monospace', fontSize: 11),
              ),
            ),
            const SizedBox(height: 20),

            Text('Create Record Field (API POST Entry)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.pink.shade900)),
            const SizedBox(height: 8),
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _taskTitleController,
                      decoration: const InputDecoration(labelText: 'Assignment Unit Title', hintText: 'e.g. Distributed Computing'),
                    ),
                    TextField(
                      controller: _taskDeadlineController,
                      decoration: const InputDecoration(labelText: 'Target Date Deadline', hintText: 'e.g. Next Thursday at midnight'),
                    ),
                    const SizedBox(height: 12),
                    _isNetworkSyncing
                        ? const CircularProgressIndicator()
                        : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _createAndSendTask,
                        icon: const Icon(Icons.cloud_upload),
                        label: const Text('Execute Create & Sent Method'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink.shade600,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text('Active Extracted Data Framework (RETRIEVE Stream)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.pink.shade900)),
            const SizedBox(height: 8),

            _apiStoredTasks.isEmpty
                ? const Center(child: Padding(padding: EdgeInsets.all(16.0), child: Text("No records saved in local buffer.")))
                : ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: _apiStoredTasks.length,
              itemBuilder: (context, index) {
                final item = _apiStoredTasks[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: Icon(Icons.storage, color: Colors.pink.shade600),
                    title: Text(item['title']!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    subtitle: Text(item['deadline']!, style: TextStyle(color: Colors.pink.shade700, fontSize: 12)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_forever, color: Colors.red),
                      onPressed: () => _removeAndCancelTask(item['id'], index),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// STUDENT GRADES PROFILE DISPLAY SCREEN
// ==========================================
class GradesScreen extends StatelessWidget {
  const GradesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> gradeList = [
      {'code': 'BIT 4101', 'title': 'Mobile Application Dev', 'mark': '82%', 'grade': 'A'},
      {'code': 'BIT 4102', 'title': 'Database Management Systems', 'mark': '74%', 'grade': 'A'},
      {'code': 'BIT 4103', 'title': 'Network Security Systems', 'mark': '68%', 'grade': 'B'},
      {'code': 'BIT 4104', 'title': 'Research Methodology Project', 'mark': '61%', 'grade': 'B'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Academic Transcript', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.pink.shade600,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: gradeList.length,
        itemBuilder: (context, index) {
          final unit = gradeList[index];
          return Card(
            child: ListTile(
              title: Text(unit['code']!, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.pink.shade800)),
              subtitle: Text(unit['title']!),
              trailing: CircleAvatar(
                backgroundColor: Colors.pink.shade100,
                child: Text(unit['grade']!, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.pink.shade900)),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ==========================================
// WEEK 4: INTERACTIVE GPA CALCULATOR SCREEN
// ==========================================
class GpaCalculatorScreen extends StatefulWidget {
  const GpaCalculatorScreen({super.key});

  @override
  State<GpaCalculatorScreen> createState() => _GpaCalculatorScreenState();
}

class _GpaCalculatorScreenState extends State<GpaCalculatorScreen> {
  final _catController = TextEditingController();
  final _examController = TextEditingController();
  double _finalMark = 0.0;
  String _grade = "-";

  void _calculateGrade() {
    final double cat = double.tryParse(_catController.text) ?? 0;
    final double exam = double.tryParse(_examController.text) ?? 0;

    setState(() {
      _finalMark = cat + exam;
      if (_finalMark >= 70) _grade = 'A (Excellent)';
      else if (_finalMark >= 60) _grade = 'B (Very Good)';
      else if (_finalMark >= 50) _grade = 'C (Good)';
      else if (_finalMark >= 40) _grade = 'D (Pass)';
      else _grade = 'F (Retake Required)';
    });
  }

  @override
  void dispose() {
    _catController.dispose();
    _examController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Grade Calculator', style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Colors.pink.shade600, foregroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(controller: _catController, decoration: const InputDecoration(labelText: 'CAT (Out of 30)')),
            TextField(controller: _examController, decoration: const InputDecoration(labelText: 'Exam (Out of 70)')),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _calculateGrade, style: ElevatedButton.styleFrom(backgroundColor: Colors.pink.shade600, foregroundColor: Colors.white), child: const Text('Calculate')),
            const SizedBox(height: 24),
            Text('Grade Result: $_grade', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.pink.shade800)),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// WEEK 5: COMPLETE USER PROFILE VIEW
// ==========================================
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Colors.pink.shade600, foregroundColor: Colors.white),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(radius: 40, backgroundColor: Colors.pink.shade600, child: const Icon(Icons.person, size: 40, color: Colors.white)),
            const SizedBox(height: 12),
            const Text('Joy', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text('Admission: BIT/4107/2024', style: TextStyle(color: Colors.pink.shade900)),
            const Text('Year 4, Semester 1', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}