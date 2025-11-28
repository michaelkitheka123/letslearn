// main.dart
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:lottie/lottie.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:confetti/confetti.dart';

void main() {
  runApp(const StudyCoachApp());
}

/* ---------------------------
   Theme & Helpers
   --------------------------- */
const Color primary = Color(0xFF6C63FF);
const Color accent = Color(0xFFFFC857);
const Color success = Color(0xFF4CAF50);
const Color warning = Color(0xFFFF9800);

const Gradient bgGradient = LinearGradient(
  colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// Animation durations
const Duration quickAnim = Duration(milliseconds: 300);
const Duration mediumAnim = Duration(milliseconds: 500);
const Duration slowAnim = Duration(milliseconds: 800);

TextStyle h1([double size = 28]) => TextStyle(
    fontSize: size,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    fontFamily: 'Poppins');

TextStyle h2([double size = 20]) => TextStyle(
    fontSize: size,
    fontWeight: FontWeight.w700,
    color: Colors.white70,
    fontFamily: 'Poppins');

EdgeInsets pagePadding =
    const EdgeInsets.symmetric(horizontal: 18.0, vertical: 18.0);

/* ---------------------------
   Animation Widgets
   --------------------------- */
class FadeInSlide extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double delay;
  final Curve curve;

  const FadeInSlide({
    super.key,
    required this.child,
    this.duration = mediumAnim,
    this.delay = 0.0,
    this.curve = Curves.easeOut,
  });

  @override
  _FadeInSlideState createState() => _FadeInSlideState();
}

class _FadeInSlideState extends State<FadeInSlide>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    _offset =
        Tween<Offset>(begin: const Offset(0.0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    Future.delayed(Duration(milliseconds: (widget.delay * 1000).round()), () {
      if (mounted) _controller.forward();
    });
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
        return Opacity(
          opacity: _opacity.value,
          child: Transform.translate(
            offset: _offset.value,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

class BounceIn extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double delay;

  const BounceIn(
      {super.key,
      required this.child,
      this.duration = mediumAnim,
      this.delay = 0.0});

  @override
  _BounceInState createState() => _BounceInState();
}

class _BounceInState extends State<BounceIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _scale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    Future.delayed(Duration(milliseconds: (widget.delay * 1000).round()), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: _scale, child: widget.child);
  }
}

class PulseAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const PulseAnimation(
      {super.key,
      required this.child,
      this.duration = const Duration(seconds: 2)});

  @override
  _PulseAnimationState createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: _animation, child: widget.child);
  }
}

/* ---------------------------
   Success Confetti Widget
   --------------------------- */
class SuccessConfetti extends StatefulWidget {
  final Widget child;
  final bool showConfetti;

  const SuccessConfetti(
      {super.key, required this.child, required this.showConfetti});

  @override
  _SuccessConfettiState createState() => _SuccessConfettiState();
}

class _SuccessConfettiState extends State<SuccessConfetti> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    if (widget.showConfetti) {
      _confettiController.play();
    }
  }

  @override
  void didUpdateWidget(SuccessConfetti oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showConfetti && !oldWidget.showConfetti) {
      _confettiController.play();
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: -pi / 2,
            emissionFrequency: 0.05,
            numberOfParticles: 20,
            maxBlastForce: 100,
            minBlastForce: 80,
          ),
        ),
      ],
    );
  }
}

/* ---------------------------
   Services Layer - Fixed File Picker
   --------------------------- */
class AIService {
  static const String apiKey = 'YOUR_OPENAI_API_KEY';
  static const String baseUrl = 'https://api.openai.com/v1';

  static Future<String> generateTopicSuggestions(String topic) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'user',
              'content':
                  'Generate 4 structured study subtopics for "$topic". Format as a bullet list with clear, specific titles that would help someone learn this topic systematically.'
            }
          ],
          'max_tokens': 500,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      }
    } catch (e) {
      print('AI Service Error: $e');
    }

    return '''
• $topic - Foundations & Core Concepts
• $topic - Practical Applications & Examples  
• $topic - Common Challenges & Solutions
• $topic - Advanced Topics & Extensions
''';
  }

  static Future<Map<String, dynamic>> analyzeNotes(
      String notes, String topic) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'user',
              'content':
                  'Analyze these study notes about "$topic" and provide:\n1. A concise summary\n2. 3-4 key concepts identified\n3. Learning gaps or areas needing clarification\n4. 2-3 suggested resources\n\nNotes:\n$notes\n\nFormat as JSON with keys: summary, keyConcepts, gaps, resources'
            }
          ],
          'max_tokens': 800,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        return jsonDecode(content);
      }
    } catch (e) {
      print('Analysis Error: $e');
    }

    return {
      'summary':
          'Analysis complete. Focus on understanding the core principles.',
      'keyConcepts': [
        'Fundamental principles',
        'Key terminology',
        'Practical applications'
      ],
      'gaps': ['More examples needed', 'Visual aids would help'],
      'resources': [
        'Khan Academy',
        'Textbook Chapter 3',
        'Online practice problems'
      ]
    };
  }

  static Future<List<Flashcard>> generateFlashcards(
      String topic, String notes) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'user',
              'content':
                  'Generate 8-10 educational flashcards for "$topic". Use the notes as context. Format as JSON array with "front" and "back" keys. Notes:\n$notes'
            }
          ],
          'max_tokens': 1000,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        final List<dynamic> cardsJson = jsonDecode(content);
        return cardsJson
            .map((card) =>
                Flashcard(front: card['front'] ?? '', back: card['back'] ?? ''))
            .toList();
      }
    } catch (e) {
      print('Flashcard Generation Error: $e');
    }

    return [
      Flashcard(
          front: 'What is the main concept of $topic?',
          back: 'The fundamental principles that define $topic'),
      Flashcard(
          front: 'Key terminology in $topic',
          back: 'Important terms and definitions'),
      Flashcard(
          front: 'Practical application of $topic',
          back: 'Real-world uses and examples'),
    ];
  }

  static Future<List<Map<String, dynamic>>> generateAssessment(
      String topic, String content) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'user',
              'content':
                  'Generate 5 comprehension questions based on this study content about "$topic". Include multiple choice and short answer questions. Format as JSON array with keys: "question", "type" (mcq/short), "choices" (array for mcq), "correctAnswer". Content:\n$content'
            }
          ],
          'max_tokens': 1000,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        return List<Map<String, dynamic>>.from(jsonDecode(content));
      }
    } catch (e) {
      print('Assessment Generation Error: $e');
    }

    return [
      {
        'question': 'What is the main focus of $topic?',
        'type': 'short',
        'correctAnswer': 'The core concepts and applications'
      }
    ];
  }
}

