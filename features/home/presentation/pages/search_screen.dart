import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:mail_up/core/router/router_definitions.dart';
import 'package:mail_up/features/home/data/models/email_models.dart';
import 'package:mail_up/features/home/presentation/providers/mail_provider.dart';

enum _Filter { all, unread, starred, attachment, from, date, label }

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  final _fromController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounce;

  _Filter _activeFilter = _Filter.all;
  DateTime? _afterDate;
  DateTime? _beforeDate;
  EmailLabel? _selectedLabel;

  List<EmailMessage> _results = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = false;
  String? _nextPageToken;
  bool _hasSearched = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _fromController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 250) {
      _loadMore();
    }
  }

  void _onTextChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _search(reset: true);
    });
  }

  String _buildQuery() {
    final base = _searchController.text.trim();
    switch (_activeFilter) {
      case _Filter.all:
        return base;
      case _Filter.unread:
        return base.isEmpty ? 'is:unread' : '$base is:unread';
      case _Filter.starred:
        return base.isEmpty ? 'is:starred' : '$base is:starred';
      case _Filter.attachment:
        return base.isEmpty ? 'has:attachment' : '$base has:attachment';
      case _Filter.from:
        final from = _fromController.text.trim();
        if (from.isEmpty) return base;
        final fromClause = 'from:$from';
        return base.isEmpty ? fromClause : '$base $fromClause';
      case _Filter.date:
        var q = base;
        if (_afterDate != null) {
          q += ' after:${DateFormat('yyyy/MM/dd').format(_afterDate!)}';
        }
        if (_beforeDate != null) {
          q += ' before:${DateFormat('yyyy/MM/dd').format(_beforeDate!)}';
        }
        return q.trim();
      case _Filter.label:
        if (_selectedLabel == null) return base;
        final labelClause = 'label:"${_selectedLabel!.name}"';
        return base.isEmpty ? labelClause : '$base $labelClause';
    }
  }

  Future<void> _search({bool reset = false}) async {
    final query = _buildQuery();
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _hasSearched = false;
        _error = null;
      });
      return;
    }

    if (reset) {
      setState(() {
        _isLoading = true;
        _hasSearched = true;
        _nextPageToken = null;
        _results = [];
        _error = null;
      });
    }

    try {
      final repo = ref.read(mailRepositoryProvider);
      final result = await repo.searchEmails(
        query: query,
        pageToken: reset ? null : _nextPageToken,
      );
      if (!mounted) return;
      setState(() {
        _results = result.messages;
        _nextPageToken = result.nextPageToken;
        _hasMore = result.nextPageToken != null;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Search failed. Please try again.';
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore || _nextPageToken == null) return;
    setState(() => _isLoadingMore = true);
    try {
      final repo = ref.read(mailRepositoryProvider);
      final result = await repo.searchEmails(
        query: _buildQuery(),
        pageToken: _nextPageToken,
      );
      if (!mounted) return;
      setState(() {
        _results = [..._results, ...result.messages];
        _nextPageToken = result.nextPageToken;
        _hasMore = result.nextPageToken != null;
        _isLoadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingMore = false);
    }
  }

  void _setFilter(_Filter filter) {
    if (_activeFilter == filter) return;
    setState(() {
      _activeFilter = filter;
      _afterDate = null;
      _beforeDate = null;
      _selectedLabel = null;
    });
    // Immediately search for non-input filters
    if (filter == _Filter.all ||
        filter == _Filter.unread ||
        filter == _Filter.starred ||
        filter == _Filter.attachment) {
      _search(reset: true);
    }
  }

  Future<void> _pickDate(bool isAfter) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      setState(() {
        if (isAfter) {
          _afterDate = picked;
        } else {
          _beforeDate = picked;
        }
      });
      _search(reset: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final labelsAsync = ref.watch(mailLabelsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // ── Search bar ────────────────────────────────
          _SearchBar(
            controller: _searchController,
            onClear: () {
              _searchController.clear();
              setState(() {
                _results = [];
                _hasSearched = false;
              });
            },
          ),

          // ── Filter chips ──────────────────────────────
          _FilterChipsRow(
            activeFilter: _activeFilter,
            onFilterSelected: _setFilter,
          ),

          // ── Filter-specific inputs ────────────────────
          if (_activeFilter == _Filter.from)
            _FromInput(
              controller: _fromController,
              onSubmitted: () => _search(reset: true),
            ),

          if (_activeFilter == _Filter.date)
            _DateRangeInput(
              afterDate: _afterDate,
              beforeDate: _beforeDate,
              onPickAfter: () => _pickDate(true),
              onPickBefore: () => _pickDate(false),
              onClear: () {
                setState(() {
                  _afterDate = null;
                  _beforeDate = null;
                });
                _search(reset: true);
              },
            ),

          if (_activeFilter == _Filter.label)
            labelsAsync.when(
              loading: () => const SizedBox(height: 48),
              error: (e, _) => const SizedBox.shrink(),
              data: (labels) => _LabelSelector(
                labels: labels,
                selected: _selectedLabel,
                onSelected: (label) {
                  setState(() => _selectedLabel = label);
                  _search(reset: true);
                },
              ),
            ),

          Divider(
            height: 1,
            color: Theme.of(
              context,
            ).colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),

          // ── Results ───────────────────────────────────
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(_error!, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            FilledButton(onPressed: () => _search(reset: true), child: const Text('Retry')),
          ],
        ),
      );
    }

    if (!_hasSearched) {
      return _EmptyPrompt(activeFilter: _activeFilter);
    }

    if (_results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Bootstrap.inbox,
              size: 56,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Try different keywords or filters',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _results.length + 1,
      itemBuilder: (context, index) {
        if (index == _results.length) {
          return _BottomStatus(
            isLoadingMore: _isLoadingMore,
            hasMore: _hasMore,
          );
        }
        return _EmailResultCard(
          email: _results[index],
          query: _searchController.text.trim(),
          onTap: () => context.pushNamed(
            AppRoute.summaryDetail.name,
            extra: {'emailId': _results[index].id, 'email': _results[index]},
          ),
        );
      },
    );
  }
}

