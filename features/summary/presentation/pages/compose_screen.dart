import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';

class ComposeScreen extends StatefulWidget {
  final Map<String, dynamic>? extra;

  const ComposeScreen({super.key, this.extra});

  @override
  State<ComposeScreen> createState() => _ComposeScreenState();
}

class _ComposeScreenState extends State<ComposeScreen> {
  final _toController = TextEditingController();
  final _subjectController = TextEditingController();
  final _bodyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Prefill if replying
    if (widget.extra != null) {
      if (widget.extra!.containsKey('to')) {
        _toController.text = widget.extra!['to'];
      }
      if (widget.extra!.containsKey('subject')) {
        _subjectController.text = 'Re: ${widget.extra!['subject']}';
      }
    }
  }

  @override
  void dispose() {
    _toController.dispose();
    _subjectController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: const Text('Compose'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Bootstrap.paperclip),
            tooltip: 'Attach file',
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Email Sent!')));
              context.pop();
            },
            icon: const Icon(Bootstrap.send_fill),
            color: Theme.of(context).colorScheme.primary,
            tooltip: 'Send',
          ).animate().scale(
            duration: 400.ms,
            curve: Curves.elasticOut,
            delay: 200.ms,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _toController,
                    decoration: const InputDecoration(
                      labelText: 'To',
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.person_outline, size: 20),
                    ),
                  ),
                  const Divider(height: 1),
                  TextField(
                    controller: _subjectController,
                    decoration: const InputDecoration(
                      labelText: 'Subject',
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.title, size: 20),
                    ),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Divider(height: 1),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _bodyController,
                  maxLines: null,
                  expands: true,
                  decoration: const InputDecoration(
                    hintText: 'Compose email...',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Mock AI Assist
          setState(() {
            _bodyController.text =
                "Hi there,\n\nHere is the update you requested regarding the project status. We are on track for the Q1 deadline.\n\nBest regards,";
          });
        },
        icon: const Icon(Bootstrap.stars),
        label: const Text('AI Assist'),
        backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onTertiaryContainer,
      ).animate().slideY(begin: 1, end: 0, delay: 500.ms, curve: Curves.easeOut),
    );
  }
}