class StorageService {
  static const String topicsKey = 'study_topics';
  static const String profileKey = 'user_profile';

  static Future<void> saveTopics(List<StudyTopic> topics) async {
    final prefs = await SharedPreferences.getInstance();
    final topicsJson = topics.map((topic) => _topicToJson(topic)).toList();
    await prefs.setString(topicsKey, jsonEncode(topicsJson));
  }

  static Future<List<StudyTopic>> loadTopics() async {
    final prefs = await SharedPreferences.getInstance();
    final topicsJson = prefs.getString(topicsKey);
    if (topicsJson != null) {
      final List<dynamic> topicsList = jsonDecode(topicsJson);
      return topicsList.map((json) => _topicFromJson(json)).toList();
    }
    return [];
  }

  static Map<String, dynamic> _topicToJson(StudyTopic topic) {
    return {
      'title': topic.title,
      'notes': topic.notes,
      'decks': topic.decks
          .map((deck) => {
                'name': deck.name,
                'cards': deck.cards
                    .map((card) => {
                          'front': card.front,
                          'back': card.back,
                        })
                    .toList(),
              })
          .toList(),
      'plan': topic.plan != null
          ? {
              'deadline': topic.plan!.deadline.toIso8601String(),
              'hoursPerDay': topic.plan!.hoursPerDay,
              'tasks': topic.plan!.tasks,
            }
          : null,
    };
  }

  static StudyTopic _topicFromJson(Map<String, dynamic> json) {
    final topic = StudyTopic(title: json['title'], notes: json['notes'] ?? '');

    if (json['decks'] != null) {
      final List<dynamic> decksJson = json['decks'];
      topic.decks = decksJson
          .map((deckJson) => FlashcardDeck(
                name: deckJson['name'],
                cards: (deckJson['cards'] as List)
                    .map((cardJson) => Flashcard(
                          front: cardJson['front'],
                          back: cardJson['back'],
                        ))
                    .toList(),
              ))
          .toList();
    }

    if (json['plan'] != null) {
      topic.plan = StudyPlan(
        deadline: DateTime.parse(json['plan']['deadline']),
        hoursPerDay: json['plan']['hoursPerDay'],
        tasks: List<String>.from(json['plan']['tasks']),
      );
    }

    return topic;
  }
}

class FileService {
  static Future<String?> pickAndReadFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'txt', 'doc', 'docx'],
        withData: true, // Important for web compatibility
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        // For web, use bytes. For mobile, use path if available
        if (file.bytes != null) {
          // Convert bytes to string (for text files)
          return String.fromCharCodes(file.bytes!);
        } else if (file.path != null) {
          // For mobile platforms
          final fileObj = File(file.path!);
          return await fileObj.readAsString();
        }
      }
    } catch (e) {
      print('File pick error: $e');
      // Fallback for web demo
      return 'Sample uploaded content for demonstration. In a real app, this would be your actual file content.';
    }
    return null;
  }
}

/* ---------------------------
   Data Models
   --------------------------- */
class StudyTopic {
  String title;
  String notes;
  List<FlashcardDeck> decks;
  StudyPlan? plan;

  StudyTopic({
    required this.title,
    this.notes = '',
    List<FlashcardDeck>? decks,
  }) : decks = decks ?? [];
}

class Flashcard {
  String front;
  String back;
  Flashcard({required this.front, required this.back});
}

class FlashcardDeck {
  String name;
  List<Flashcard> cards;
  FlashcardDeck({required this.name, required this.cards});
}

class StudyPlan {
  DateTime deadline;
  int hoursPerDay;
  List<String> tasks;
  StudyPlan({
    required this.deadline,
    required this.hoursPerDay,
    required this.tasks,
  });
}

/* ---------------------------
   Global App State with Persistence
   --------------------------- */
class AppState extends ChangeNotifier {
  List<StudyTopic> topics = [];
  StudyTopic? current;
  Map<String, dynamic> profile = {};
  bool initialized = false;

  Future<void> initialize() async {
    if (initialized) return;

    topics = await StorageService.loadTopics();
    initialized = true;
    notifyListeners();
  }

  void addTopic(StudyTopic t) {
    topics.add(t);
    _saveTopics();
    notifyListeners();
  }

  void selectTopic(StudyTopic t) {
    current = t;
    notifyListeners();
  }

  void updateTopicNotes(StudyTopic t, String notes) {
    t.notes = notes;
    _saveTopics();
    notifyListeners();
  }

  void addFlashcardDeck(StudyTopic t, FlashcardDeck deck) {
    t.decks.add(deck);
    _saveTopics();
    notifyListeners();
  }

  void savePlan(StudyTopic t, StudyPlan p) {
    t.plan = p;
    _saveTopics();
    notifyListeners();
  }

  void deleteTopic(StudyTopic t) {
    topics.remove(t);
    _saveTopics();
    notifyListeners();
  }

  Future<void> _saveTopics() async {
    await StorageService.saveTopics(topics);
  }
}

final appState = AppState();

/* ---------------------------
   Root App with Initialization
   --------------------------- */
class StudyCoachApp extends StatelessWidget {
  const StudyCoachApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Study Coach',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: primary,
        scaffoldBackgroundColor: Colors.black,
        splashColor: primary.withOpacity(0.2),
        fontFamily: 'Poppins',
        snackBarTheme: SnackBarThemeData(
          backgroundColor: Colors.grey[900],
          contentTextStyle: const TextStyle(color: Colors.white),
        ),
      ),
      home: const AppInitializer(),
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  _AppInitializerState createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _initializing = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await appState.initialize();
    setState(() => _initializing = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Container(
          decoration: const BoxDecoration(gradient: bgGradient),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  'assets/animations/study_animation.json',
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 30),
                AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText(
                      'Loading Study Coach...',
                      textStyle: h2(18),
                      speed: const Duration(milliseconds: 100),
                    ),
                  ],
                  totalRepeatCount: 1,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return const HomeScreen();
  }
}

