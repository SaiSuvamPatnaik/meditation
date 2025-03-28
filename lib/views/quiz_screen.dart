import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_page.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  Map<int, String> _answers = {};
  late final PageController _pageController;

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
    {
      'question': 'How long is your typical meditation session?',
      'options': ['5-10 minutes', '10-20 minutes', 'More than 20 minutes']
    },
    {
      'question': 'Where do you usually meditate?',
      'options': ['Home', 'Outdoors', 'Yoga/Meditation Center']
    },
    {
      'question': 'Which type of meditation do you prefer?',
      'options': ['Guided', 'Silent', 'Breathing-focused']
    },
  ];


  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  void _submitQuiz() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
  }

  Widget _buildOption(String label, String option, bool selected) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: selected ? const Color(0xFFD84319) : Colors.white,
        border: Border.all(color: const Color(0xFFD84319).withOpacity(0.4), width: 1.2),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        title: Text(option,
            style: GoogleFonts.poppins(
                color: selected ? Colors.white : const Color(0xFFD84319),
                fontWeight: FontWeight.w500)),
        leading: CircleAvatar(
          backgroundColor: selected ? Colors.white : Colors.grey.shade300,
          child: Text(label,
              style: GoogleFonts.poppins(
                  color: selected ? const Color(0xFFD84319) : Colors.black)),
        ),
        onTap: () {
          setState(() {
            _answers[_currentQuestionIndex] = option;
          });
        },
      ),
    );
  }

  List<Widget> _buildQuestionNav() {
    return List.generate(_questions.length, (index) {
      final isActive = index == _currentQuestionIndex;
      return CircleAvatar(
        radius: 16,
        backgroundColor: isActive ? const Color(0xFFD84319) : Colors.grey.shade300,
        child: Text(
          '${index + 1}',
          style: GoogleFonts.poppins(
              color: isActive ? Colors.white : Colors.black, fontSize: 14),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentQuestionIndex];
    return Scaffold(
      backgroundColor: const Color(0xFFE5E4E2),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const BackButton(color: Color(0xFFD84319)),
                  Text(
                    'Lets Understand You',
                    style: GoogleFonts.roboto(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFdd4c1b))
                  ),
                  Row(
                    children: [
                      // const Icon(Icons.timer, size: 18, color: Color(0xFFD84319)),
                      const SizedBox(width: 4),
                      // Text("16:35",
                      //     style: GoogleFonts.poppins(
                      //         fontWeight: FontWeight.w500,
                      //         color: const Color(0xFFD84319)))
                    ],
                  )
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: _buildQuestionNav(),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      question['question'],
                      style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFD84319)),
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(
                      question['options'].length,
                          (i) => _buildOption(
                        String.fromCharCode(65 + i),
                        question['options'][i],
                        _answers[_currentQuestionIndex] == question['options'][i],
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                            onPressed: _currentQuestionIndex > 0
                                ? () {
                              setState(() {
                                _currentQuestionIndex--;
                              });
                            }
                                : null,
                            icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFD84319))),
                        ElevatedButton(
                          onPressed: () {
                            if (_currentQuestionIndex < _questions.length - 1) {
                              setState(() {
                                _currentQuestionIndex++;
                              });
                            } else {
                              _submitQuiz();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(color: Color(0xFFD84319))),
                          ),
                          child: Text(
                            _currentQuestionIndex == _questions.length - 1
                                ? "Submit Quiz"
                                : "Next",
                            style: GoogleFonts.poppins(
                                color: const Color(0xFFD84319),
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        IconButton(
                            onPressed: () {
                              if (_currentQuestionIndex < _questions.length - 1) {
                                setState(() {
                                  _currentQuestionIndex++;
                                });
                              } else {
                                _submitQuiz();
                              }
                            },
                            icon: const Icon(Icons.arrow_forward_ios, color: Color(0xFFD84319)))
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
