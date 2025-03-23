// quiz_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'video_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  Map<int, String> _answers = {};
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }


  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'How often do you meditate?',
      'options': ['Daily', 'Weekly', 'Occasionally']
    },
    {
      'question': 'What is your primary goal for meditation?',
      'options': ['Reduce Stress', 'Improve Focus', 'Self-Awareness']
    },
    {
      'question': 'Preferred time of the day to meditate?',
      'options': ['Morning', 'Afternoon', 'Night']
    },
  ];

  void _nextQuestion(String answer) {
    setState(() {
      _answers[_currentQuestionIndex] = answer;
      if (_currentQuestionIndex < _questions.length - 1) {
        _currentQuestionIndex++;
        _pageController.nextPage(duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const VideoScreen()),
        );
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F0E6),
      body: PageView.builder(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _questions.length,
        itemBuilder: (context, index) {
          final question = _questions[index];
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: Text(
                    question['question'],
                    key: ValueKey(question['question']),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF203A43),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                ...question['options'].map<Widget>((option) => _buildOption(option)).toList(),
              ],
            ),
          );
        },
      ),
    );
  }


  Widget _buildOption(String option) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton(
        onPressed: () => _nextQuestion(option),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF203A43),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          elevation: 4,
        ),
        child: Center(
          child: Text(
            option,
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