/* ---------------------------
   Home Screen with Enhanced Animations
   --------------------------- */
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int navIndex = 0;
  late AnimationController _bgController;
  final List<Widget> pages = [
    const DiscoverScreen(),
    const TopicsScreen(),
    const PlannerScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),
              _buildTopBar(),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 600),
                  switchInCurve: Curves.easeInOut,
                  switchOutCurve: Curves.easeInOut,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                  child: pages[navIndex],
                ),
              ),
              _buildBottomNav(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return FadeInSlide(
      delay: 0.1,
      child: Padding(
        padding: pagePadding,
        child: Row(
          children: [
            BounceIn(
              child: Text('Tusome', style: h1(26)),
            ),
            const Spacer(),
            IconButton(
              icon: const PulseAnimation(
                child: Icon(Icons.search, color: Colors.white70),
              ),
              onPressed: () => _openSearch(),
            ),
            const SizedBox(width: 8),
            const CircleAvatar(
                radius: 20,
                backgroundColor: accent,
                child: Text('VC',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold))),
          ],
        ),
      ),
    );
  }

  void _openSearch() {
    showSearch(context: context, delegate: TopicSearchDelegate());
  }

  Widget _buildBottomNav() {
    return FadeInSlide(
      delay: 0.3,
      child: Container(
        decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 2,
              )
            ]),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navButton(Icons.explore, 'Discover', 0),
            _navButton(Icons.book, 'Topics', 1),
            _navButton(Icons.calendar_today, 'Planner', 2),
            _navButton(Icons.person, 'Profile', 3),
          ],
        ),
      ),
    );
  }

  Widget _navButton(IconData icon, String label, int idx) {
    final active = idx == navIndex;
    return GestureDetector(
      onTap: () => setState(() => navIndex = idx),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: quickAnim,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: active ? primary.withOpacity(0.2) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: active ? accent : Colors.white70),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  color: active ? accent : Colors.white70,
                  fontSize: 12,
                  fontWeight: active ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}

/* ---------------------------
   Discover Screen - Enhanced with Animations
   --------------------------- */
