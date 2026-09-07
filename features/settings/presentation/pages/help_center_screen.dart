import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  static const _faqs = [
    _FAQ(
      question: 'How does email forwarding to WhatsApp work?',
      answer:
          'Mail-Up monitors your Gmail inbox in real time. When a new email arrives that matches your forwarding rules (by label or contact), it automatically sends a WhatsApp message with the sender, subject, and a summary to your configured number.',
    ),
    _FAQ(
      question: 'How do I set up WhatsApp forwarding?',
      answer:
          'Go to Settings → WhatsApp Settings. Enable the toggle, enter your WhatsApp number with the country code (e.g. +923001234567), then open Forwarding Rules to choose which labels or contact groups should trigger forwarding.',
    ),
    _FAQ(
      question: 'What are Forwarding Rules?',
      answer:
          'Forwarding Rules let you control exactly which emails get forwarded. You can forward by Label — any email arriving in a selected Gmail label — or by Contact Group, where you group sender email addresses (e.g. "VIP", "Boss") and toggle them on.',
    ),
    _FAQ(
      question: 'How do I add a contact for forwarding?',
      answer:
          'Open Settings → WhatsApp Settings → Forwarding Rules → Forward by Contact. Tap "New Group" to create a group (e.g. "Family"), then tap "Add Email Address" inside the group card and enter the sender\'s email. Enable the group toggle to activate forwarding.',
    ),
    _FAQ(
      question: 'Why am I getting duplicate or bulk notifications?',
      answer:
          'Mail-Up uses Gmail\'s History API to track only new emails since the last check. If you see duplicates, it usually means the app was restarted or reinstalled. The history sync resets and catches up — this resolves itself after the first successful push.',
    ),
    _FAQ(
      question: 'What does the AI summary do?',
      answer:
          'When you open an email, Mail-Up uses Google Gemini to generate a concise summary of the email body. This helps you quickly understand the key points, action items, and sender intent without reading the full email.',
    ),
    _FAQ(
      question: 'Can I reply to emails from WhatsApp?',
      answer:
          'Yes! When you reply to a forwarded WhatsApp message, Mail-Up sends your reply back as a Gmail reply to the original email thread. Make sure you reply directly to the forwarded message (not a new message) for this to work.',
    ),
    _FAQ(
      question: 'How do I filter my inbox by label?',
      answer:
          'In the Inbox, use the filter chips bar just below the header. Tap any label chip (Inbox, Starred, Promotions, or your custom labels) to switch to that view instantly. Tap the "New" chip to create a new Gmail label on the spot.',
    ),
    _FAQ(
      question: 'How do I assign a label to an email?',
      answer:
          'Long press any email in the inbox to open the label assignment sheet. Your custom labels will appear with checkboxes — tap one to assign or remove it from that email.',
    ),
    _FAQ(
      question: 'How do I sign out?',
      answer:
          'Go to Settings (bottom nav) and scroll to the bottom. Tap "Sign Out" and confirm. This will disconnect your Google account and return you to the login screen.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(child: _HelpHeader()),

          // Quick help cards
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionLabel('Quick Help'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickCard(
                          icon: Bootstrap.whatsapp,
                          color: const Color(0xFF25D366),
                          label: 'Setup WhatsApp',
                          onTap: () => _scrollToFaq(context, 1),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickCard(
                          icon: Bootstrap.funnel_fill,
                          color: Colors.purple,
                          label: 'Forwarding Rules',
                          onTap: () => _scrollToFaq(context, 2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickCard(
                          icon: Bootstrap.cpu,
                          color: Colors.teal,
                          label: 'AI Summary',
                          onTap: () => _scrollToFaq(context, 5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // FAQ section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 10),
              child: _SectionLabel('Frequently Asked Questions'),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _FaqTile(faq: _faqs[index], index: index),
                childCount: _faqs.length,
              ),
            ),
          ),

          // Still need help
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
              child: _SectionLabel('Still need help?'),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _ContactTile(
                  icon: Bootstrap.envelope_fill,
                  iconColor: Colors.blue,
                  title: 'Email Support',
                  subtitle: 'support@mailup.app',
                  onTap: () {},
                ),
                const SizedBox(height: 8),
                _ContactTile(
                  icon: Bootstrap.github,
                  iconColor: Theme.of(context).colorScheme.onSurface,
                  title: 'Report a Bug',
                  subtitle: 'Open an issue on GitHub',
                  onTap: () {},
                ),
                const SizedBox(height: 28),
                Center(
                  child: Text(
                    'Mail-Up • Version 1.0.0',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _scrollToFaq(BuildContext context, int index) {
    // Just a placeholder — tapping quick cards is informational
  }
}

class _HelpHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 20,
        right: 20,
        bottom: 28,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.tertiary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Bootstrap.question_circle_fill,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Help Center',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Find answers to common questions about Mail-Up',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _QuickCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FaqTile extends StatefulWidget {
  final _FAQ faq;
  final int index;

  const _FaqTile({required this.faq, required this.index});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _controller;
  late final Animation<double> _rotationAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _rotationAnim = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    if (_expanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: _toggle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            color: _expanded
                ? Theme.of(context).colorScheme.primaryContainer.withValues(
                    alpha: 0.4,
                  )
                : Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(14),
            border: _expanded
                ? Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.3),
                  )
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Center(
                        child: Text(
                          '${widget.index + 1}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.faq.question,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    RotationTransition(
                      turns: _rotationAnim,
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        size: 22,
                      ),
                    ),
                  ],
                ),
                if (_expanded) ...[
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.only(left: 38),
                    child: Text(
                      widget.faq.answer,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ContactTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _FAQ {
  final String question;
  final String answer;
  const _FAQ({required this.question, required this.answer});
}
