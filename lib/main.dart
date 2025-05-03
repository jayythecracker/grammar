import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/services.dart';

void main() async {
  await dotenv.load(fileName: "assets/.env");
  runApp(const GrammarCheckerApp());
}

class GrammarCheckerApp extends StatelessWidget {
  const GrammarCheckerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6200EE),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        cardTheme: const CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: const Color(0xFF6200EE), width: 2),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6200EE),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        cardTheme: CardTheme(
          elevation: 0,
          color: Colors.grey.shade900,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade800,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFBB86FC), width: 2),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      themeMode: ThemeMode.light,
      home: const GrammarCheckerScreen(),
    );
  }
}

class GrammarCheckerScreen extends StatefulWidget {
  const GrammarCheckerScreen({super.key});

  @override
  State<GrammarCheckerScreen> createState() => _GrammarCheckerScreenState();
}

class _GrammarCheckerScreenState extends State<GrammarCheckerScreen> {
  final TextEditingController _textController = TextEditingController();
  String correctedText = "";
  bool isLoading = false;
  String? errorMessage;

  Future<void> checkGrammar(String text) async {
    String apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';

    setState(() {
      isLoading = true;
      errorMessage = null;
      correctedText = "";
    });

    try {
      final model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: apiKey);

      final prompt = '''
Act as a professional grammar checker and translator. Please:
1. If the text is not in English, translate it to English
2. Check and fix any grammar mistakes
3. Explain the corrections or translation changes made
4. Format the response clearly with Original, Corrected, and Explanation sections

Text to check: $text
''';

      final response = await model.generateContent([Content.text(prompt)]);

      setState(() {
        correctedText = response.text ?? "No correction needed.";
      });
    } catch (e) {
      setState(() {
        errorMessage = "Error: ${e.toString()}";
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      setState(() {
        _textController.text = data!.text!;
      });
    }
  }

  void _clearText() {
    setState(() {
      _textController.clear();
      correctedText = "";
      errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            Icon(Icons.spellcheck_rounded, color: colorScheme.primary),
            const SizedBox(width: 12),
            Text(
              "Grammar Guru",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: colorScheme.onBackground,
              ),
            ),
          ],
        ),
        actions: [],
        backgroundColor: colorScheme.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 88),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        Text(
                          "Text to check",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onBackground,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            color:
                                isDark
                                    ? Colors.grey.shade800
                                    : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow:
                                isDark
                                    ? []
                                    : [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  16,
                                  16,
                                  8,
                                ),
                                child: TextField(
                                  controller: _textController,
                                  maxLines: 5,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: colorScheme.onBackground,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: "Type or paste your text here...",
                                    hintStyle: TextStyle(
                                      color: colorScheme.onBackground
                                          .withOpacity(0.5),
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.all(16),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                                child: Row(
                                  children: [
                                    IconButton(
                                      onPressed: _pasteFromClipboard,
                                      icon: Icon(
                                        Icons.content_paste_rounded,
                                        color: colorScheme.primary,
                                      ),
                                      tooltip: 'Paste from clipboard',
                                    ),
                                    IconButton(
                                      onPressed: _clearText,
                                      icon: Icon(
                                        Icons.clear_rounded,
                                        color: colorScheme.onBackground
                                            .withOpacity(0.5),
                                      ),
                                      tooltip: 'Clear text',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        if (errorMessage != null)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline_rounded,
                                  color: colorScheme.error,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    errorMessage!,
                                    style: TextStyle(color: colorScheme.error),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        if (correctedText.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          Container(
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer.withOpacity(
                                0.5,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle_rounded,
                                      color: colorScheme.primary,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      "Analysis Result",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Divider(
                                  color: colorScheme.onBackground.withOpacity(
                                    0.1,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ...correctedText.split('\n').map((part) {
                                  if (part.trim().isEmpty) {
                                    return const SizedBox(height: 8);
                                  }

                                  if (part.startsWith('Original:') ||
                                      part.startsWith('Corrected:') ||
                                      part.startsWith('Explanation:')) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 8),
                                        Text(
                                          part,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: colorScheme.primary,
                                            height: 1.5,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                      ],
                                    );
                                  }

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    child: Text(
                                      part,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: colorScheme.onBackground,
                                        height: 1.5,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        ],
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed:
                      isLoading
                          ? null
                          : () => checkGrammar(_textController.text),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    disabledBackgroundColor: colorScheme.onBackground
                        .withOpacity(0.1),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child:
                      isLoading
                          ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.onPrimary,
                            ),
                          )
                          : const Text(
                            "Check Grammar",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