// ── Search bar ─────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onClear;

  const _SearchBar({required this.controller, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 8,
        right: 16,
        bottom: 8,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: controller,
                autofocus: true,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search emails...',
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  suffixIcon: ValueListenableBuilder(
                    valueListenable: controller,
                    builder: (context, value, _) => value.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18),
                            onPressed: onClear,
                          )
                        : const SizedBox.shrink(),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Filter chips row ───────────────────────────────────────────────────────

class _FilterChipsRow extends StatelessWidget {
  final _Filter activeFilter;
  final ValueChanged<_Filter> onFilterSelected;

  const _FilterChipsRow({
    required this.activeFilter,
    required this.onFilterSelected,
  });

  static const _filters = [
    (_Filter.all, 'All', Icons.all_inbox_rounded),
    (_Filter.unread, 'Unread', Icons.mark_email_unread_rounded),
    (_Filter.starred, 'Starred', Icons.star_rounded),
    (_Filter.attachment, 'Attachment', Icons.attach_file_rounded),
    (_Filter.from, 'From', Icons.person_rounded),
    (_Filter.date, 'Date', Icons.date_range_rounded),
    (_Filter.label, 'Label', Icons.label_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (filter, label, icon) = _filters[index];
          final isSelected = activeFilter == filter;
          return FilterChip(
            avatar: Icon(icon, size: 15),
            label: Text(label),
            selected: isSelected,
            showCheckmark: false,
            onSelected: (_) => onFilterSelected(filter),
          );
        },
      ),
    );
  }
}

// ── From input ─────────────────────────────────────────────────────────────

class _FromInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmitted;

  const _FromInput({required this.controller, required this.onSubmitted});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: TextField(
        controller: controller,
        autofocus: false,
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => onSubmitted(),
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          hintText: 'Sender email or name...',
          prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
          suffixIcon: TextButton(
            onPressed: onSubmitted,
            child: const Text('Search'),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          isDense: true,
        ),
      ),
    );
  }
}

// ── Date range input ───────────────────────────────────────────────────────

