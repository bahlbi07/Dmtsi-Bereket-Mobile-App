import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/analytics_service.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});
  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _feedbackController = TextEditingController();
  String _feedbackType = 'General Feedback';
  int _rating = 5; // 🌟 ሓዱሽ፡ ደረጃ (Rating) ንምዕቃብ
  bool _isLoading = false; // 🌟 ሓዱሽ፡ ናይ ምልኣኽ ኣኒሜሽን ሎዲንግ ስቴት

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _submitFeedback() async {
    if (_isLoading) return;
    HapticFeedback.lightImpact();

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // 🌟 ተጠቃሚ ዝጸሓፎ ርእይቶ ምስቲ ሓዱሽ Star Rating ብሓባር ናብ ሰርቨር ምልኣኽ
      AnalyticsService.track('feedback_submitted', {
        'type': _feedbackType,
        'rating': _rating,
        'msg': _feedbackController.text.trim(),
      });

      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: 'dmtsibereketapp@gmail.com',
        query: 'subject=App Feedback [$_feedbackType] - Rating: $_rating/5'
            '&body=Rating: $_rating/5 Stars\n\nFeedback:\n${_feedbackController.text}',
      );

      try {
        await launchUrl(emailUri);
        if (mounted) Navigator.maybePop(context);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Could not open email client.',
                style: TextStyle(fontFamily: 'Nyala'),
              ),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const primaryColor = Color(0xFFC61B1B);

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F7),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 38.0, vertical: 8.0),
              child: Row(
                children: [
                  IconButton(
                    icon:
                        const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.maybePop(context);
                    },
                  ),
                  const Text(
                    'ርእይቶ (Feedback)',
                    style: TextStyle(
                      fontFamily: 'Nyala',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 38.0, vertical: 10.0),
                child: Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          'ሓሳብኩም ወይ ርእይቶኹም ኣዝዩ የሐጉሰና! ዝኾነ ይኹን ጸገም ወይ መመሓየሺ ሓሳብ እንተለኩም፡ ኣብዚ ጽሒፍኩም ስደዱልና።',
                          style: TextStyle(
                              fontFamily: 'Nyala', fontSize: 18, height: 1.6),
                        ),
                        const SizedBox(height: 25),

                        // --- 🌟 ሓዱሽ ፊቸር፦ ደረጃ ምሃብ (Interactive Star Rating) ---
                        const Text(
                          'ደረጃ ሃቡና (Rate Us)',
                          style: TextStyle(
                            fontFamily: 'Nyala',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: List.generate(5, (index) {
                            final starIndex = index + 1;
                            return IconButton(
                              icon: Icon(
                                _rating >= starIndex
                                    ? Icons.star_rounded
                                    : Icons.star_border_rounded,
                                size: 36,
                              ),
                              color: _rating >= starIndex
                                  ? Colors.amber
                                  : Colors.grey,
                              onPressed: () {
                                HapticFeedback.selectionClick();
                                setState(() {
                                  _rating = starIndex;
                                });
                              },
                            );
                          }),
                        ),
                        const SizedBox(height: 25),

                        // --- 🌟 ሓዱሽ ምምሕያሽ፦ Choice Chips (ኣብ ክንዲ Dropdown) ---
                        const Text(
                          'ዓይነት ርእይቶ (Feedback Type)',
                          style: TextStyle(
                            fontFamily: 'Nyala',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: [
                            _buildChoiceChip(
                              label: 'General Feedback',
                              icon: Icons.chat_bubble_outline_rounded,
                              selected: _feedbackType == 'General Feedback',
                              onSelected: (selected) {
                                if (selected) {
                                  setState(
                                      () => _feedbackType = 'General Feedback');
                                }
                              },
                              isDark: isDark,
                            ),
                            _buildChoiceChip(
                              label: 'Bug Report',
                              icon: Icons.bug_report_outlined,
                              selected: _feedbackType == 'Bug Report',
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() => _feedbackType = 'Bug Report');
                                }
                              },
                              isDark: isDark,
                            ),
                            _buildChoiceChip(
                              label: 'Feature Request',
                              icon: Icons.lightbulb_outline_rounded,
                              selected: _feedbackType == 'Feature Request',
                              onSelected: (selected) {
                                if (selected) {
                                  setState(
                                      () => _feedbackType = 'Feature Request');
                                }
                              },
                              isDark: isDark,
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),

                        // --- 🌟 ዝተማሓየሸ TextFormField (Outline Border & Character Counter) ---
                        TextFormField(
                          controller: _feedbackController,
                          maxLength: 500, // ፊደላት መቑጸሪ
                          style: const TextStyle(
                              fontFamily: 'Nyala', fontSize: 18),
                          maxLines: 5,
                          decoration: InputDecoration(
                            labelText: 'ናትኩም ርእይቶ',
                            labelStyle: const TextStyle(
                                fontFamily: 'Nyala',
                                fontSize: 18,
                                color: primaryColor),
                            hintText: 'ነቲ ርእይቶኹም ኣብዚ ብዝርዝር ጽሓፉ...',
                            hintStyle: const TextStyle(
                                fontFamily: 'Nyala', fontSize: 16),
                            alignLabelWithHint: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                  color: primaryColor, width: 2),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: isDark
                                    ? Colors.grey.shade800
                                    : Colors.grey.shade300,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'በጃኹም ርእይቶኹም ኣእትዉ።';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 35),

                        // --- 🌟 ሓዱሽ ፊቸር፦ ኣኒሜሽን ዘለዎ ምልኣኽ ባተን (Loading Submit Button) ---
                        Center(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: _isLoading ? 80 : 220,
                            height: 52,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      _isLoading ? 26 : 30),
                                ),
                                elevation: 2,
                              ),
                              onPressed: _isLoading ? null : _submitFeedback,
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.send_rounded, size: 20),
                                        SizedBox(width: 8),
                                        Text(
                                          'ብኢመይል ስደድ',
                                          style: TextStyle(
                                            fontFamily: 'Nyala',
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🌟 Choice Chips ንምስራሕ ዘገልግል Helper Widget
  Widget _buildChoiceChip({
    required String label,
    required IconData icon,
    required bool selected,
    required ValueChanged<bool> onSelected,
    required bool isDark,
  }) {
    const primaryColor = Color(0xFFC61B1B);
    return ChoiceChip(
      avatar: Icon(
        icon,
        size: 18,
        color: selected
            ? Colors.white
            : (isDark ? Colors.grey.shade400 : Colors.grey.shade700),
      ),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: selected
              ? Colors.white
              : (isDark ? Colors.grey.shade300 : Colors.grey.shade800),
        ),
      ),
      selected: selected,
      onSelected: (val) {
        HapticFeedback.selectionClick();
        onSelected(val);
      },
      selectedColor: primaryColor,
      backgroundColor:
          isDark ? const Color(0xFF2A2A2A) : const Color(0xFFEEEEEE),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected
              ? primaryColor
              : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
        ),
      ),
      elevation: selected ? 2 : 0,
      pressElevation: 1,
    );
  }
}
