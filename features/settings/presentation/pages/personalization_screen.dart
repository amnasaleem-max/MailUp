import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:mail_up/features/settings/presentation/providers/ai_settings_provider.dart';
import 'package:mail_up/features/settings/presentation/providers/gemini_models_provider.dart';

class PersonalizationScreen extends ConsumerStatefulWidget {
  const PersonalizationScreen({super.key});

  @override
  ConsumerState<PersonalizationScreen> createState() =>
      _PersonalizationScreenState();
}

class _PersonalizationScreenState extends ConsumerState<PersonalizationScreen> {
  String _formatModelName(String model) {
    if (model.startsWith('gemini-')) {
      final parts = model.split('-');
      if (parts.length >= 3) {
        final version = parts[1];
        final type = parts
            .sublist(2)
            .map((p) => p.isEmpty ? '' : p[0].toUpperCase() + p.substring(1))
            .join(' ');
        return 'Gemini $version $type';
      } else if (parts.length == 2) {
        final name = parts[1][0].toUpperCase() + parts[1].substring(1);
        return 'Gemini $name';
      }
    }
    return model;
  }

  @override
  Widget build(BuildContext context) {
    final aiSettings = ref.watch(aiSettingsProvider);
    final modelsAsync = ref.watch(geminiModelsProvider);
    final theme = Theme.of(context);

    final isOnline = modelsAsync.maybeWhen(
      data: (models) => models.isNotEmpty,
      orElse: () => true, // Default to true while loading/unresolved
    );
    final isLoading = modelsAsync.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Control Center'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          // Engine Status Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.tertiary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Bootstrap.cpu, color: Colors.white, size: 32),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isOnline
                            ? Colors.white.withValues(alpha: 0.2)
                            : Colors.red.shade900.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(20),
                        border: isOnline
                            ? null
                            : Border.all(color: Colors.red.shade300, width: 1.5),
                      ),
                      child: Text(
                        isLoading
                            ? 'CHECKING...'
                            : isOnline
                                ? 'ONLINE'
                                : 'OFFLINE',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Summarization Engine',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isLoading
                      ? 'Checking connection status...'
                      : isOnline
                          ? 'Processing emails in real-time'
                          : 'Gemini API Key is invalid or disconnected',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Model Selection
          Text(
            'AI Model',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: DropdownButtonHideUnderline(
              child: modelsAsync.when(
                loading: () => const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                error: (err, stack) => DropdownButton<String>(
                  value: aiSettings.model,
                  icon: const Icon(Icons.arrow_drop_down),
                  isExpanded: true,
                  items: [
                    DropdownMenuItem(
                      value: aiSettings.model,
                      child: Text(_formatModelName(aiSettings.model)),
                    ),
                  ],
                  onChanged: null,
                ),
                data: (models) {
                  final availableModels = models.isEmpty
                      ? [aiSettings.model]
                      : (models.contains(aiSettings.model)
                          ? models
                          : [aiSettings.model, ...models]);

                  return DropdownButton<String>(
                    value: aiSettings.model,
                    icon: const Icon(Icons.arrow_drop_down),
                    isExpanded: true,
                    items: availableModels.map((m) {
                      return DropdownMenuItem(
                        value: m,
                        child: Text(_formatModelName(m)),
                      );
                    }).toList(),
                    onChanged: models.isEmpty
                        ? null
                        : (value) {
                            ref
                                .read(aiSettingsProvider.notifier)
                                .setModel(value!);
                          },
                  );
                },
              ),
            ),
          ),
          if (!isLoading && !isOnline) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    size: 14, color: theme.colorScheme.error),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Invalid Gemini API key. Model selection is disabled.',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.error),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 32),

          // Summary Length Stepper
          Text(
            'Summary Detail',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Theme.of(context).colorScheme.primary,
              inactiveTrackColor: Theme.of(context).colorScheme.outlineVariant,
              thumbColor: Theme.of(context).colorScheme.primary,
              overlayColor: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.2),
              trackHeight: 6,
            ),
            child: Slider(
              value: aiSettings.summaryLength,
              min: 0,
              max: 2,
              divisions: 2,
              onChanged: (value) {
                ref.read(aiSettingsProvider.notifier).setSummaryLength(value);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLabel('Brief'),
                _buildLabel('Standard'),
                _buildLabel('Detailed'),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Tone Selection
          Text(
            'Tone',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            children: [
              _buildToneChip('Professional', Bootstrap.briefcase),
              _buildToneChip('Casual', Bootstrap.emoji_smile),
              _buildToneChip('Direct', Bootstrap.lightning),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildToneChip(String label, IconData icon) {
    final aiSettings = ref.watch(aiSettingsProvider);
    final isSelected = aiSettings.tone == label;
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurface,
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (bool selected) {
        if (selected) {
          ref.read(aiSettingsProvider.notifier).setTone(label);
        }
      },
      selectedColor: Theme.of(context).colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected
            ? Theme.of(context).colorScheme.onPrimary
            : Theme.of(context).colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      checkmarkColor: Theme.of(context).colorScheme.onPrimary,
    );
  }
}