class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  _DiscoverScreenState createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final _controller = TextEditingController();
  bool loading = false;
  List<String> suggestions = [];

  Future<void> _askAIForTopics(String q) async {
    if (q.trim().isEmpty) return;
    setState(() => loading = true);

    try {
      final aiResponse = await AIService.generateTopicSuggestions(q);
      final lines = aiResponse
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .toList();
      suggestions = lines
          .map((line) => line.replaceAll(RegExp(r'^[•\-\d\.\s]+'), '').trim())
          .toList();
    } catch (e) {
      suggestions = [
        '$q — Core Concepts',
        '$q — Practical Applications',
        '$q — Advanced Topics',
        '$q — Review & Practice'
      ];
    }

    setState(() => loading = false);
  }

  void _createTopic(String title) {
    final t = StudyTopic(title: title);
    appState.addTopic(t);
    appState.selectTopic(t);
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => TopicDetailScreen(topic: t)));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: pagePadding,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInSlide(
              delay: 0.1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  AnimatedTextKit(
                    animatedTexts: [
                      TypewriterAnimatedText(
                        'What do you want to learn today?',
                        textStyle: h2(20),
                        speed: const Duration(milliseconds: 50),
                      ),
                    ],
                    totalRepeatCount: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            FadeInSlide(
              delay: 0.2,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: primary.withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 1,
                          )
                        ],
                      ),
                      child: TextField(
                        controller: _controller,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'e.g. Calculus: limits',
                          hintStyle: const TextStyle(color: Colors.white38),
                          filled: true,
                          fillColor: Colors.white10,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  BounceIn(
                    delay: 0.3,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        final q = _controller.text.trim();
                        if (q.isEmpty) return;
                        _createTopic(q);
                      },
                      child: const Text('Start'),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),
            FadeInSlide(
              delay: 0.4,
              child: Row(
                children: [
                  const Text('Need suggestions?',
                      style: TextStyle(color: Colors.white70)),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () => _askAIForTopics(
                        _controller.text.trim().isEmpty
                            ? 'linear algebra'
                            : _controller.text.trim()),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: loading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Generate'),
                  )
                ],
              ),
            ),
            const SizedBox(height: 18),
            if (suggestions.isNotEmpty)
              FadeInSlide(
                delay: 0.5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Try one of these:',
                        style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: suggestions
                          .asMap()
                          .entries
                          .map((entry) => BounceIn(
                                delay: 0.6 + entry.key * 0.1,
                                child: ActionChip(
                                  label: Text(entry.value),
                                  backgroundColor: Colors.white10,
                                  onPressed: () => _createTopic(entry.value),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

/* ---------------------------
   Topics Screen - Enhanced with Animations
   --------------------------- */
class TopicsScreen extends StatefulWidget {
  const TopicsScreen({super.key});

  @override
  _TopicsScreenState createState() => _TopicsScreenState();
}

class _TopicsScreenState extends State<TopicsScreen> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInSlide(
            delay: 0.1,
            child: Row(
              children: [
                Text('Your Topics', style: h2(22)),
                const SizedBox(height: 8),
                PulseAnimation(
                  child: IconButton(
                    icon: const Icon(Icons.file_upload, color: Colors.white70),
                    onPressed: _uploadFileToNewTopic,
                    tooltip: 'Upload notes file',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: appState.topics.isEmpty
                ? FadeInSlide(
                    delay: 0.2,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Lottie.asset(
                            'assets/animations/empty_state.json',
                            width: 150,
                            height: 150,
                          ),
                          const SizedBox(height: 20),
                          const Text('No topics yet.',
                              style: TextStyle(color: Colors.white54)),
                          const Text('Tap Discover to create one!',
                              style: TextStyle(color: Colors.white54)),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: appState.topics.length,
                    itemBuilder: (ctx, i) {
                      final t = appState.topics[i];
                      return FadeInSlide(
                        delay: 0.1 + i * 0.1,
                        child: TopicCard(topic: t),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadFileToNewTopic() async {
    final contents = await FileService.pickAndReadFile();
    if (contents != null) {
      final topicName = _extractTopicNameFromContent(contents);
      final topic = StudyTopic(title: topicName, notes: contents);
      appState.addTopic(topic);
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => TopicDetailScreen(topic: topic),
      ));
    }
  }

  String _extractTopicNameFromContent(String content) {
    final firstLine = content.split('\n').first.trim();
    if (firstLine.length > 50) {
      return 'Uploaded Notes ${DateFormat.yMd().format(DateTime.now())}';
    }
    return firstLine.isEmpty ? 'Uploaded Notes' : firstLine;
  }
}

class TopicCard extends StatelessWidget {
  final StudyTopic topic;
  const TopicCard({super.key, required this.topic});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => TopicDetailScreen(topic: topic),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 5,
              spreadRadius: 1,
            )
          ],
        ),
        child: Row(
          children: [
            Hero(
              tag: 'topic-${topic.title}',
              child: PulseAnimation(
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: primary,
                  child: Text(
                    topic.title[0].toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(topic.title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text(
                        topic.notes.isEmpty
                            ? 'No notes yet'
                            : (topic.notes.length > 90
                                ? '${topic.notes.substring(0, 90)}...'
                                : topic.notes),
                        style: const TextStyle(color: Colors.white54)),
                    if (topic.decks.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                          '${topic.decks.length} flashcard deck${topic.decks.length > 1 ? 's' : ''}',
                          style: const TextStyle(color: primary, fontSize: 12)),
                    ],
                  ]),
            ),
            const Icon(Icons.chevron_right, color: Colors.white30)
          ],
        ),
      ),
    );
  }
}

/* ---------------------------
   Topic Detail Screen - Enhanced with Animations
   --------------------------- */
class TopicDetailScreen extends StatefulWidget {
  final StudyTopic topic;
  const TopicDetailScreen({super.key, required this.topic});
  @override
  _TopicDetailScreenState createState() => _TopicDetailScreenState();
}

class _TopicDetailScreenState extends State<TopicDetailScreen> {
  final _notesController = TextEditingController();
  bool analyzing = false;
  Map<String, dynamic> aiAnalysis = {};

  @override
  void initState() {
    super.initState();
    _notesController.text = widget.topic.notes;
  }

  Future<void> _runAnalyzer() async {
    if (widget.topic.notes.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Add some notes first to analyze')));
      return;
    }

    setState(() => analyzing = true);
    try {
      aiAnalysis =
          await AIService.analyzeNotes(widget.topic.notes, widget.topic.title);
    } catch (e) {
      aiAnalysis = {
        'summary': 'Analysis complete. Review your notes for key concepts.',
        'keyConcepts': ['Core principles', 'Important definitions'],
        'gaps': ['More examples needed', 'Practice problems required'],
        'resources': ['Textbook reference', 'Online tutorials']
      };
    }
    setState(() => analyzing = false);
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Analysis complete — suggestions ready')));
  }

  void _saveNotes() {
    appState.updateTopicNotes(widget.topic, _notesController.text);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Notes saved')));
  }

  void _openStudyFlow() {
    appState.selectTopic(widget.topic);
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => StudyFlowScreen(topic: widget.topic)));
  }

  Future<void> _openFlashcardGenerator() async {
    if (widget.topic.notes.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Add notes first to generate flashcards')));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Generating flashcards...')));

    try {
      final cards = await AIService.generateFlashcards(
          widget.topic.title, widget.topic.notes);
      final deck = FlashcardDeck(
        name: '${widget.topic.title} - AI Generated',
        cards: cards,
      );
      appState.addFlashcardDeck(widget.topic, deck);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Generated ${cards.length} flashcards')));

      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => FlashcardsScreen(deck: deck),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to generate flashcards')));
    }
  }

  Future<void> _uploadFile() async {
    final contents = await FileService.pickAndReadFile();
    if (contents != null) {
      _notesController.text = contents;
      _saveNotes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: bgGradient),
        child: SafeArea(
          child: Padding(
            padding: pagePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeInSlide(
                  delay: 0.1,
                  child: Row(
                    children: [
                      Hero(
                          tag: 'topic-${widget.topic.title}',
                          child: CircleAvatar(
                              radius: 28,
                              backgroundColor: primary,
                              child:
                                  Text(widget.topic.title[0].toUpperCase()))),
                      const SizedBox(width: 12),
                      Expanded(child: Text(widget.topic.title, style: h1(22))),
                      PulseAnimation(
                        child: IconButton(
                          icon:
                              const Icon(Icons.play_circle_fill, color: accent),
                          onPressed: _openStudyFlow,
                          tooltip: 'Start study session',
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const FadeInSlide(
                  delay: 0.2,
                  child: Text('Your notes',
                      style: TextStyle(color: Colors.white70)),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: FadeInSlide(
                    delay: 0.3,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _notesController,
                              maxLines: null,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration.collapsed(
                                  hintText: 'Paste notes or type here...',
                                  hintStyle: TextStyle(color: Colors.white38)),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              BounceIn(
                                delay: 0.4,
                                child: ElevatedButton.icon(
                                  onPressed: _saveNotes,
                                  icon: const Icon(Icons.save,
                                      color: Colors.black),
                                  label: const Text('Save',
                                      style: TextStyle(color: Colors.black)),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: accent),
                                ),
                              ),
                              BounceIn(
                                delay: 0.5,
                                child: OutlinedButton.icon(
                                    onPressed: _uploadFile,
                                    icon: const Icon(Icons.upload_file,
                                        color: Colors.white70),
                                    label: const Text('Upload File')),
                              ),
                              BounceIn(
                                delay: 0.6,
                                child: OutlinedButton.icon(
                                    onPressed: _runAnalyzer,
                                    icon: const Icon(Icons.auto_awesome,
                                        color: Colors.white70),
                                    label: analyzing
                                        ? const Text('Analyzing...')
                                        : const Text('Analyze')),
                              ),
                              BounceIn(
                                delay: 0.7,
                                child: OutlinedButton.icon(
                                    onPressed: _openFlashcardGenerator,
                                    icon: const Icon(Icons.grid_view),
                                    label: const Text('Generate Flashcards')),
                              ),
                              BounceIn(
                                delay: 0.8,
                                child: ElevatedButton.icon(
                                    onPressed: _openStudyFlow,
                                    icon: const Icon(Icons.play_arrow),
                                    label: const Text('Start Study'),
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: primary)),
                              ),
                            ],
                          ),
                          if (aiAnalysis.isNotEmpty) ...[
                            const Divider(color: Colors.white12),
                            FadeInSlide(
                              delay: 0.9,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text('AI Analysis',
                                          style: TextStyle(
                                              color: Colors.white70))),
                                  const SizedBox(height: 6),
                                  if (aiAnalysis['summary'] != null)
                                    Text(aiAnalysis['summary'],
                                        style: const TextStyle(
                                            color: Colors.white54)),
                                  if (aiAnalysis['keyConcepts'] != null) ...[
                                    const SizedBox(height: 8),
                                    const Text('Key Concepts:',
                                        style: TextStyle(
                                            color: Colors.white70,
                                            fontWeight: FontWeight.bold)),
                                    ...(aiAnalysis['keyConcepts'] as List).map(
                                        (concept) => Text('• $concept',
                                            style: const TextStyle(
                                                color: Colors.white54))),
                                  ],
                                  if (aiAnalysis['resources'] != null) ...[
                                    const SizedBox(height: 8),
                                    const Text('Suggested Resources:',
                                        style: TextStyle(
                                            color: Colors.white70,
                                            fontWeight: FontWeight.bold)),
                                    ...(aiAnalysis['resources'] as List).map(
                                        (resource) => Text('• $resource',
                                            style: const TextStyle(
                                                color: Colors.white54))),
                                  ],
                                ],
                              ),
                            ),
                          ]
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* ---------------------------
   Study Flow Screen - Enhanced with Animations
   --------------------------- */
class StudyFlowScreen extends StatefulWidget {
  final StudyTopic topic;
  const StudyFlowScreen({super.key, required this.topic});
  @override
  _StudyFlowScreenState createState() => _StudyFlowScreenState();
}

class _StudyFlowScreenState extends State<StudyFlowScreen>
    with WidgetsBindingObserver {
  DateTime? startedAt;
  Duration readTime = Duration.zero;
  Timer? ticker;
  DateTime lastInteraction = DateTime.now();
  Timer? inactivityTimer;
  bool paused = false;
  String readingContent = '';
  bool loadingContent = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadReading();
    _startTicker();
    _resetInactivityTimer();
  }

  void _loadReading() async {
    setState(() => loadingContent = true);

    if (widget.topic.notes.isNotEmpty) {
      readingContent = widget.topic.notes;
    } else {
      readingContent =
          'Study content for "${widget.topic.title}".\n\nStart by reviewing the core concepts and fundamental principles. Take notes as you read and pause to reflect on key points.';
    }

    setState(() => loadingContent = false);
  }

  void _startTicker() {
    startedAt ??= DateTime.now();
    ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!paused) {
        setState(() {
          readTime = DateTime.now().difference(startedAt!);
        });
      }
    });
  }

  void _resetInactivityTimer() {
    inactivityTimer?.cancel();
    lastInteraction = DateTime.now();
    inactivityTimer = Timer(const Duration(seconds: 45), () {
      _sendInactivityPrompt();
    });
  }

  void _sendInactivityPrompt() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Still reading? Tap to continue or take a short break.'),
        duration: Duration(seconds: 6)));
  }

  void _onUserInteraction() {
    _resetInactivityTimer();
  }

  void _pause() => setState(() => paused = true);
  void _resume() => setState(() => paused = false);

  Future<void> _prepareAssessment() async {
    setState(() => loadingContent = true);
    try {
      final questions = await AIService.generateAssessment(
          widget.topic.title, readingContent);
      setState(() => loadingContent = false);
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) =>
            AssessmentScreen(questions: questions, topic: widget.topic),
      ));
    } catch (e) {
      setState(() => loadingContent = false);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to generate assessment')));
    }
  }

  @override
  void dispose() {
    ticker?.cancel();
    inactivityTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _onUserInteraction(),
      onPanDown: (_) => _onUserInteraction(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: const BoxDecoration(gradient: bgGradient),
          child: SafeArea(
            child: Padding(
              padding: pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInSlide(
                    delay: 0.1,
                    child: Row(
                      children: [
                        const BackButton(color: Colors.white),
                        const SizedBox(width: 8),
                        Text('Study: ${widget.topic.title}', style: h1(20)),
                        const Spacer(),
                        Chip(
                            label: Text(_formatDuration(readTime)),
                            backgroundColor: Colors.white10),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: loadingContent
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Lottie.asset(
                                  'assets/animations/progress_animation.json',
                                  width: 100,
                                  height: 100,
                                ),
                                const SizedBox(height: 20),
                                const Text('Loading study content...',
                                    style: TextStyle(color: Colors.white54)),
                              ],
                            ),
                          )
                        : FadeInSlide(
                            delay: 0.2,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white10,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  )
                                ],
                              ),
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                        'Read carefully. You will be asked questions after reviewing.',
                                        style:
                                            TextStyle(color: Colors.white54)),
                                    const SizedBox(height: 8),
                                    Text(readingContent,
                                        style: const TextStyle(
                                            color: Colors.white70,
                                            height: 1.45)),
                                    const SizedBox(height: 18),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        BounceIn(
                                          delay: 0.3,
                                          child: ElevatedButton.icon(
                                              onPressed: _pause,
                                              icon: const Icon(Icons.pause),
                                              label: const Text('Pause'),
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.white10)),
                                        ),
                                        BounceIn(
                                          delay: 0.4,
                                          child: ElevatedButton.icon(
                                              onPressed: _resume,
                                              icon:
                                                  const Icon(Icons.play_arrow),
                                              label: const Text('Resume'),
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor: primary)),
                                        ),
                                        BounceIn(
                                          delay: 0.5,
                                          child: ElevatedButton(
                                              onPressed: _prepareAssessment,
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor: accent,
                                                  foregroundColor:
                                                      Colors.black),
                                              child: const Text(
                                                  'I\'m ready — Ask me questions')),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    LinearProgressIndicator(
                                        value: (readTime.inSeconds % 300) / 300,
                                        color: accent,
                                        backgroundColor: Colors.white12)
                                  ],
                                ),
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }
}

