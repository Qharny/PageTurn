import 'package:flutter/material.dart';
import '../../theme.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final List<_FaqItem> _faqs = [
    _FaqItem(
      question: 'How do I join a Reading Club?',
      answer: 'Navigate to Reading Clubs from the drawer menu and tap the "Join" button on any club you\'d like to be a part of. Membership is instant and free.',
    ),
    _FaqItem(
      question: 'Can I read books offline?',
      answer: 'Yes! Enable "Offline Mode" in Settings to download books to your device. Downloaded books are available even without an internet connection.',
    ),
    _FaqItem(
      question: 'How do I track my reading progress?',
      answer: 'Your progress is tracked automatically as you read. Visit your Library to view progress bars on each book, and the Reading Goal card in the drawer shows your yearly goal.',
    ),
    _FaqItem(
      question: 'Can I switch between audiobook and e-book?',
      answer: 'Absolutely. Tap any book to open its detail page, and you\'ll see both "Read" and "Listen" options to switch seamlessly between formats.',
    ),
    _FaqItem(
      question: 'How do I cancel my subscription?',
      answer: 'Go to Settings > Account to manage your subscription. You can pause or cancel at any time. Your existing downloads will remain accessible until the period ends.',
    ),
    _FaqItem(
      question: 'Why can\'t I find a specific book?',
      answer: 'Our catalog grows weekly. Use the Search tab to look for a specific title. If it\'s not available, tap "Request a Book" and we\'ll work on adding it.',
    ),
  ];

  final Set<int> _expandedItems = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.neutral,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'How can we\nhelp you?',
                      style: TextStyle(
                        fontFamily: 'Literata',
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E1E1E),
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildContactCards(),
                    const SizedBox(height: 28),
                    const Text(
                      'Frequently Asked\nQuestions',
                      style: TextStyle(
                        fontFamily: 'Literata',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E1E1E),
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._faqs.asMap().entries.map((e) => _buildFaqCard(e.key, e.value)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF2ECE4), width: 1.2),
              ),
              child: const Icon(Icons.arrow_back_rounded, color: Color(0xFF5C3826), size: 20),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'Help & Support',
            style: TextStyle(
              fontFamily: 'Literata',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5C3826),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCards() {
    return Row(
      children: [
        Expanded(
          child: _buildContactCard(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'Live Chat',
            subtitle: 'Available 24/7',
            color: const Color(0xFF2D6A4F),
            bgColor: const Color(0xFFE8F0EC),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildContactCard(
            icon: Icons.mail_outline_rounded,
            title: 'Email Us',
            subtitle: 'Reply in 24h',
            color: const Color(0xFF8C481A),
            bgColor: const Color(0xFFFDF0E9),
          ),
        ),
      ],
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color bgColor,
  }) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.15), width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 10),
            Text(title, style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.bold, color: color)),
            Text(subtitle, style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: Color(0xFF7A6B63))),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqCard(int index, _FaqItem faq) {
    final isExpanded = _expandedItems.contains(index);
    return GestureDetector(
      onTap: () => setState(() {
        if (isExpanded) {
          _expandedItems.remove(index);
        } else {
          _expandedItems.add(index);
        }
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isExpanded ? Colors.white : Colors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isExpanded ? const Color(0xFFE8DFD3) : const Color(0xFFF2ECE4),
            width: 1.2,
          ),
          boxShadow: isExpanded
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 3))]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    faq.question,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: isExpanded ? FontWeight.bold : FontWeight.w600,
                      color: isExpanded ? const Color(0xFF8C481A) : const Color(0xFF1E1E1E),
                    ),
                  ),
                ),
                Icon(
                  isExpanded ? Icons.remove_rounded : Icons.add_rounded,
                  color: isExpanded ? AppTheme.primary : const Color(0xFF7A6B63),
                  size: 20,
                ),
              ],
            ),
            if (isExpanded) ...[
              const SizedBox(height: 10),
              const Divider(color: Color(0xFFF2ECE4), height: 1),
              const SizedBox(height: 10),
              Text(
                faq.answer,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: Color(0xFF5C3826),
                  height: 1.6,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FaqItem {
  final String question;
  final String answer;
  _FaqItem({required this.question, required this.answer});
}