class _DateRangeInput extends StatelessWidget {
  final DateTime? afterDate;
  final DateTime? beforeDate;
  final VoidCallback onPickAfter;
  final VoidCallback onPickBefore;
  final VoidCallback onClear;

  const _DateRangeInput({
    required this.afterDate,
    required this.beforeDate,
    required this.onPickAfter,
    required this.onPickBefore,
    required this.onClear,
  });

  String _fmt(DateTime? d) =>
      d == null ? 'Any' : DateFormat('MMM d, yyyy').format(d);

  @override
  Widget build(BuildContext context) {
    final hasAny = afterDate != null || beforeDate != null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: _DateChip(
              label: 'After: ${_fmt(afterDate)}',
              isSet: afterDate != null,
              onTap: onPickAfter,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _DateChip(
              label: 'Before: ${_fmt(beforeDate)}',
              isSet: beforeDate != null,
              onTap: onPickBefore,
            ),
          ),
          if (hasAny) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 18),
              onPressed: onClear,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ],
        ],
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  final String label;
  final bool isSet;
  final VoidCallback onTap;

  const _DateChip({
    required this.label,
    required this.isSet,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSet
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(10),
          border: isSet
              ? Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.4),
                )
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 14,
              color: isSet
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isSet
                      ? Theme.of(context).colorScheme.onPrimaryContainer
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: isSet ? FontWeight.w600 : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Label selector ─────────────────────────────────────────────────────────

class _LabelSelector extends StatelessWidget {
  final List<EmailLabel> labels;
  final EmailLabel? selected;
  final ValueChanged<EmailLabel> onSelected;

  const _LabelSelector({
    required this.labels,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final userLabels = labels.where((l) => l.type == 'user').toList();
    if (userLabels.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        child: Text(
          'No custom labels available',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
        itemCount: userLabels.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final label = userLabels[index];
          final isSelected = selected?.id == label.id;
          return ChoiceChip(
            label: Text(label.name),
            selected: isSelected,
            showCheckmark: false,
            onSelected: (_) => onSelected(label),
          );
        },
      ),
    );
  }
}

// ── Empty prompt ───────────────────────────────────────────────────────────

class _EmptyPrompt extends StatelessWidget {
  final _Filter activeFilter;

  const _EmptyPrompt({required this.activeFilter});

  String get _hint {
    switch (activeFilter) {
      case _Filter.all:
        return 'Type to search your inbox';
      case _Filter.unread:
        return 'Showing all unread emails';
      case _Filter.starred:
        return 'Showing starred emails';
      case _Filter.attachment:
        return 'Showing emails with attachments';
      case _Filter.from:
        return 'Enter a sender email or name above';
      case _Filter.date:
        return 'Pick a date range above to filter';
      case _Filter.label:
        return 'Select a label above to filter';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Bootstrap.search,
            size: 56,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            _hint,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Bottom pagination status ───────────────────────────────────────────────

class _BottomStatus extends StatelessWidget {
  final bool isLoadingMore;
  final bool hasMore;

  const _BottomStatus({required this.isLoadingMore, required this.hasMore});

  @override
  Widget build(BuildContext context) {
    if (isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (!hasMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'All results loaded',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }
    return const SizedBox(height: 16);
  }
}

// ── Email result card ──────────────────────────────────────────────────────

class _EmailResultCard extends StatelessWidget {
  final EmailMessage email;
  final String query;
  final VoidCallback onTap;

  const _EmailResultCard({
    required this.email,
    required this.query,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final initial =
        email.sender.isNotEmpty ? email.sender[0].toUpperCase() : '?';
    final time = _formatTime(email.date);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.12),
                  child: Text(
                    initial,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              email.sender,
                              style: Theme.of(
                                context,
                              ).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            time,
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(fontSize: 11),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        email.subject,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        email.snippet,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (email.hasAttachments)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Row(
                            children: [
                              Icon(
                                Icons.attach_file_rounded,
                                size: 12,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Has attachment',
                                style: Theme.of(
                                  context,
                                ).textTheme.labelSmall?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return DateFormat.jm().format(date);
    if (diff.inDays < 7) return DateFormat.E().format(date);
    return DateFormat('MMM d').format(date);
  }
}