/* ---------------------------
   Assessment Screen - Enhanced with Animations
   --------------------------- */
class AssessmentScreen extends StatefulWidget {
  final List<Map<String, dynamic>> questions;
  final StudyTopic topic;
  const AssessmentScreen(
      {super.key, required this.questions, required this.topic});
  @override
  _AssessmentScreenState createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  int qIndex = 0;
  Map<int, dynamic> answers = {};
  bool submitting = false;
  late ConfettiController _confettiController;
  bool showConfetti = false;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.questions.isEmpty) {
      return const Scaffold(
          body: Center(child: Text('No questions available')));
    }

    final q = widget.questions[qIndex];
    return SuccessConfetti(
      showConfetti: showConfetti,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: const BoxDecoration(gradient: bgGradient),
          child: SafeArea(
            child: Padding(
              padding: pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInSlide(
                    delay: 0.1,
                    child: Row(
                      children: [
                        const BackButton(color: Colors.white),
                        const SizedBox(width: 8),
                        Text('Assessment', style: h1(20)),
                        const Spacer(),
                        Text('${qIndex + 1}/${widget.questions.length}',
                            style: const TextStyle(color: Colors.white54))
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: FadeInSlide(
                      delay: 0.2,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 1,
                            )
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(q['question'] ?? '',
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 18)),
                            const SizedBox(height: 12),
                            if (q['type'] == 'mcq')
                              ...(q['choices'] as List)
                                  .asMap()
                                  .entries
                                  .map((e) {
                                final idx = e.key;
                                final text = e.value;
                                return FadeInSlide(
                                  delay: 0.3 + idx * 0.1,
                                  child: ListTile(
                                    title: Text(text,
                                        style: const TextStyle(
                                            color: Colors.white70)),
                                    leading: Radio<int>(
                                      value: idx,
                                      groupValue: answers[qIndex] as int?,
                                      onChanged: (v) =>
                                          setState(() => answers[qIndex] = v),
                                    ),
                                  ),
                                );
                              }),
                            if (q['type'] == 'short')
                              FadeInSlide(
                                delay: 0.3,
                                child: TextField(
                                  onChanged: (v) => answers[qIndex] = v,
                                  decoration: const InputDecoration(
                                      hintText: 'Write your answer',
                                      hintStyle:
                                          TextStyle(color: Colors.white38),
                                      filled: true,
                                      fillColor: Colors.white10),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            const Spacer(),
                            FadeInSlide(
                              delay: 0.4,
                              child: Row(
                                children: [
                                  if (qIndex > 0)
                                    OutlinedButton(
                                        onPressed: () =>
                                            setState(() => qIndex--),
                                        child: const Text('Back')),
                                  const Spacer(),
                                  if (submitting)
                                    const CircularProgressIndicator(),
                                  ElevatedButton(
                                      onPressed: submitting
                                          ? null
                                          : () {
                                              if (qIndex <
                                                  widget.questions.length - 1) {
                                                setState(() => qIndex++);
                                              } else {
                                                _finish();
                                              }
                                            },
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: accent,
                                          foregroundColor: Colors.black),
                                      child: Text(
                                          qIndex < widget.questions.length - 1
                                              ? 'Next'
                                              : 'Finish'))
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _finish() async {
    setState(() => submitting = true);

    int score = 0;
    for (int i = 0; i < widget.questions.length; i++) {
      final q = widget.questions[i];
      final ans = answers[i];

      if (q['type'] == 'mcq' && ans == q['correctAnswer']) {
        score++;
      } else if (q['type'] == 'short') {
        if ((ans ?? '').toString().trim().isNotEmpty) score += 1;
      }
    }

    final total = widget.questions.length;
    final percentage = (score / total * 100).round();

    String feedback = _generateFeedback(percentage);

    setState(() {
      submitting = false;
      showConfetti = percentage >= 70;
    });

    if (percentage >= 70) {
      _confettiController.play();
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Assessment Results'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (percentage >= 70)
              Lottie.asset(
                'assets/animations/success_celebration.json',
                width: 100,
                height: 100,
              ),
            Text('Score: $score / $total ($percentage%)',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text('Feedback:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text(feedback),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close')),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Return to Topics'),
          ),
        ],
      ),
    );
  }

  String _generateFeedback(int percentage) {
    if (percentage >= 90) {
      return 'Excellent! You have a strong understanding of this topic.';
    }
    if (percentage >= 70) {
      return 'Good work! You understand the main concepts but could review some details.';
    }
    if (percentage >= 50) {
      return 'You have a basic understanding. Focus on the key concepts you missed.';
    }
    return 'Keep studying! Review the material and try again. Focus on the fundamental concepts.';
  }
}

/* ---------------------------
   Flashcards Screen - Enhanced with Animations
   --------------------------- */
class FlashcardsScreen extends StatefulWidget {
  final FlashcardDeck deck;
  const FlashcardsScreen({super.key, required this.deck});
  @override
  _FlashcardsScreenState createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen> {
  int idx = 0;
  bool showBack = false;

  @override
  Widget build(BuildContext context) {
    final card = widget.deck.cards[idx];
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(widget.deck.name),
        backgroundColor: Colors.black26,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: bgGradient),
        child: SafeArea(
          child: Padding(
            padding: pagePadding,
            child: Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => showBack = !showBack),
                    child: Center(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 350),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 10,
                              spreadRadius: 2,
                            )
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(showBack ? card.back : card.front,
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 20),
                                textAlign: TextAlign.center),
                            const SizedBox(height: 12),
                            Text(showBack ? 'Back' : 'Front',
                                style: const TextStyle(
                                    color: Colors.white30, fontSize: 12))
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                FadeInSlide(
                  delay: 0.1,
                  child: Row(
                    children: [
                      IconButton(
                          icon: const Icon(Icons.navigate_before),
                          onPressed: idx > 0
                              ? () {
                                  setState(() {
                                    idx--;
                                    showBack = false;
                                  });
                                }
                              : null),
                      const Spacer(),
                      Text('${idx + 1} / ${widget.deck.cards.length}'),
                      const Spacer(),
                      IconButton(
                          icon: const Icon(Icons.navigate_next),
                          onPressed: idx < widget.deck.cards.length - 1
                              ? () {
                                  setState(() {
                                    idx++;
                                    showBack = false;
                                  });
                                }
                              : null),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* ---------------------------
   Planner Screen - Enhanced with Animations
   --------------------------- */
class PlannerScreen extends StatelessWidget {
  const PlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topics = appState.topics;
    return Padding(
      padding: pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInSlide(
            delay: 0.1,
            child: Text('Study Planner', style: h2(22)),
          ),
          const SizedBox(height: 12),
          if (topics.isEmpty)
            FadeInSlide(
              delay: 0.2,
              child: Center(
                child: Column(
                  children: [
                    Lottie.asset(
                      'assets/animations/empty_state.json',
                      width: 120,
                      height: 120,
                    ),
                    const Text('No topics created yet — start in Discover!'),
                  ],
                ),
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: topics.length,
              itemBuilder: (ctx, i) {
                final t = topics[i];
                return FadeInSlide(
                  delay: 0.1 + i * 0.1,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 5,
                          spreadRadius: 1,
                        )
                      ],
                    ),
                    child: ListTile(
                      title: Text(t.title),
                      subtitle: Text(t.plan == null
                          ? 'No study plan'
                          : '${t.plan!.tasks.length} tasks • ${DateFormat.yMd().format(t.plan!.deadline)}'),
                      trailing: t.plan == null
                          ? BounceIn(
                              delay: 0.2 + i * 0.1,
                              child: ElevatedButton(
                                  onPressed: () => _createPlan(context, t),
                                  child: const Text('Create plan')),
                            )
                          : BounceIn(
                              delay: 0.2 + i * 0.1,
                              child: ElevatedButton(
                                  onPressed: () => _viewPlan(context, t),
                                  child: const Text('View plan')),
                            ),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  void _createPlan(BuildContext ctx, StudyTopic t) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      builder: (_) => CreatePlanSheet(topic: t),
    );
  }

  void _viewPlan(BuildContext ctx, StudyTopic t) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Text('Study Plan for ${t.title}'),
        content: t.plan == null
            ? const Text('No plan created')
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        'Deadline: ${DateFormat.yMMMMd().format(t.plan!.deadline)}'),
                    Text('Daily hours: ${t.plan!.hoursPerDay}'),
                    const SizedBox(height: 16),
                    const Text('Schedule:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    ...t.plan!.tasks.map((task) => Text('• $task')),
                  ],
                ),
              ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Close')),
        ],
      ),
    );
  }
}

class CreatePlanSheet extends StatefulWidget {
  final StudyTopic topic;
  const CreatePlanSheet({super.key, required this.topic});
  @override
  _CreatePlanSheetState createState() => _CreatePlanSheetState();
}

class _CreatePlanSheetState extends State<CreatePlanSheet> {
  DateTime deadline = DateTime.now().add(const Duration(days: 7));
  int hours = 1;
  List<String> tasks = [];
  bool generating = false;

  Future<void> _generatePlan() async {
    setState(() => generating = true);

    await Future.delayed(const Duration(seconds: 2));

    final daysUntilDeadline = deadline.difference(DateTime.now()).inDays;
    tasks = _generateStructuredPlan(daysUntilDeadline);

    setState(() => generating = false);
  }

  List<String> _generateStructuredPlan(int totalDays) {
    if (totalDays <= 0) return ['Study intensively today'];

    return List.generate(totalDays, (index) {
      final dayNum = index + 1;
      if (dayNum == 1) {
        return 'Day $dayNum: Foundations & Core Concepts (${hours}hr)';
      }
      if (dayNum == 2) {
        return 'Day $dayNum: Practice Problems & Applications (${hours}hr)';
      }
      if (dayNum == totalDays - 1) {
        return 'Day $dayNum: Final Review & Weak Areas (${hours}hr)';
      }
      if (dayNum == totalDays) {
        return 'Day $dayNum: Quick Recap & Confidence Building (${hours}hr)';
      }
      return 'Day $dayNum: Topic Deep Dive & Exercises (${hours}hr)';
    });
  }

  void _savePlan() {
    final p = StudyPlan(
        deadline: deadline,
        hoursPerDay: hours,
        tasks: tasks.isEmpty
            ? [
                'Study $hours hour(s) daily until ${DateFormat.yMd().format(deadline)}'
              ]
            : tasks);
    appState.savePlan(widget.topic, p);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Study plan saved')));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 500,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInSlide(
            delay: 0.1,
            child: Text('Create Study Plan for ${widget.topic.title}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),
          FadeInSlide(
            delay: 0.2,
            child: Row(
              children: [
                const Text('Deadline:'),
                const SizedBox(width: 12),
                TextButton(
                    onPressed: _pickDate,
                    child: Text(DateFormat.yMMMMd().format(deadline))),
              ],
            ),
          ),
          const SizedBox(height: 12),
          FadeInSlide(
            delay: 0.3,
            child: Row(
              children: [
                const Text('Hours per day:'),
                const SizedBox(width: 12),
                DropdownButton<int>(
                  value: hours,
                  items: [1, 2, 3, 4, 5]
                      .map((e) => DropdownMenuItem(
                          value: e, child: Text('$e hour${e > 1 ? 's' : ''}')))
                      .toList(),
                  onChanged: (v) => setState(() => hours = v ?? 1),
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
          const FadeInSlide(
            delay: 0.4,
            child: Text('Study Schedule:',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 8),
          if (tasks.isNotEmpty)
            Expanded(
              child: ListView(
                children: tasks
                    .asMap()
                    .entries
                    .map((entry) => FadeInSlide(
                          delay: 0.5 + entry.key * 0.1,
                          child: Text('• ${entry.value}'),
                        ))
                    .toList(),
              ),
            )
          else
            const Expanded(
              child: FadeInSlide(
                delay: 0.5,
                child: Center(
                  child: Text(
                    'No tasks yet. Generate a plan or add custom tasks.',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),
          FadeInSlide(
            delay: 0.6,
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: generating ? null : _generatePlan,
                    child: generating
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Generate Smart Plan'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                      onPressed: _savePlan, child: const Text('Save Plan')),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _pickDate() async {
    final d = await showDatePicker(
        context: context,
        initialDate: deadline,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)));
    if (d != null) setState(() => deadline = d);
  }
}

/* ---------------------------
   Profile Screen - Enhanced with Animations
   --------------------------- */
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final totalTopics = appState.topics.length;
    final totalFlashcards = appState.topics.fold(
        0,
        (sum, topic) =>
            sum +
            topic.decks
                .fold(0, (deckSum, deck) => deckSum + deck.cards.length));
    final totalStudyTime = totalTopics * 45;

    return ListView(
      padding: pagePadding,
      children: [
        FadeInSlide(
          delay: 0.1,
          child: Text('Profile', style: h2(22)),
        ),
        const SizedBox(height: 12),
        const FadeInSlide(
          delay: 0.2,
          child: Row(
            children: [
              PulseAnimation(
                child: CircleAvatar(
                    radius: 36,
                    backgroundColor: accent,
                    child: Text('VC', style: TextStyle(color: Colors.black))),
              ),
              SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Victor',
                    style: TextStyle(color: Colors.white, fontSize: 18)),
                Text('Active learner', style: TextStyle(color: Colors.white54))
              ]),
              Spacer(),
              Column(children: [
                Text('Streak', style: TextStyle(color: Colors.white54)),
                SizedBox(height: 6),
                Text('7 days', style: TextStyle(color: accent))
              ])
            ],
          ),
        ),
        const SizedBox(height: 20),
        const FadeInSlide(
          delay: 0.3,
          child:
              Text('Study Statistics', style: TextStyle(color: Colors.white70)),
        ),
        const SizedBox(height: 8),
        FadeInSlide(
          delay: 0.4,
          child: Row(
            children: [
              _statBox('Topics', '$totalTopics', 0),
              const SizedBox(width: 8),
              _statBox('Flashcards', '$totalFlashcards', 1),
              const SizedBox(width: 8),
              _statBox('Minutes', '$totalStudyTime', 2),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const FadeInSlide(
          delay: 0.5,
          child: Text('Settings', style: TextStyle(color: Colors.white70)),
        ),
        FadeInSlide(
          delay: 0.6,
          child: ListTile(
              leading: const Icon(Icons.sync),
              title: const Text('Cloud Sync'),
              trailing: Switch(value: false, onChanged: (_) {})),
        ),
        FadeInSlide(
          delay: 0.7,
          child: ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Study Reminders'),
              trailing: Switch(value: true, onChanged: (_) {})),
        ),
        FadeInSlide(
          delay: 0.8,
          child: ListTile(
              leading: const Icon(Icons.security),
              title: const Text('Data Privacy & Export'),
              onTap: () {}),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _statBox(String label, String value, int index) {
    return Expanded(
      child: BounceIn(
        delay: 0.4 + index * 0.1,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 5,
                spreadRadius: 1,
              )
            ],
          ),
          child: Column(
            children: [
              Text(value,
                  style: const TextStyle(
                      color: accent,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(label, style: const TextStyle(color: Colors.white54))
            ],
          ),
        ),
      ),
    );
  }
}

/* ---------------------------
   Search Delegate - Enhanced with Animations
   --------------------------- */
class TopicSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return const BackButton();
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = appState.topics
        .where((topic) =>
            topic.title.toLowerCase().contains(query.toLowerCase()) ||
            topic.notes.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return Padding(
      padding: pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInSlide(
            delay: 0.1,
            child: Text('Search Results for "$query"', style: h2(18)),
          ),
          const SizedBox(height: 12),
          if (results.isEmpty)
            const FadeInSlide(
              delay: 0.2,
              child: Center(child: Text('No topics found. Create a new one?')),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: results.length,
              itemBuilder: (ctx, i) {
                final topic = results[i];
                return FadeInSlide(
                  delay: 0.1 + i * 0.1,
                  child: ListTile(
                    leading: CircleAvatar(
                        backgroundColor: primary,
                        child: Text(topic.title[0].toUpperCase())),
                    title: Text(topic.title),
                    subtitle: Text(topic.notes.length > 100
                        ? '${topic.notes.substring(0, 100)}...'
                        : topic.notes),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => TopicDetailScreen(topic: topic),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final recentTopics = appState.topics.take(5).toList();
    final suggestions = recentTopics.map((t) => t.title).toList();

    final filtered = suggestions
        .where((s) => s.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView(
      children: [
        if (query.isEmpty) ...[
          const Padding(
            padding: EdgeInsets.all(16),
            child: FadeInSlide(
              delay: 0.1,
              child: Text('Recent Topics',
                  style: TextStyle(
                      color: Colors.white70, fontWeight: FontWeight.bold)),
            ),
          ),
          ...recentTopics.asMap().entries.map((entry) => FadeInSlide(
                delay: 0.2 + entry.key * 0.1,
                child: ListTile(
                  leading: const Icon(Icons.history, color: Colors.white54),
                  title: Text(entry.value.title),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => TopicDetailScreen(topic: entry.value),
                      ),
                    );
                  },
                ),
              )),
        ] else
          ...filtered.asMap().entries.map((entry) => FadeInSlide(
                delay: 0.1 + entry.key * 0.1,
                child: ListTile(
                    title: Text(entry.value), onTap: () => query = entry.value),
              )),
      ],
    );
  }
}
